import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

void main() {
  runApp(const ClaudeMobileApp());
}

class ClaudeMobileApp extends StatefulWidget {
  const ClaudeMobileApp({super.key});

  @override
  State<ClaudeMobileApp> createState() => _ClaudeMobileAppState();
}

class _ClaudeMobileAppState extends State<ClaudeMobileApp> {
  ThemeMode themeMode = ThemeMode.dark;
  String selectedModel = 'meta/llama-3.3-70b-instruct';

  final List<String> models = [
    'meta/llama-3.3-70b-instruct',
    'qwen/qwen3-coder-480b-a35b-instruct',
    'deepseek-ai/deepseek-r1',
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      themeMode =
          prefs.getBool('darkMode') ?? true ? ThemeMode.dark : ThemeMode.light;
      selectedModel = prefs.getString('model') ?? models.first;
    });
  }

  Future<void> toggleTheme(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', dark);
    setState(() {
      themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> selectModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model', model);
    setState(() {
      selectedModel = model;
    });
  }

  Future<void> runTermuxCommand(String command) async {
    final intent = AndroidIntent(
      action: 'com.termux.RUN_COMMAND',
      package: 'com.termux',
      componentName: 'com.termux/com.termux.app.RunCommandService',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: <String, dynamic>{
        'com.termux.RUN_COMMAND_PATH':
            '/data/data/com.termux/files/usr/bin/bash',
        'com.termux.RUN_COMMAND_ARGUMENTS': <String>[
          '-lc',
          'source ~/.bashrc; $command'
        ],
        'com.termux.RUN_COMMAND_WORKDIR':
            '/data/data/com.termux/files/home',
        'com.termux.RUN_COMMAND_BACKGROUND': true,
      },
    );

    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;

    return MaterialApp(
      title: 'Claude Code Mobile',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD97757),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD97757),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Claude Code Mobile'),
          actions: [
            IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => toggleTheme(!isDark),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NVIDIA NIM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Selected model:\n$selectedModel'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Choose model'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: models.map((model) {
                  final selected = model == selectedModel;
                  return ChoiceChip(
                    label: Text(model.split('/').last),
                    selected: selected,
                    onSelected: (_) => selectModel(model),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start CCR'),
                  onPressed: () => runTermuxCommand('ccr start'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.terminal),
                  label: const Text('Open Claude Code'),
                  onPressed: () => runTermuxCommand(
                    'ccr code -- --model $selectedModel',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop CCR'),
                  onPressed: () => runTermuxCommand('ccr stop'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
