import 'package:flutter/material.dart';
import '../../domain/entities/service_module_entity.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/app_widgets.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';

class ServiceModuleCard extends StatelessWidget {
  final ServiceModuleEntity module;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceModuleCard({
    super.key,
    required this.module,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (module.image != null && module.image!.isNotEmpty) ...[
              AppNetworkImage(
                url: module.image,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10),
                fallback: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.category_outlined, size: 24, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                context.serverLabel(module.title),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? AppColors.accent : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
