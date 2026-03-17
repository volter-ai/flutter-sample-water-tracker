import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/water_entry.dart';
import '../services/storage_service.dart';

class WaterTrackerProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  int _dailyGoal = 2000;
  int _currentIntake = 0;
  List<WaterEntry> _entries = [];
  bool _isLoading = true;

  int get dailyGoal => _dailyGoal;
  int get currentIntake => _currentIntake;
  List<WaterEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  double get progressPercentage {
    if (_dailyGoal == 0) return 0;
    return (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
  }

  WaterTrackerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _dailyGoal = await _storage.getDailyGoal();
    _entries = await _storage.getTodayEntries();
    _currentIntake = _entries.fold(0, (sum, entry) => sum + entry.amount);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWater(int amount) async {
    final entry = WaterEntry(
      amount: amount,
      timestamp: DateTime.now(),
    );

    _entries.add(entry);
    _currentIntake += amount;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _storage.saveEntries(_entries, today);
    await _storage.saveWaterIntake(_currentIntake, today);

    notifyListeners();
  }

  Future<void> removeEntry(int index) async {
    if (index < 0 || index >= _entries.length) return;

    final entry = _entries[index];
    _entries.removeAt(index);
    _currentIntake -= entry.amount;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _storage.saveEntries(_entries, today);
    await _storage.saveWaterIntake(_currentIntake, today);

    notifyListeners();
  }

  Future<void> updateDailyGoal(int newGoal) async {
    _dailyGoal = newGoal;
    await _storage.saveDailyGoal(newGoal);
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _showCustomAmountDialog(BuildContext context) async {
    final controller = TextEditingController();
    final provider = Provider.of<WaterTrackerProvider>(context, listen: false);

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      await provider.addWater(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WaterTrackerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Circle
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: provider.progressPercentage,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${provider.currentIntake}',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ml',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(provider.progressPercentage * 100).toInt()}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Goal Text
                Center(
                  child: Text(
                    'Goal: ${provider.dailyGoal} ml',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Quick Add Buttons
                const Text(
                  'Quick Add',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => provider.addWater(250),
                        child: const Text('250 ml'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => provider.addWater(500),
                        child: const Text('500 ml'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => provider.addWater(750),
                        child: const Text('750 ml'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => _showCustomAmountDialog(context),
                        child: const Text('Custom'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Entries List
                const Text(
                  'Today\'s Entries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.entries.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No water logged yet today',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.entries[provider.entries.length - 1 - index];
                      final reversedIndex = provider.entries.length - 1 - index;
                      final timeFormat = DateFormat('h:mm a');

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.water_drop, color: Colors.blue),
                          title: Text('${entry.amount} ml'),
                          subtitle: Text(timeFormat.format(entry.timestamp)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => provider.removeEntry(reversedIndex),
                            tooltip: 'Remove',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
