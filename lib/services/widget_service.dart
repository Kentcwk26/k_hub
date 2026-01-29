import 'dart:async';
import 'package:flutter/services.dart';

class WidgetExportService {
  static const MethodChannel _channel = MethodChannel('kverse/widget');

  static Future<bool> updateKVerseWidget({
    required String wallpaperUrl,
    required String text,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('updateWidget', {
        'wallpaperUrl': wallpaperUrl,
        'text': text,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('PlatformException updating widget: $e');
      return false;
    } catch (e) {
      print('Unknown error updating widget: $e');
      return false;
    }
  }
}