import 'dart:convert';

import 'package:puzzle_match/models/profile.dart';
import 'package:puzzle_match/models/puzzle_snapshot.dart';
import 'package:puzzle_match/models/stage_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistedAppData {
  const PersistedAppData({
    required this.selectedProfileId,
    required this.profiles,
    required this.config,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.debugMode,
    this.activeSnapshot,
  });

  final String selectedProfileId;
  final List<PlayerProfile> profiles;
  final GameConfig config;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool debugMode;
  final PuzzleSnapshot? activeSnapshot;

  PersistedAppData copyWith({
    String? selectedProfileId,
    List<PlayerProfile>? profiles,
    GameConfig? config,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? debugMode,
    PuzzleSnapshot? activeSnapshot,
    bool clearSnapshot = false,
  }) {
    return PersistedAppData(
      selectedProfileId: selectedProfileId ?? this.selectedProfileId,
      profiles: profiles ?? this.profiles,
      config: config ?? this.config,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      debugMode: debugMode ?? this.debugMode,
      activeSnapshot: clearSnapshot
          ? null
          : (activeSnapshot ?? this.activeSnapshot),
    );
  }
}

class StorageService {
  StorageService({SharedPreferences? prefs}) : _prefs = prefs;

  static const _key = 'puzzle_match_state_v1';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<PersistedAppData> load() async {
    await init();
    final raw = _prefs!.getString(_key);
    if (raw == null || raw.isEmpty) {
      return _fresh();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final defaults = PlayerProfile.defaults();
      final savedProfiles = (json['profiles'] as List<dynamic>? ?? const [])
          .map((item) => PlayerProfile.fromJson(item as Map<String, dynamic>))
          .toList();
      final profiles = [
        for (final fallback in defaults)
          savedProfiles.cast<PlayerProfile>().where((item) => item.id == fallback.id).isEmpty
              ? fallback
              : savedProfiles.firstWhere((item) => item.id == fallback.id),
      ];
      final configJson = json['config'] as Map<String, dynamic>?;
      return PersistedAppData(
        selectedProfileId:
            json['selectedProfileId'] as String? ??
            PlayerProfile.defaultProfileId,
        profiles: profiles,
        config: configJson == null
            ? GameConfig.standard()
            : GameConfig.fromJson(configJson),
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        debugMode: json['debugMode'] as bool? ?? false,
        activeSnapshot: json['activeSnapshot'] == null
            ? null
            : PuzzleSnapshot.fromJson(
                json['activeSnapshot'] as Map<String, dynamic>,
              ),
      );
    } catch (_) {
      return _fresh();
    }
  }

  Future<void> save(PersistedAppData data) async {
    await init();
    final json = <String, dynamic>{
      'selectedProfileId': data.selectedProfileId,
      'profiles': data.profiles.map((profile) => profile.toJson()).toList(),
      'config': data.config.toJson(),
      'soundEnabled': data.soundEnabled,
      'musicEnabled': data.musicEnabled,
      'debugMode': data.debugMode,
      'activeSnapshot': data.activeSnapshot?.toJson(),
    };
    await _prefs!.setString(_key, jsonEncode(json));
  }

  PersistedAppData _fresh() {
    return PersistedAppData(
      selectedProfileId: PlayerProfile.defaultProfileId,
      profiles: PlayerProfile.defaults(),
      config: GameConfig.standard(),
      soundEnabled: true,
      musicEnabled: true,
      debugMode: false,
    );
  }
}
