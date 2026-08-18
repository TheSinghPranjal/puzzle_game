import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/motion.dart';
import 'package:puzzle_match/ui/screens/content_screen.dart';
import 'package:puzzle_match/ui/screens/how_to_play_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Sound'),
            value: app.soundEnabled,
            onChanged: (_) => app.toggleSound(),
          ),
          SwitchListTile(
            title: const Text('Music'),
            value: app.musicEnabled,
            onChanged: (_) => app.toggleMusic(),
          ),
          SwitchListTile(
            secondary: Icon(
              app.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            title: const Text('Dark mode'),
            subtitle: Text(app.darkMode ? 'Navy night theme' : 'Cream daylight theme'),
            value: app.darkMode,
            onChanged: (_) => app.toggleDarkMode(),
          ),
          SwitchListTile(
            title: const Text('Developer tile IDs'),
            subtitle: const Text('For diagnosing shuffle and grouping'),
            value: app.debugMode,
            onChanged: (_) => app.toggleDebug(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Game content'),
            subtitle: const Text('Levels, grids, and image pools'),
            onTap: () => AppMotion.open(context, const ContentScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('How to play'),
            onTap: () => AppMotion.open(context, const HowToPlayScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: const Text('Reset this profile'),
            subtitle: Text('Clears ${app.profile.name} progress, coins, and hints'),
            onTap: () => _confirmReset(context, app),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('About'),
            subtitle: Text('Image Puzzle  ·  version 1.0.0'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppController app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panel(context),
        title: const Text('Reset progress?'),
        content: Text(
          'This resets ${app.profile.name} only. Other profiles are unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.resetCurrentProfile();
    }
  }
}
