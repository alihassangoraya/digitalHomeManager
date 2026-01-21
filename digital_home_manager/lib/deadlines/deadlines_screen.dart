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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        tooltip: 'Add Deadline',
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.deepOrange, size: 32),
                  const SizedBox(width: 10),
                  Text('Deadlines & Checks',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: StreamBuilder<List<Deadline>>(
                  stream: DeadlinesService.deadlinesStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final deadlines = snapshot.data!;
                    if (deadlines.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.hourglass_empty, size: 44, color: Colors.deepOrange),
                            SizedBox(height: 12),
                            Text('No deadlines yet. Tap + to add your first required task.', textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(22.0),
                      itemCount: deadlines.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final d = deadlines[i];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: d.completed ? Colors.green[50] : Colors.white,
                            border: Border.all(
                              color: d.completed ? Colors.green[200]! : Colors.deepOrange[100]!,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: ListTile(
                            leading: Icon(
                              d.completed ? Icons.check_circle : Icons.schedule,
                              color: d.completed ? Colors.green : Colors.deepOrange,
                              size: 32,
                            ),
                            title: Text(
                              d.label,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  decoration: d.completed ? TextDecoration.lineThrough : null),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text(
                                  'Due: ${d.due.toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                if (d.completed)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 2,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    d.completed ? Icons.undo : Icons.check,
                                    color: Colors.teal,
                                  ),
                                  tooltip: d.completed ? 'Mark as incomplete' : 'Mark complete',
                                  onPressed: () => DeadlinesService.updateDeadline(d.id, completed: !d.completed),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: 'Delete',
                                  onPressed: () => DeadlinesService.deleteDeadline(d.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
