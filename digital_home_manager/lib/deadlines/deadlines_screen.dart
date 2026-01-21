import 'package:flutter/material.dart';

import 'deadlines_service.dart';

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  final _labelController = TextEditingController();
  DateTime? _selectedDue;

  void _showAddDialog() {
    _labelController.clear();
    _selectedDue = null;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Deadline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDue = picked);
                }
              },
              child: Text(_selectedDue == null
                  ? 'Select Due Date'
                  : 'Due: ${_selectedDue!.toLocal().toString().split(' ')[0]}'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              if (_labelController.text.isNotEmpty && _selectedDue != null) {
                await DeadlinesService.addDeadline(_labelController.text, _selectedDue!);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Add Deadline',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Deadline>>(
        stream: DeadlinesService.deadlinesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final deadlines = snapshot.data!;
          if (deadlines.isEmpty) {
            return const Center(child: Text('No deadlines yet. Add one!'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: deadlines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = deadlines[i];
              return ListTile(
                tileColor: d.completed ? Colors.green[50] : Colors.orange[50],
                leading: Icon(
                  d.completed ? Icons.check_circle : Icons.schedule,
                  color: d.completed ? Colors.green : Colors.orange,
                ),
                title: Text(
                  d.label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          d.completed ? TextDecoration.lineThrough : null),
                ),
                subtitle: Text('Due: ${d.due.toLocal().toString().split(' ')[0]}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: Icon(
                            d.completed ? Icons.undo : Icons.check,
                            color: Colors.teal),
                        tooltip: d.completed ? 'Mark as incomplete' : 'Mark complete',
                        onPressed: () {
                          DeadlinesService.updateDeadline(d.id, completed: !d.completed);
                        }),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () {
                          DeadlinesService.deleteDeadline(d.id);
                        }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
