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
  String selectedModel = 'meta/llama-3.3-70b-instruct';

  Future<void> runTermux(String command) async {
    final intent = AndroidIntent(
      action: 'com.termux.RUN_COMMAND',
      package: 'com.termux',
      componentName: 'com.termux/com.termux.app.RunCommandService',
      extras: <String, dynamic>{
        'com.termux.RUN_COMMAND_PATH': '/data/data/com.termux/files/usr/bin/bash',
        'com.termux.RUN_COMMAND_ARGUMENTS': <String>['-lc', command],
        'com.termux.RUN_COMMAND_WORKDIR': '/data/data/com.termux/files/home',
        'com.termux.RUN_COMMAND_BACKGROUND': true,
      },
    );

    try {
      await intent.launch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent: $command')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
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
            const SizedBox(height: 24),
            const Text('Selected model'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedModel,
              items: const [
                DropdownMenuItem(
                  value: 'meta/llama-3.3-70b-instruct',
                  child: Text('Llama 3.3 70B'),
                ),
                DropdownMenuItem(
                  value: 'qwen/qwen3-coder-480b-a35b-instruct',
                  child: Text('Qwen3 Coder'),
                ),
                DropdownMenuItem(
                  value: 'deepseek-ai/deepseek-r1',
                  child: Text('DeepSeek R1'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedModel = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
