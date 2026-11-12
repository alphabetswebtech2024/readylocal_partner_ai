import 'package:flutter/material.dart';

import '../../../../core/design/app_colors.dart';

/// Animated logo. It begins exactly like the native launch screen (the pin
/// alone on white), so nothing jumps when Flutter takes over:
///   1. the pin pops in the centre with a soft blue ring,
///   2. it slides left as "ReadyLocal" wipes in beside it,
///   3. the tagline rises in and a blue-to-red line sweeps underneath.
/// One controller and plain transforms, so it stays smooth on 2 GB phones.
class SplashLogoWidget extends StatefulWidget {
  const SplashLogoWidget({super.key});

  /// Length of the animation; the splash waits at least this long.
  static const Duration duration = Duration(milliseconds: 1800);

  @override
  State<SplashLogoWidget> createState() => _SplashLogoWidgetState();
}

class _SplashLogoWidgetState extends State<SplashLogoWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: SplashLogoWidget.duration);

  Animation<double> _part(double from, double to, Curve curve) =>
      CurvedAnimation(parent: _c, curve: Interval(from, to, curve: curve));

  late final Animation<double> _pop = _part(0, 0.30, Curves.easeOutBack);
  late final Animation<double> _ring = _part(0.12, 0.55, Curves.easeOutCubic);
  late final Animation<double> _slide = _part(0.28, 0.52, Curves.easeInOutCubic);
  late final Animation<double> _wipe = _part(0.48, 0.76, Curves.easeOutCubic);
  late final Animation<double> _tagline = _part(0.70, 0.88, Curves.easeOut);
  late final Animation<double> _sweep = _part(0.72, 1, Curves.easeInOutCubic);
  late final Animation<double> _shapes = _part(0, 0.6, Curves.easeOutCubic);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Respect the phone's "remove animations" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).width;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // Same proportions as the supplied logo.
    final total = (screen * 0.76).clamp(240.0, 360.0);
    final markWidth = total * 0.157;
    final markHeight = markWidth * 348 / 235;
    final wordLeft = total * 0.195;
    final wordWidth = total - wordLeft;
    final wordHeight = wordWidth * 234 / 1209;
    final taglineWidth = wordWidth * 0.86;
    int px(double logical) => (logical * dpr).round();

    final word = Image.asset(
      'assets/images/logo_word.png',
      width: wordWidth,
      cacheWidth: px(wordWidth),
    );
    final tagline = Image.asset(
      'assets/images/logo_tagline.png',
      width: taglineWidth,
      cacheWidth: px(taglineWidth),
    );
    final mark = Image.asset(
      'assets/images/logo_mark_large.png',
      width: markWidth,
      height: markHeight,
      cacheWidth: px(markWidth * 1.3),
    );

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          // Brand shapes drift in from the corners.
          AnimatedBuilder(
            animation: _shapes,
            builder: (context, _) {
              final t = _shapes.value;
              return Stack(
                children: [
                  Positioned(
                    top: -screen * (0.62 - 0.34 * t),
                    right: -screen * (0.56 - 0.34 * t),
                    child: _circle(screen * 0.72, AppColors.primaryTint),
                  ),
                  Positioned(
                    bottom: -screen * (0.72 - 0.38 * t),
                    left: -screen * (0.60 - 0.34 * t),
                    child: _circle(screen * 0.8, AppColors.accentTint),
                  ),
                ],
              );
            },
          ),
          Center(
            child: SizedBox(
              width: total,
              height: markHeight + 40,
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  // The pin starts centred, then moves to its place in the logo.
                  final centred = (total - markWidth) / 2;
                  final x = centred * (1 - _slide.value);
                  const top = 0.0;
                  final wordTop = top + (markHeight - wordHeight - wordHeight * 0.45) / 2 - 2;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Ring that spreads out as the pin lands.
                      Positioned(
                        left: x + markWidth / 2 - markHeight,
                        top: top + markHeight / 2 - markHeight,
                        child: Opacity(
                          opacity: (1 - _ring.value).clamp(0.0, 1.0) * (_c.value > 0.12 ? 0.55 : 0),
                          child: Transform.scale(
                            scale: 0.35 + 0.95 * _ring.value,
                            child: Container(
                              width: markHeight * 2,
                              height: markHeight * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: x,
                        top: top,
                        child: Transform.scale(
                          scale: _pop.value.clamp(0.0, 1.2) * (1.22 - 0.22 * _slide.value),
                          child: mark,
                        ),
                      ),
                      Positioned(
                        left: wordLeft,
                        top: wordTop,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: _wipe.value.clamp(0.0, 1.0),
                            child: word,
                          ),
                        ),
                      ),
                      Positioned(
                        left: wordLeft + (wordWidth - taglineWidth) / 2,
                        top: wordTop + wordHeight + 8 + 10 * (1 - _tagline.value),
                        child: Opacity(opacity: _tagline.value, child: tagline),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Line that sweeps in the logo's blue-to-red while the app gets ready.
          Positioned(
            left: 0,
            right: 0,
            bottom: 84,
            child: Center(
              child: SizedBox(
                width: total * 0.42,
                height: 4,
                child: AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, _) => Opacity(
                    opacity: _tagline.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: ColoredBox(
                        color: AppColors.border,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _sweep.value,
                          child: const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.brandRibbon)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
