import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_match/models/profile.dart';
import 'package:puzzle_match/state/app_controller.dart';
import 'package:puzzle_match/theme/app_theme.dart';
import 'package:puzzle_match/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen shows new game for a fresh profile', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController();
    await controller.load();
    expect(controller.profile.id, PlayerProfile.defaultProfileId);
    expect(controller.config.levels, isNotEmpty);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('NEW GAME'), findsOneWidget);
    expect(find.text('IMAGE PUZZLE'), findsOneWidget);
    expect(find.textContaining('Tiger'), findsWidgets);
  });
}
