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

  // Temporary mock data. Later, we'll fetch this from Supabase!
  final List<String> availableMacros = [
    'Open Settings & Display',
    'Clear App Cache',
    'Send Test Message',
    'Daily Login Reward',
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
    
    // Simulate connection delay for now
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        addLog('Connected to Android Emulator successfully.');
      }
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
    
    // Simulate macro running time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        addLog('Macro "$selectedMacro" finished executing.');
      }
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
                      const Text('Available Macros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
