// Category/service image loading: decode size, caching widget and fallbacks.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';
import 'package:gotask_partner/features/select_service/domain/entities/service_module_entity.dart';
import 'package:gotask_partner/features/select_service/presentation/widgets/service_module_card.dart';

Widget host(Widget child, {double dpr = 3}) => MediaQuery(
      data: MediaQueryData(devicePixelRatio: dpr),
      child: MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('service tile image is cached and decoded at display size', (tester) async {
    await tester.pumpWidget(host(const AppNetworkImage(url: 'https://img.test/home.png', width: 44, height: 44)));
    final img = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    // Before: Image.network decoded the full source image (e.g. 1024x1024 = 4 MB).
    // After: decoded at 44 logical px x 3 dpr = 132 px (~68 KB).
    expect(img.memCacheWidth, 132);
    expect(img.imageUrl, 'https://img.test/home.png');
  });

  testWidgets('full-width hero images decode by height', (tester) async {
    await tester.pumpWidget(host(const AppNetworkImage(url: 'https://img.test/hero.png', width: double.infinity, height: 200)));
    final img = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(img.memCacheWidth, isNull);
    expect(img.memCacheHeight, 600);
  });

  testWidgets('empty or invalid URL shows the branded fallback, never a broken image', (tester) async {
    for (final url in [null, '', '   ', 'not-a-url']) {
      await tester.pumpWidget(host(AppNetworkImage(url: url, width: 44, height: 44)));
      expect(find.byType(CachedNetworkImage), findsNothing);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    }
  });

  testWidgets('service module card uses the cached image widget', (tester) async {
    final module = const ServiceModuleEntity(id: 'm1', title: 'Home Services', moduleCode: 'HS', image: 'https://img.test/hs.png', hasCategory: true);
    await tester.pumpWidget(host(ServiceModuleCard(module: module, isSelected: false, onTap: () {})));
    expect(find.byType(AppNetworkImage), findsOneWidget);
    expect(find.byType(Image).evaluate().where((e) => (e.widget as Image).image is NetworkImage), isEmpty);
  });
}
