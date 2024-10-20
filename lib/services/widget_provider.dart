import 'package:flutter/services.dart';

class WidgetProviderService {
  static const platform = MethodChannel('com.example.untitled5/widget');

  // Call to update widget with the new quote
  Future<void> updateWidget(String quote) async {
    try {
      await platform.invokeMethod('updateWidget', {'quote': quote});
    } on PlatformException catch (e) {
      print("Failed to update widget: ${e.message}");
    }
  }
}
