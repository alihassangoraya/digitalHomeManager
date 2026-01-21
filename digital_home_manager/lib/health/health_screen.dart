import 'package:flutter/material.dart';

import 'health_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late Future<HealthAnalytics> _analytics;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _analytics = HealthService.getAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refresh();
        await _analytics;
      },
      child: FutureBuilder<HealthAnalytics>(
        future: _analytics,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final analytics = snapshot.data!;
          return Container(
            color: Colors.grey[100],
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety, color: Colors.green, size: 32,),
                    const SizedBox(width: 10),
                    Text('Home Health Analytics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 19, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Summary", style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _chip(
                              label: "Overdue: ${analytics.overdueCount}",
                              color: analytics.overdueCount > 0 ? Colors.red : Colors.grey[300]!,
                            ),
                            const SizedBox(width: 6),
                            _chip(
                              label: "Upcoming: ${analytics.upcomingCount}",
                              color: analytics.upcomingCount > 0 ? Colors.orange : Colors.grey[300]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (analytics.risks.isNotEmpty)
                  Card(
                    color: Colors.red[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: _tile('Risks & Alerts', analytics.risks, color: Colors.red),
                    ),
                  ),
                if (analytics.recommendations.isNotEmpty)
                  Card(
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: _tile('Recommendations', analytics.recommendations, color: Colors.green),
                    ),
                  ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: _tile(
                      'Service & Check History',
                      analytics.history,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-analyze health'),
                    onPressed: _refresh,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _tile(String title, List<String> lines, {Color? color}) {
    if (lines.isEmpty) return const SizedBox();
    return Card(
      color: color?.withOpacity(0.09),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            ...lines.map((line) => Text(
                  line,
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}
