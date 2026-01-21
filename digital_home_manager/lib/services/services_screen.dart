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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _booking ? null : () => _showBookDialog(providers),
            icon: _booking
                ? const CircularProgressIndicator()
                : const Icon(Icons.handyman),
            label: const Text("Book Service"),
            backgroundColor: Colors.purple,
          ),
          body: Container(
            color: Colors.grey[100],
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 18),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.handyman, color: Colors.purple, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        'Services & History',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<List<ServiceJob>>(
                    stream: ServicesService.jobsStream(),
                    builder: (context, jobSnap) {
                      if (!jobSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final jobs = jobSnap.data!;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: jobs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.history, size: 44, color: Colors.purple),
                                      SizedBox(height: 13),
                                      Text("No booked services yet. Tap 'Book Service' to request help.", textAlign: TextAlign.center),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: jobs.length,
                                  separatorBuilder: (_, __) => const Divider(height: 18),
                                  itemBuilder: (context, i) {
                                    final job = jobs[i];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: job.status == 'completed' ? Colors.green[100] : Colors.purple[50],
                                        foregroundColor: job.status == 'completed' ? Colors.green[900] : Colors.purple[900],
                                        child: Icon(
                                          job.status == 'completed'
                                              ? Icons.check_circle
                                              : Icons.miscellaneous_services,
                                          size: 22,
                                        ),
                                      ),
                                      title: Text(
                                        job.label,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: job.status == 'completed' ? Colors.green[900] : Colors.purple[900]),
                                      ),
                                      subtitle: Text(
                                        "By: ${job.providerName}\n${job.created.toLocal().toString().split(' ')[0]}",
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                      ),
                                      trailing: job.status == 'pending'
                                          ? ElevatedButton.icon(
                                              icon: const Icon(Icons.done),
                                              label: const Text('Complete'),
                                              onPressed: () => ServicesService.completeJob(job.id),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            )
                                          : const Icon(Icons.verified, color: Colors.green),
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Verified Providers',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepPurple)),
                          const SizedBox(height: 10),
                          ...providers.map((p) => ListTile(
                                leading: Icon(Icons.business_center, color: Colors.deepPurple[800], size: 28),
                                title: Text('${p.name} — ${p.specialty}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Phone: ${p.phone}\nEmail: ${p.email}', style: const TextStyle(fontSize: 13)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
