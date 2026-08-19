import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puzzle_match/logic/grid_validation.dart';
import 'package:puzzle_match/logic/puzzle_engine.dart';
import 'package:puzzle_match/logic/reward_service.dart';
import 'package:puzzle_match/logic/session_image_picker.dart';
import 'package:puzzle_match/logic/timer_controller.dart';
import 'package:puzzle_match/models/profile.dart';
import 'package:puzzle_match/models/puzzle_asset_catalog.dart';
import 'package:puzzle_match/models/puzzle_image_ref.dart';
import 'package:puzzle_match/models/puzzle_snapshot.dart';
import 'package:puzzle_match/models/stage_config.dart';
import 'package:puzzle_match/services/image_repository.dart';
import 'package:puzzle_match/services/storage_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    StorageService? storage,
    ImageRepository? images,
    RewardService rewardService = const RewardService(),
    Random? random,
    SessionImagePicker? sessionImages,
  }) : _storage = storage ?? StorageService(),
       images = images ?? ImageRepository(),
       _rewards = rewardService,
       _random = random ?? Random(),
       _sessionImages = sessionImages ?? SessionImagePicker();

  final StorageService _storage;
  final ImageRepository images;
  final RewardService _rewards;
  final Random _random;
  final SessionImagePicker _sessionImages;
  final ImagePicker _picker = ImagePicker();

  bool ready = false;
  String? lastError;

  late GameConfig config;
  late List<PlayerProfile> profiles;
  late String selectedProfileId;
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool debugMode = false;
  bool darkMode = true;

  PuzzleEngine? engine;
  GameTimerController? timer;
  TickerProvider? _vsync;
  GamePhase phase = GamePhase.countdown;
  int currentLevel = 1;
  int currentStage = 1;
  PuzzleImageRef? currentImage;
  ui.Image? boardImage;
  bool rewardGranted = false;
  int? hintFrom;
  int? hintTo;
  Set<int> recentlySolved = {};

  PlayerProfile get profile =>
      profiles.firstWhere((item) => item.id == selectedProfileId);

  bool get canResume => profile.canResume;
  bool get hintsAvailable => profile.hintPoints > 0;
  bool get isPlaying => phase == GamePhase.playing;
  bool get boardLocked =>
      phase != GamePhase.playing || engine == null || boardImage == null;

  Future<void> load() async {
    final data = await _storage.load();
    config = PuzzleAssetCatalog.apply(
      GameConfig.withStandardLayouts(data.config),
      await PuzzleAssetCatalog.loadFromBundle(),
    );
    profiles = data.profiles;
    selectedProfileId = data.selectedProfileId;
    if (!profiles.any((item) => item.id == selectedProfileId)) {
      selectedProfileId = PlayerProfile.defaultProfileId;
    }
    soundEnabled = data.soundEnabled;
    musicEnabled = data.musicEnabled;
    debugMode = data.debugMode;
    darkMode = data.darkMode;
    ready = true;
    await _storage.save(
      PersistedAppData(
        selectedProfileId: selectedProfileId,
        profiles: profiles,
        config: config,
        soundEnabled: soundEnabled,
        musicEnabled: musicEnabled,
        debugMode: debugMode,
        darkMode: darkMode,
        activeSnapshot: data.activeSnapshot,
      ),
    );
    notifyListeners();
  }

  Future<void> selectProfile(String id) async {
    selectedProfileId = id;
    _sessionImages.reset();
    await _persist();
    notifyListeners();
  }

  Future<String?> startNewGame() {
    _sessionImages.reset();
    return startStage(1, 1);
  }

  Future<String?> resumeGame() {
    return startStage(profile.resumeLevel, profile.resumeStage);
  }

  Future<String?> startStage(int level, int stage) async {
    lastError = null;
    final stageConfig = config.stage(level, stage);
    final playable = PuzzleAssetCatalog.withoutGenerated(stageConfig.images);
    if (playable.isEmpty) {
      lastError = 'This stage has no images. Add one in Settings.';
      notifyListeners();
      return lastError;
    }

    final picked = await _pickPlayableImage(level, stage, playable);
    if (picked == null) {
      lastError = 'No valid image could be loaded for this stage.';
      notifyListeners();
      return lastError;
    }

    timer?.dispose();
    currentLevel = level;
    currentStage = stage;
    currentImage = picked.ref;
    boardImage = picked.image;
    engine = PuzzleEngine.shuffled(
      rows: stageConfig.rows,
      columns: stageConfig.columns,
      random: _random,
    );
    rewardGranted = false;
    recentlySolved = {};
    hintFrom = null;
    hintTo = null;
    phase = GamePhase.countdown;
    timer = GameTimerController(
      duration: Duration(seconds: stageConfig.timerSeconds),
      onTick: (_) => notifyListeners(),
      onExpired: handleTimeExpired,
    );
    if (_vsync != null) {
      timer!.attachTicker(_vsync!);
    }

    _replaceProfile(
      profile.copyWith(
        hasStarted: true,
        resumeLevel: level,
        resumeStage: stage,
      ),
    );
    await _persist(clearSnapshot: true);
    notifyListeners();
    return null;
  }

  void attachTicker(TickerProvider vsync) {
    _vsync = vsync;
    timer?.attachTicker(vsync);
  }

  void beginPlay() {
    if (phase != GamePhase.countdown) return;
    phase = GamePhase.playing;
    timer?.start();
    notifyListeners();
  }

  void pauseGame() {
    if (phase != GamePhase.playing) return;
    timer?.pause();
    phase = GamePhase.paused;
    notifyListeners();
  }

  void resumePausedGame() {
    if (phase != GamePhase.paused) return;
    phase = GamePhase.playing;
    timer?.resume();
    notifyListeners();
  }

  Future<void> leaveToHome() async {
    timer?.pause();
    engine = null;
    boardImage = null;
    currentImage = null;
    phase = GamePhase.countdown;
    timer?.dispose();
    timer = null;
    await _persist(clearSnapshot: true);
    notifyListeners();
  }

  void handleAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (phase == GamePhase.playing) {
        pauseGame();
      }
    }
  }

  void onBoardMoved(MoveResult result) {
    if (!result.applied || engine == null) return;
    recentlySolved = result.solvedPositionIndexes;
    if (engine!.isSolved) {
      _completeStage();
    } else {
      notifyListeners();
    }
  }

  Future<bool> useHint() async {
    if (boardLocked || engine == null) return false;
    if (profile.hintPoints <= 0) return false;
    final unsolved = engine!.firstUnsolvedPosition();
    if (unsolved == null) return false;
    hintFrom = engine!.positionOf(unsolved);
    hintTo = unsolved;
    _replaceProfile(profile.copyWith(hintPoints: profile.hintPoints - 1));
    final result = engine!.applyHint();
    recentlySolved = result.solvedPositionIndexes;
    await _persist();
    if (engine!.isSolved) {
      _completeStage();
    } else {
      notifyListeners();
    }
    return result.applied;
  }

  void handleTimeExpired() {
    if (phase == GamePhase.completed || phase == GamePhase.failed) return;
    if (engine?.isSolved == true) return;
    phase = GamePhase.failed;
    timer?.stop();
    notifyListeners();
  }

  Future<String?> retryStage() {
    return startStage(currentLevel, currentStage);
  }

  Future<String?> continueAfterWin() {
    final next = config.nextStage(currentLevel, currentStage);
    if (next == null) {
      return Future.value(null);
    }
    return startStage(next.$1, next.$2);
  }

  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    await _persist();
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    musicEnabled = !musicEnabled;
    await _persist();
    notifyListeners();
  }

  Future<void> toggleDebug() async {
    debugMode = !debugMode;
    await _persist();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    darkMode = !darkMode;
    await _persist();
    notifyListeners();
  }

  Future<String?> addImageToStage(int level, int stage) async {
    final current = config.stage(level, stage);
    if (current.images.length >= GridValidation.maxImagesPerStage) {
      return 'Maximum ${GridValidation.maxImagesPerStage} images per stage.';
    }
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked == null) return null;
    try {
      final imported = await images.importPickedFile(picked.path);
      final updated = current.copyWith(
        images: [...PuzzleAssetCatalog.withoutGenerated(current.images), imported],
      );
      config = config.replacingStage(level, updated);
      await _persist();
      notifyListeners();
      return null;
    } on ImageLoadException catch (error) {
      return error.message;
    } catch (_) {
      return 'Could not add that image.';
    }
  }

  Future<void> removeImageFromStage(
    int level,
    int stage,
    PuzzleImageRef image,
  ) async {
    if (image.isBundled) {
      lastError = 'Bundled level images cannot be removed.';
      notifyListeners();
      return;
    }
    final current = config.stage(level, stage);
    if (current.images.length <= GridValidation.minImagesPerStage) {
      lastError = 'Each stage needs at least one image.';
      notifyListeners();
      return;
    }
    final updated = current.copyWith(
      images: [for (final item in current.images) if (item.id != image.id) item],
    );
    config = config.replacingStage(level, updated);
    await images.deleteFile(image);
    await _persist();
    notifyListeners();
  }

  Future<String?> updateStageLayout({
    required int level,
    required int stage,
    required int rows,
    required int columns,
    required int timerSeconds,
  }) async {
    final error = GridValidation.validate(rows, columns);
    if (error != null) return error;
    final clampedTimer = timerSeconds.clamp(
      GameConfig.minTimerSeconds,
      GameConfig.maxTimerSeconds,
    );
    final current = config.stage(level, stage);
    config = config.replacingStage(
      level,
      current.copyWith(
        rows: rows,
        columns: columns,
        timerSeconds: clampedTimer,
      ),
    );
    await _persist();
    notifyListeners();
    return null;
  }

  Future<void> resetCurrentProfile() async {
    final reset = PlayerProfile.defaults().firstWhere(
      (item) => item.id == profile.id,
    );
    _replaceProfile(reset);
    await _persist(clearSnapshot: true);
    notifyListeners();
  }

  void _completeStage() {
    if (phase == GamePhase.completed) return;
    timer?.stop();
    phase = GamePhase.completed;
    final grant = _rewards.grantIfNeeded(alreadyGranted: rewardGranted);
    rewardGranted = true;
    final next = config.nextStage(currentLevel, currentStage);
    var updated = profile.withProgress(
      level: currentLevel,
      stage: currentStage,
      completed: true,
      awardRewards: grant.coins > 0,
    );
    if (next != null) {
      updated = updated.copyWith(resumeLevel: next.$1, resumeStage: next.$2);
    }
    _replaceProfile(updated);
    _persist(clearSnapshot: true);
    notifyListeners();
  }

  void _replaceProfile(PlayerProfile updated) {
    profiles = [
      for (final item in profiles)
        if (item.id == updated.id) updated else item,
    ];
  }

  Future<void> _persist({bool clearSnapshot = false}) {
    return _storage.save(
      PersistedAppData(
        selectedProfileId: selectedProfileId,
        profiles: profiles,
        config: config,
        soundEnabled: soundEnabled,
        musicEnabled: musicEnabled,
        debugMode: debugMode,
        darkMode: darkMode,
        activeSnapshot: clearSnapshot ? null : _snapshotOrNull(),
      ),
    );
  }

  PuzzleSnapshot? _snapshotOrNull() {
    if (engine == null || currentImage == null || timer == null) return null;
    if (phase != GamePhase.paused && phase != GamePhase.playing) return null;
    return PuzzleSnapshot(
      level: currentLevel,
      stage: currentStage,
      imageId: currentImage!.id,
      placement: engine!.placement,
      remainingMs: timer!.remaining.inMilliseconds,
      phase: GamePhase.paused,
    );
  }

  Future<({PuzzleImageRef ref, ui.Image image})?> _pickPlayableImage(
    int level,
    int stage,
    List<PuzzleImageRef> pool,
  ) async {
    final remaining = [
      for (final ref in pool)
        if (!ref.isGenerated) ref,
    ];
    while (remaining.isNotEmpty) {
      final ref = _sessionImages.next(
        level: level,
        stage: stage,
        pool: remaining,
        random: _random,
      );
      try {
        final image = await images.resolve(ref);
        return (ref: ref, image: image);
      } catch (_) {
        remaining.removeWhere((item) => item.id == ref.id);
      }
    }
    return null;
  }

  @override
  void dispose() {
    timer?.dispose();
    images.dispose();
    super.dispose();
  }
}
