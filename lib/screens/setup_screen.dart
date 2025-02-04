import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:Left/homepage.dart';
import 'package:Left/models/user_data.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  DateTime? selectedBirthday;
  final TextEditingController _lifespanController = TextEditingController();
  final List<ImportantDate> importantDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        actions: [
          TextButton(
            onPressed: _saveAndContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(height: 24, color: Colors.grey[500]),
          // Birthday selector
          ListTile(
            title: const Text('Your birthday (optional)'),
            subtitle: Text(
              selectedBirthday != null
                  ? DateFormat('MMM d, y').format(selectedBirthday!)
                  : 'Not set',
            ),
            onTap: () => _selectBirthday(context),
          ),
          const SizedBox(height: 16),
          // Expected lifespan input
          TextField(
            controller: _lifespanController,
            decoration: const InputDecoration(
              labelText: 'Expected lifespan (optional)',
              hintText: 'Enter in years',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          // Important dates section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Important dates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _addImportantDate(context),
                child: const Text('Add date'),
              ),
            ],
          ),
          ...importantDates.map((date) => ListTile(
                title: Text(date.title),
                subtitle: Text(DateFormat('MMM d').format(date.date)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      importantDates.remove(date);
                    });
                  },
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedBirthday = picked;
      });
    }
  }

  Future<void> _addImportantDate(BuildContext context) async {
    final titleController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add important date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Anniversary',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                selectedDate != null
                    ? DateFormat('MMM d').format(selectedDate!)
                    : 'Select date',
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDate = DateTime(
                    DateTime.now().year,
                    picked.month,
                    picked.day,
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedDate != null) {
                setState(() {
                  importantDates.add(ImportantDate(
                    title: titleController.text,
                    date: selectedDate!,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveAndContinue() async {
    final userData = UserData(
      birthday: selectedBirthday,
      expectedLifespan: int.tryParse(_lifespanController.text),
      importantDates: importantDates,
    );

    final box = await Hive.openBox<UserData>('userData');
    await box.put('user', userData);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}
