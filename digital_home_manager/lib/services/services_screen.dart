import 'package:flutter/material.dart';

import 'services_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _booking = false;

  Future<void> _showBookDialog(List<ServiceProvider> providers) async {
    String? _selectedId;
    final labelController = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Book New Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedId,
                items: providers
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} — ${p.specialty}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedId = v),
                decoration: const InputDecoration(labelText: 'Provider'),
                isExpanded: true,
                hint: const Text('Select a provider'),
              ),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Service Requested (e.g., Annual Boiler Check)'),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ]
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              child: const Text('Book'),
              onPressed: () async {
                if (_selectedId == null || labelController.text.isEmpty) {
                  setState(() => error = 'Select provider and enter service.');
                  return;
                }
                final provider = providers.firstWhere((p) => p.id == _selectedId);
                setState(() => _booking = true);
                await ServicesService.bookService(
                  providerId: provider.id,
                  providerName: provider.name,
                  label: labelController.text.trim(),
                );
                setState(() => _booking = false);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceProvider>>(
      future: ServicesService.getProviders(),
      builder: (context, provSnap) {
        if (!provSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final providers = provSnap.data!;
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: _booking
                ? null
                : () {
                    _showBookDialog(providers);
                  },
            tooltip: 'Book Service',
            child: _booking ? const CircularProgressIndicator() : const Icon(Icons.add_business),
          ),
          body: StreamBuilder<List<ServiceJob>>(
            stream: ServicesService.jobsStream(),
            builder: (context, jobSnap) {
              if (!jobSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final jobs = jobSnap.data!;
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Book Household Services', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 18),
                  if (jobs.isEmpty)
                    const Text("No current or past service jobs. Use '+' to book!"),
                  ...jobs.map((job) => Card(
                        color: job.status == 'completed'
                            ? Colors.green[50]
                            : Colors.yellow[50],
                        child: ListTile(
                          leading: Icon(
                            job.status == 'completed'
                                ? Icons.check_circle
                                : Icons.build,
                            color: job.status == 'completed'
                                ? Colors.green
                                : Colors.amber,
                          ),
                          title: Text(job.label),
                          subtitle: Text("By: ${job.providerName}\n${job.created.toLocal().toString().split(' ')[0]}"),
                          trailing: job.status == 'pending'
                              ? ElevatedButton.icon(
                                  icon: const Icon(Icons.done),
                                  label: const Text('Mark Complete'),
                                  onPressed: () => ServicesService.completeJob(job.id),
                                )
                              : null,
                        ),
                      )),
                  const SizedBox(height: 18),
                  Text('Available Providers', style: Theme.of(context).textTheme.titleLarge),
                  ...providers.map((p) => Card(
                        color: Colors.purple[25],
                        child: ListTile(
                          leading: const Icon(Icons.business_center, color: Colors.deepPurple),
                          title: Text('${p.name} — ${p.specialty}'),
                          subtitle: Text('Phone: ${p.phone}\nEmail: ${p.email}'),
                        ),
                      )),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
