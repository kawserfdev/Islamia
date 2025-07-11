import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const SettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: leading != null 
          ? Icon(
              leading,
              color: titleColor ?? theme.colorScheme.onSurface,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null 
          ? Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            )
          : null),
      onTap: onTap,
    );
  }
}