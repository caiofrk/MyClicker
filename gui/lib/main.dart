import 'package:flutter/material.dart';

void main() {
  runApp(const MyClickerApp());
}

class MyClickerApp extends StatelessWidget {
  const MyClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyClicker Macro Bot',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.tealAccent,
          surface: Color(0xFF1E1E2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF12121A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isConnected = false;
  String? selectedMacro;
  List<String> logs = ['App initialized.', 'Waiting for connection...'];

  final List<String> availableMacros = [
    'Open Settings & Display',
  ];

  void addLog(String message) {
    setState(() {
      logs.insert(0, '[${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}] $message');
    });
  }

  void connectDevice() {
    setState(() {
      isConnected = true;
    });
    addLog('Connecting to device...');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) addLog('Connected to Android Emulator successfully.');
    });
  }

  void runMacro() {
    if (!isConnected) {
      addLog('Error: Please connect to a device first.');
      return;
    }
    if (selectedMacro == null) {
      addLog('Error: No macro selected.');
      return;
    }
    addLog('Starting macro: $selectedMacro...');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) addLog('Macro "$selectedMacro" finished executing.');
    });
  }

  void _openMacroBuilder() async {
    final newMacroName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MacroBuilderScreen()),
    );
    if (newMacroName != null && newMacroName is String) {
      setState(() {
        availableMacros.add(newMacroName);
      });
      addLog('New macro created: $newMacroName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyClicker Control Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.circle,
              color: isConnected ? Colors.greenAccent : Colors.redAccent,
              size: 16,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Connection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Device Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            color: isConnected ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: isConnected ? null : connectDevice,
                      icon: const Icon(Icons.usb),
                      label: Text(isConnected ? 'Connected' : 'Connect Device'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Macros Card
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Macros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.tealAccent, size: 28),
                            onPressed: _openMacroBuilder,
                            tooltip: 'Create New Macro',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: availableMacros.length,
                          itemBuilder: (context, index) {
                            final macro = availableMacros[index];
                            final isSelected = macro == selectedMacro;
                            return ListTile(
                              title: Text(macro),
                              leading: Icon(Icons.play_circle_outline, 
                                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey),
                              selected: isSelected,
                              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onTap: () {
                                setState(() {
                                  selectedMacro = macro;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: runMacro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('RUN MACRO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Live Log Window
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Live Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10)
                          ),
                          child: ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  logs[index],
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.greenAccent),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MacroBuilderScreen extends StatefulWidget {
  const MacroBuilderScreen({super.key});

  @override
  State<MacroBuilderScreen> createState() => _MacroBuilderScreenState();
}

class _MacroBuilderScreenState extends State<MacroBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, dynamic>> _steps = [];

  void _addStep(String type) {
    setState(() {
      if (type == 'launch_app') {
        _steps.add({'action': 'launch_app', 'package_name': 'com.example.app'});
      } else if (type == 'click_text') {
        _steps.add({'action': 'click_text', 'text': 'Button Name'});
      } else if (type == 'type_desc') {
        _steps.add({'action': 'type_desc', 'field_description': 'Search', 'input_text': 'Text'});
      } else if (type == 'sleep') {
        _steps.add({'action': 'sleep', 'duration': 2});
      }
    });
  }

  void _showAddStepDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.launch),
                title: const Text('Launch App'),
                onTap: () { Navigator.pop(context); _addStep('launch_app'); },
              ),
              ListTile(
                leading: const Icon(Icons.touch_app),
                title: const Text('Click Text'),
                onTap: () { Navigator.pop(context); _addStep('click_text'); },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard),
                title: const Text('Type Text'),
                onTap: () { Navigator.pop(context); _addStep('type_desc'); },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Sleep (Wait)'),
                onTap: () { Navigator.pop(context); _addStep('sleep'); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveMacro() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a macro name')));
      return;
    }
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one step')));
      return;
    }
    // Return the name so the dashboard can display it
    Navigator.pop(context, _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.tealAccent),
            onPressed: _saveMacro,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Macro Name',
                border: OutlineInputBorder(),
                filled: true,
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _steps.isEmpty
                  ? const Center(child: Text('No steps added yet. Tap + to add a step.'))
                  : ListView.builder(
                      itemCount: _steps.length,
                      itemBuilder: (context, index) {
                        final step = _steps[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(step['action'].toString().toUpperCase()),
                            subtitle: Text(step.toString()),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _steps.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStepDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Step'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.black,
      ),
    );
  }
}
