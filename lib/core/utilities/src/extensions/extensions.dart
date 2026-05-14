import '../../../../core/app_ui/app_ui.dart';

import 'package:flutter/foundation.dart';

enum PlatformType { android, ios, windows, linux, macos, fuchsia }

bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

bool get isMacOs => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

bool get isFuchsia => !kIsWeb && defaultTargetPlatform == TargetPlatform.fuchsia;

extension ColorOpacityExt on Color {
  Color withOAlpha(double opacity) {
    // opacity must be 0.0 to 1.0
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withValues(alpha: safeOpacity);
  }
}




// extension AppLinkLauncher on AppLinkModel {
//   Future<void> launch({bool forceStoreFallback = false}) async {
//     final Uri appUri = Uri.parse(appUrl);
//     final Uri storeUri = Uri.parse(storeUrl);
//     try {
//       if (!forceStoreFallback && await canLaunchUrl(appUri)) {
//         final success = await launchUrl(
//           appUri,
//           mode: LaunchMode.externalApplication,
//         );
//         if (success) return;
//       }
//     } on Exception catch (e) {
//       debugPrint("App launch failed: $e");
//     }
//
//     // fallback to store
//     if (await canLaunchUrl(storeUri)) {
//       await launchUrl(storeUri, mode: LaunchMode.externalApplication);
//     } else {
//       Exception('Could not launch app or store link.');
//     }
//   }
// }