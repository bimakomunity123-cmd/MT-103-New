import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final double fontSize;

  const StatusBadge({
    Key? key,
    required this.text,
    this.type = StatusType.online,
    this.fontSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case StatusType.online:
        color = AppColors.accentGreen;
        break;
      case StatusType.active:
        color = AppColors.accentBlue;
        break;
      case StatusType.warning:
        color = AppColors.accentOrange;
        break;
      case StatusType.danger:
        color = AppColors.accentRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum StatusType { online, active, warning, danger }
