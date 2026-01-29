import 'package:flutter/foundation.dart';

String getPlatformInfo() {
  if (kIsWeb) {
    return 'Web Platform';
  }
  
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'Android';
    case TargetPlatform.iOS:
      return 'iOS';
    case TargetPlatform.windows:
      return 'Windows';
    case TargetPlatform.linux:
      return 'Linux';
    case TargetPlatform.macOS:
      return 'macOS';
    case TargetPlatform.fuchsia:
      return 'Fuchsia';
  }
}

bool isGoogleMapsSupported() {
  if (kIsWeb) {
    return true; 
  }
  
  return defaultTargetPlatform == TargetPlatform.android ||
         defaultTargetPlatform == TargetPlatform.iOS ||
         defaultTargetPlatform == TargetPlatform.macOS || 
         defaultTargetPlatform == TargetPlatform.linux || 
         defaultTargetPlatform == TargetPlatform.windows; 
}