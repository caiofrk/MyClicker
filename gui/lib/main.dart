import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
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
  Map<String, dynamic>? selectedMacro;
  List<String> logs = ['App initialized.', 'Waiting for connection...'];

  final List<Map<String, dynamic>> availableMacros = [
    {
      'name': 'Open Settings & Display',
      'steps': [
        {'action': 'launch_app', 'package_name': 'com.android.settings'},
        {'action': 'sleep', 'duration': 2},
        {'action': 'click_text', 'text': 'Display'},
      ],
    }
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

  Future<void> runMacro() async {
    if (!isConnected) {
      addLog('Error: Please connect to a device first.');
      return;
    }
    if (selectedMacro == null) {
      addLog('Error: No macro selected.');
      return;
    }
    addLog('Queueing macro: ${selectedMacro!['name']} to Supabase...');
    
    try {
      await Supabase.instance.client.from('tasks').insert({
        'action': 'run_macro',
        'target': selectedMacro!['steps'],
        'status': 'pending',
      });
      addLog('Macro successfully queued! The Python bot will execute it.');
    } catch (e) {
      addLog('Error queuing macro: $e');
    }
  }

  void _openMacroBuilder({Map<String, dynamic>? existingMacro, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MacroBuilderScreen(macro: existingMacro)),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (index != null) {
          availableMacros[index] = result;
          if (selectedMacro != null && selectedMacro!['name'] == existingMacro?['name']) {
            selectedMacro = result;
          }
          addLog('Macro updated: ${result['name']}');
        } else {
          availableMacros.add(result);
          addLog('New macro created: ${result['name']}');
        }
      });
    }
  }

  void _deleteMacro(int index) {
    setState(() {
      final macroName = availableMacros[index]['name'];
      if (selectedMacro != null && selectedMacro!['name'] == macroName) {
        selectedMacro = null;
      }
      availableMacros.removeAt(index);
      addLog('Macro deleted: $macroName');
    });
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
                            onPressed: () => _openMacroBuilder(),
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
                            final isSelected = selectedMacro != null && macro['name'] == selectedMacro!['name'];
                            return ListTile(
                              title: Text(macro['name']),
                              subtitle: Text('${(macro['steps'] as List).length} steps'),
                              leading: Icon(Icons.play_circle_outline, 
                                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey),
                              selected: isSelected,
                              selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.grey),
                                    onPressed: () => _openMacroBuilder(existingMacro: macro, index: index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _deleteMacro(index),
                                  ),
                                ],
                              ),
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
  final Map<String, dynamic>? macro;
  const MacroBuilderScreen({super.key, this.macro});

  @override
  State<MacroBuilderScreen> createState() => _MacroBuilderScreenState();
}

class _MacroBuilderScreenState extends State<MacroBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, dynamic>> _steps = [];

  @override
  void initState() {
    super.initState();
    if (widget.macro != null) {
      _nameController.text = widget.macro!['name'];
      _steps.addAll(List<Map<String, dynamic>>.from(widget.macro!['steps'].map((step) => Map<String, dynamic>.from(step))));
    }
  }

  void _promptForStepDetails(String type) async {
    if (type == 'launch_app') {
      final selectedAppPackage = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppSelectorScreen()),
      );
      if (selectedAppPackage != null && selectedAppPackage is String) {
        setState(() {
          _steps.add({'action': 'launch_app', 'package_name': selectedAppPackage});
        });
      }
      return;
    }

    if (type == 'type_desc') {
      final descController = TextEditingController();
      final textController = TextEditingController();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Type Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Field Description')),
              TextField(controller: textController, decoration: const InputDecoration(labelText: 'Text to type')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _steps.add({'action': 'type_desc', 'field_description': descController.text, 'input_text': textController.text});
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
      return;
    }

    String title = '';
    String label = '';
    TextInputType keyboardType = TextInputType.text;

    if (type == 'click_text') {
      title = 'Click Text';
      label = 'Exact text to click';
    } else if (type == 'sleep') {
      title = 'Sleep (Wait)';
      label = 'Seconds';
      keyboardType = TextInputType.number;
    }

    final valController = TextEditingController();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: valController,
          decoration: InputDecoration(labelText: label),
          keyboardType: keyboardType,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final val = valController.text;
                if (type == 'click_text') _steps.add({'action': 'click_text', 'text': val});
                else if (type == 'sleep') _steps.add({'action': 'sleep', 'duration': int.tryParse(val) ?? 1});
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                onTap: () { Navigator.pop(context); _promptForStepDetails('launch_app'); },
              ),
              ListTile(
                leading: const Icon(Icons.touch_app),
                title: const Text('Click Text'),
                onTap: () { Navigator.pop(context); _promptForStepDetails('click_text'); },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard),
                title: const Text('Type Text'),
                onTap: () { Navigator.pop(context); _promptForStepDetails('type_desc'); },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Sleep (Wait)'),
                onTap: () { Navigator.pop(context); _promptForStepDetails('sleep'); },
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
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'steps': _steps,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.macro == null ? 'Create Macro' : 'Edit Macro'),
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

class AppSelectorScreen extends StatefulWidget {
  const AppSelectorScreen({super.key});

  @override
  State<AppSelectorScreen> createState() => _AppSelectorScreenState();
}

class _AppSelectorScreenState extends State<AppSelectorScreen> {
  List<AppInfo> apps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    List<AppInfo> installedApps = await InstalledApps.getInstalledApps(excludeSystemApps: true, withIcon: true);
    // Sort alphabetically by name
    installedApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      apps = installedApps;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select an App to Launch'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return ListTile(
                  leading: app.icon != null
                      ? Image.memory(app.icon!, width: 40, height: 40)
                      : const Icon(Icons.android, size: 40),
                  title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(app.packageName),
                  onTap: () {
                    // Return the package name
                    Navigator.pop(context, app.packageName);
                  },
                );
              },
            ),
    );
  }
}
