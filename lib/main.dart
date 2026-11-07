import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';

void main() {
  runApp(const ClaudeMobileApp());
}

class ClaudeMobileApp extends StatelessWidget {
  const ClaudeMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Claude Code Mobile',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = 'Ready';

  Future<void> runTermux(String command) async {
    setState(() => status = 'Sending: $command');

    final intent = AndroidIntent(
      action: 'com.termux.RUN_COMMAND',
      package: 'com.termux',
      componentName: 'com.termux.app.RunCommandService',
      arguments: <String, dynamic>{
        'com.termux.RUN_COMMAND_PATH': '/data/data/com.termux/files/usr/bin/bash',
        'com.termux.RUN_COMMAND_ARGUMENTS': <String>['-lc', command],
        'com.termux.RUN_COMMAND_WORKDIR': '/data/data/com.termux/files/home',
        'com.termux.RUN_COMMAND_BACKGROUND': true,
      },
    );

    try {
      await intent.launch();
      setState(() => status = 'Sent successfully: $command');
    } catch (e) {
      setState(() => status = 'FAILED: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Claude Code Mobile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(status),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => runTermux('echo test-ok > ~/claude-mobile-test.txt'),
              child: const Text('Test Termux'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => runTermux('ccr start'),
              child: const Text('Start CCR'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => runTermux('ccr code'),
              child: const Text('Open Claude Code'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => runTermux('ccr stop'),
              child: const Text('Stop CCR'),
            ),
          ],
        ),
      ),
    );
  }
}
