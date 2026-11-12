import 'dart:io';
import 'package:flutter/material.dart';
import '../providers/job_progress_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class JobUploadSectionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<UploadItem> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<UploadItem>? onRetry;

  const JobUploadSectionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
        ),
        const SizedBox(height: 10),
        DashedBorderContainer(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: images.isNotEmpty
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisAlignment: images.isNotEmpty
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (images.isNotEmpty) ...[
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: images.length,
                      itemBuilder: (_, i) => _buildImageTile(images[i], i),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onAdd,
                  child: Row(
                    children: [
                      if (images.isEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: AppColors.border,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.textDisabled,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.add,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.addMore,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageTile(UploadItem item, int idx) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(item.file.path),
            fit: BoxFit.cover,
            cacheWidth: 360, // a thumbnail; never decode the full photo into memory
            errorBuilder: (_, _, _) => Container(
              color: AppColors.primaryTint,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, color: AppColors.primary),
            ),
          ),
        ),
        if (item.isUploading)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        if (item.isError)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 26),
            ),
          ),
        if (item.isError && !item.isUploading)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onRetry?.call(item),
              child: Text(
                L10n.current.commonRetry,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onRemove(idx),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const DashedBorderContainer({
    super.key,
    required this.child,
    this.borderColor = AppColors.borderStrong,
    this.borderRadius = 12,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: borderColor,
        radius: borderRadius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}
