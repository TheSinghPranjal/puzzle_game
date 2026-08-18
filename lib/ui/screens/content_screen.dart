import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/logic/grid_validation.dart';
import 'package:puzzle_match/models/stage_config.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/widgets/puzzle_thumb.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  int _level = 1;
  int _stage = 1;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final stage = app.config.stage(_level, _stage);
    return Scaffold(
      appBar: AppBar(title: const Text('Game content')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Picker(
            label: 'Level',
            value: _level,
            min: 1,
            max: app.config.levelCount,
            onChanged: (value) => setState(() {
              _level = value;
              _stage = 1;
            }),
          ),
          _Picker(
            label: 'Stage',
            value: _stage,
            min: 1,
            max: GameConfig.stagesPerLevel,
            onChanged: (value) => setState(() => _stage = value),
          ),
          const SizedBox(height: 8),
          Text(
            'Grid ${stage.rows} × ${stage.columns}  ·  ${stage.timerSeconds}s  ·  ${stage.images.length}/${GridValidation.maxImagesPerStage} images',
            style: const TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  label: 'Rows',
                  value: stage.rows,
                  onSubmitted: (rows) => _saveLayout(app, rows: rows),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  label: 'Columns',
                  value: stage.columns,
                  onSubmitted: (columns) => _saveLayout(app, columns: columns),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  label: 'Timer',
                  value: stage.timerSeconds,
                  onSubmitted: (timer) => _saveLayout(app, timer: timer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final image in stage.images)
                SizedBox(
                  width: 96,
                  height: 128,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: PuzzleThumb(
                            image: image,
                            repository: app.images,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          onPressed: () => app.removeImageFromStage(
                            _level,
                            _stage,
                            image,
                          ),
                          icon: const Icon(Icons.delete_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              if (stage.images.length < GridValidation.maxImagesPerStage)
                InkWell(
                  onTap: () async {
                    final error = await app.addImageToStage(_level, _stage);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                    }
                  },
                  child: Container(
                    width: 96,
                    height: 128,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accent),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: AppTheme.accent),
                          Text('Add', style: TextStyle(color: AppTheme.accent)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'PNG, JPG, or WebP. Maximum 5 images per stage. One is chosen at random each attempt.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLayout(
    AppController app, {
    int? rows,
    int? columns,
    int? timer,
  }) async {
    final current = app.config.stage(_level, _stage);
    final error = await app.updateStageLayout(
      level: _level,
      stage: _stage,
      rows: rows ?? current.rows,
      columns: columns ?? current.columns,
      timerSeconds: timer ?? current.timerSeconds,
    );
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _Picker extends StatelessWidget {
  const _Picker({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String label;
  final int value;
  final ValueChanged<int> onSubmitted;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != '${widget.value}') {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) widget.onSubmitted(parsed);
      },
    );
  }
}
