import 'package:flutter/material.dart';
import 'package:postgram/utils/theme.dart';

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Firebase Setup Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Postgram is live, but it needs to be linked to your Firebase project to enable Login and Cloud features.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SelectableText(
                  'flutterfire configure',
                  style: TextStyle(fontFamily: 'Courier', color: blueColor),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Run the command above in your project terminal and rebuild to complete the setup.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
