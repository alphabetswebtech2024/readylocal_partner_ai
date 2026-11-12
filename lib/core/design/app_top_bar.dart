import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// The one header used across the app: logo-blue gradient, white title and a
/// thin blue-to-red line taken from the logo. It draws behind the status bar
/// and sets light status-bar icons itself, so use it outside any top SafeArea.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.showBack = true, this.onBack, this.actions = const []});

  final String title;
  final bool showBack;

  /// Default is the usual back behaviour (Navigator.maybePop).
  final VoidCallback? onBack;
  final List<Widget> actions;

  static const double barHeight = 58;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        padding: EdgeInsets.only(top: top),
        child: SizedBox(
          height: barHeight,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (showBack)
                        Semantics(
                          button: true,
                          label: MaterialLocalizations.of(context).backButtonTooltip,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: onBack ?? () => Navigator.maybePop(context),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(Icons.arrow_back_rounded, size: 21, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 4),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                ),
              ),
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.accent, Color(0x00C93438)], stops: [0, 0.55]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
