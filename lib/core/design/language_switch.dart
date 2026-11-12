import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/locale_provider.dart';
import 'app_colors.dart';

/// English / తెలుగు switch for the screens before login. Each option is
/// written in its own language so anyone can find theirs. The same saved
/// setting drives the whole app, including the Profile language menu.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key, this.onDark = false});

  /// True when placed on a blue header.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final track = onDark ? Colors.white.withValues(alpha: 0.16) : AppColors.primaryTint;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(context, provider, const Locale('en'), 'English'),
          _option(context, provider, const Locale('te'), 'తెలుగు'),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, LocaleProvider provider, Locale locale, String label) {
    final selected = provider.locale.languageCode == locale.languageCode;
    final idle = onDark ? Colors.white : AppColors.primary;
    final activeBg = onDark ? Colors.white : AppColors.primary;
    final activeText = onDark ? AppColors.primary : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => provider.setLocale(locale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 36, minWidth: 68),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? activeText : idle),
          ),
        ),
      ),
    );
  }
}
