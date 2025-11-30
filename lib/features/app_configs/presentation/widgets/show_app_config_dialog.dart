import 'package:coexist_app_portal/features/app_configs/domain/model/app_config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showAppConfigDialog(
  BuildContext context,
  AppConfigModel config,
  VoidCallback? onDismiss,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false, // Prevent back button dismissal
        child: AlertDialog(
          title: config.title != null
              ? Text(
                  config.title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          content: config.message != null
              ? Text(config.message!, style: const TextStyle(fontSize: 16))
              : null,
          actions: [
            if (config.buttonText != null || config.buttonText!.isNotEmpty)
              TextButton(
                onPressed: () {
                  if (config.buttonAction == 'exit_app') {
                    // Exit the app
                    SystemNavigator.pop();
                  } else {
                    // Normal dismiss behavior
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  }
                },
                child: Text(
                  config.buttonText ?? 'OK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    },
  );
}
