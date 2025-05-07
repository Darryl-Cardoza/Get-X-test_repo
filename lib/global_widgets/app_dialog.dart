// lib/global_widgets/app_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Types of dialog to indicate context: informational, success, or error.
enum AppDialogType { info, success, error }

/// A customizable modal dialog with header icon, title, message, and actions.
///
/// Usage:
/// ```dart
/// await AppDialog.show(
///   title: 'Error',
///   message: 'Something went wrong.',
///   type: AppDialogType.error,
///   confirmText: 'Retry',
///   onConfirm: () => doRetry(),
/// );
/// ```
class AppDialog extends StatelessWidget {
  /// Title text displayed at the top of the dialog.
  final String title;

  /// Main message/body of the dialog. Can scroll if too long.
  final String message;

  /// Label for the primary action button (default: 'OK').
  final String confirmText;

  /// Callback invoked when primary action is pressed.
  final VoidCallback? onConfirm;

  /// Optional label for secondary/cancel action button.
  final String? cancelText;

  /// Callback invoked when secondary action is pressed.
  final VoidCallback? onCancel;

  /// Dialog style type: info, success, or error.
  final AppDialogType type;

  // Colors for default styling
  static const Color _primaryColor = Color(0xFF205072);
  static const Color _secondaryColor = Color(0xFF2C6975);

  const AppDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'OK',
    this.onConfirm,
    this.cancelText,
    this.onCancel,
    this.type = AppDialogType.info,
  }) : super(key: key);

  /// Displays the dialog using Get.dialog and returns a Future<T?>.
  ///
  /// Parameters:
  /// - [title]: header title
  /// - [message]: body content
  /// - [confirmText]: primary button label
  /// - [onConfirm]: primary button callback
  /// - [cancelText]: optional secondary button label
  /// - [onCancel]: secondary button callback
  /// - [type]: style variant
  static Future<T?> show<T>({
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    AppDialogType type = AppDialogType.info,
  }) {
    return Get.dialog<T>(
      AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        cancelText: cancelText,
        onCancel: onCancel,
        type: type,
      ),
      barrierDismissible: false, // user must tap a button
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if current theme is dark to adjust background
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pick header color and icon based on dialog type
    late final Color headerColor;
    late final IconData iconData;

    switch (type) {
      case AppDialogType.success:
        headerColor = Colors.green.shade600;
        iconData = Icons.check_circle_outline;
        break;
      case AppDialogType.error:
        headerColor = Colors.red.shade600;
        iconData = Icons.error_outline;
        break;
      case AppDialogType.info:
        headerColor = _secondaryColor;
        iconData = Icons.info_outline;
        break;
    }

    return Dialog(
      // Dialog styling
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER: Colored banner with icon
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(iconData, size: 48, color: Colors.white),
            ),
            // BODY: Title and scrollable message
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                children: [
                  // Title text
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message content, scrolls if too long
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ACTIONS: Cancel and Confirm buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cancelText != null) ...[
                    TextButton(
                      onPressed: () {
                        Get.back();
                        onCancel?.call();
                      },
                      child: Text(
                        cancelText!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    onPressed: () {
                      Get.back();
                      onConfirm?.call();
                    },
                    child: Text(
                      confirmText,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
