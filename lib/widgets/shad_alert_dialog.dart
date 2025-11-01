import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A reusable Shadcn-style alert dialog for warnings or errors.
class ShadAlertDialog {
  static Future<void> showAlertDialogWarning(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return ShadDialog(
          // ✅ Safe Shadcn layout
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ Header row
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 📄 Message text
              Text(message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // ✅ Action button area
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton.destructive(
                  // ✅ Using Shadcn’s built-in destructive variant
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
