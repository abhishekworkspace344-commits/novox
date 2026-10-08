import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toUpperCase();

    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (cleanStatus) {
      case "PRESENT":
      case "ON_TIME":
      case "PAID":
      case "ACTIVE":
      case "SUCCESS":
        bgColor = AppColors.successBg;
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;

      case "LATE":
      case "LATE_ENTRY":
      case "PARTIAL":
      case "PENDING":
        bgColor = AppColors.warningBg;
        textColor = AppColors.warning;
        icon = Icons.access_time;
        break;

      case "ABSENT":
      case "INACTIVE":
      case "OVERDUE":
      case "FAILED":
        bgColor = AppColors.dangerBg;
        textColor = AppColors.danger;
        icon = Icons.cancel_outlined;
        break;

      default:
        bgColor = AppColors.primarySoft;
        textColor = AppColors.primary;
        icon = Icons.info_outline;
        break;
    }

    String displayLabel = cleanStatus.replaceAll('_', ' ');
    if (displayLabel.isEmpty) displayLabel = "UNKNOWN";

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Icon(
              icon,
              size: 13,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
