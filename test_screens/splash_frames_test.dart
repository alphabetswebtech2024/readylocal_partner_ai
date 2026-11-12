// Saves frames of the logo animation for review:
//   flutter test test_screens/splash_frames_test.dart --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/features/splash/presentation/widgets/splash_logo_widget.dart';

import 'harness.dart';

void main() {
  setUpAll(loadFonts);

  testWidgets('splash animation frames', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: SplashLogoWidget())),
    );
    await tester.runAsync(() async {
      for (final name in ['logo_mark_large', 'logo_word', 'logo_tagline']) {
        await precacheImage(AssetImage('assets/images/$name.png'), tester.element(find.byType(SplashLogoWidget)));
      }
    });
    var at = 0;
    for (final ms in [150, 350, 650, 900, 1150, 1400, 1800]) {
      await tester.pump(Duration(milliseconds: ms - at));
      at = ms;
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
      await tester.pump();
      await expectLater(find.byType(Scaffold), matchesGoldenFile('shots/splash/frame_${ms.toString().padLeft(4, '0')}.png'));
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
