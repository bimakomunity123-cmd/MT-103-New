import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool filled;

  const NeonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.filled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accentGreen;
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? c.withOpacity(0.1) : AppColors.bgInput,
          border: Border.all(color: c.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: c,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
