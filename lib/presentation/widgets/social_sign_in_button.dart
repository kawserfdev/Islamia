import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? iconPath;
  final IconData? icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const SocialSignInButton({
    Key? key,
    required this.onPressed,
    this.iconPath,
    this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null ? BorderSide(color: borderColor!) : null,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              Image.asset(
                iconPath!,
                height: 20,
                width: 20,
              ),
            ] else if (icon != null) ...[
              Icon(icon, size: 20),
            ],
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}