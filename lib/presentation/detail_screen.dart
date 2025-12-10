import 'package:flutter/material.dart';
import 'package:flutter_module/main.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Detail'),leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _dismissFlutterModule,
        )),body: Center(child: Text("DetailScreen")));
  }

  Future<void> _dismissFlutterModule() async {
    try {
      await sendChannel.invokeMethod('dismissFlutterModule');
    } catch (e) {
      debugPrint('Error dismissing Flutter module: $e');
    }
  }
}
