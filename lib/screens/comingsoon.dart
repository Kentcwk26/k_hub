import 'package:flutter/material.dart';
import '../../utils/information.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Coming Soon")),
      body: Center(
        child: IconTextWidget(
          icon: Icons.on_device_training,
          text: 'Coming Soon !',
          iconColor: Colors.grey,
          textColor: Colors.grey,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          mainAxisAlignment: MainAxisAlignment.center,
          padding: const EdgeInsets.all(16),
        )
      ),
    );
  }
}