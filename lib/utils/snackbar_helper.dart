import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration? duration,
    IconData? icon,
  }) {
    final colors = {
      SnackbarType.success: AppColors.success,
      SnackbarType.error: AppColors.error,
      SnackbarType.warning: AppColors.warning,
      SnackbarType.info: AppColors.info,
    };

    final icons = {
      SnackbarType.success: Icons.check_circle,
      SnackbarType.error: Icons.error,
      SnackbarType.warning: Icons.warning,
      SnackbarType.info: Icons.info,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? icons[type],
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors[type],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration ?? const Duration(seconds: 3),
        animation: kThemeAnimationDuration,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.error, duration: Duration(seconds: 4));

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.warning);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackbarType.info);
}