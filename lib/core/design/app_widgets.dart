import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Network image with disk + memory caching, decode-at-display-size,
/// a skeleton placeholder and a branded fallback. Use this instead of
/// `Image.network` so images are downloaded once and never decoded larger
/// than they are drawn.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Shown when there is no URL or the download fails.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final fallbackWidget = fallback ?? _DefaultImageFallback(width: width, height: height);
    final link = url?.trim() ?? '';
    Widget child;
    if (link.isEmpty || !(link.startsWith('http://') || link.startsWith('https://'))) {
      child = fallbackWidget;
    } else {
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
      int? cacheSize(double? logical) => (logical == null || !logical.isFinite) ? null : (logical * dpr).round();
      child = CachedNetworkImage(
        imageUrl: link,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheSize(width),
        memCacheHeight: (width == null || !width!.isFinite) ? cacheSize(height) : null,
        fadeInDuration: AppSizes.fast,
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => AppSkeleton(width: width, height: height),
        errorWidget: (_, _, _) => fallbackWidget,
      );
    }
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

class _DefaultImageFallback extends StatelessWidget {
  const _DefaultImageFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final shortest = [width, height].whereType<double>().fold<double>(48, (a, b) => b < a ? b : a);
    return Container(
      width: width,
      height: height,
      color: AppColors.primaryTint,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: AppColors.primary, size: (shortest * 0.45).clamp(16, 40)),
    );
  }
}

/// A calm pulsing grey block used while content loads.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, this.width, this.height, this.radius = 8});

  final double? width;
  final double? height;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.55,
    upperBound: 1,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: AppColors.skeleton, borderRadius: BorderRadius.circular(widget.radius)),
      ),
    );
  }
}

/// Skeleton list shaped like the app's cards, for list screens.
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({super.key, this.count = 4, this.itemHeight = 84, this.padding = const EdgeInsets.all(16)});

  final int count;
  final double itemHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => AppSkeleton(height: itemHeight, radius: AppRadii.card),
    );
  }
}

/// Friendly empty state: icon in a tinted circle, a title and an optional hint.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({super.key, required this.title, this.message, this.icon = Icons.inbox_outlined, this.action});

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, textAlign: TextAlign.center, style: text.titleMedium),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
          if (action != null) ...[const SizedBox(height: AppSpacing.md), action!],
        ],
      ),
    );
  }
}

/// Error state with an optional retry button. Retry only re-runs a read
/// (never a payment or a job action).
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.title, this.message, this.retryLabel, this.onRetry});

  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: message,
      icon: Icons.cloud_off_rounded,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryLabel ?? 'Retry'),
            ),
    );
  }
}

/// Small rounded status label ("Pending", "Completed" ...).
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.label, required this.color, required this.background});

  const AppStatusChip.success({super.key, required this.label})
    : color = AppColors.success,
      background = AppColors.successTint;

  const AppStatusChip.warning({super.key, required this.label})
    : color = AppColors.warning,
      background = AppColors.warningTint;

  const AppStatusChip.danger({super.key, required this.label})
    : color = AppColors.accentPressed,
      background = AppColors.accentTint;

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// Section title with an optional trailing link ("View All").
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(AppSizes.minTouch, 40),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

/// Replaces Flutter's red error screen if a widget ever fails to build.
class AppWidgetErrorBox extends StatelessWidget {
  const AppWidgetErrorBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const Icon(Icons.error_outline_rounded, color: AppColors.textDisabled, size: 28),
    );
  }
}
