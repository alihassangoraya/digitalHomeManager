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
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text('Home Health Overview', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              if (analytics.risks.isNotEmpty) ...[
                _tile('Risks & Alerts', analytics.risks, color: Colors.red),
                const SizedBox(height: 12),
              ],
              if (analytics.recommendations.isNotEmpty) ...[
                _tile('Recommendations', analytics.recommendations, color: Colors.green),
                const SizedBox(height: 12),
              ],
              _tile(
                'Overview',
                [
                  if (analytics.overdueCount > 0)
                    '${analytics.overdueCount} overdue inspections/services',
                  if (analytics.upcomingCount > 0)
                    '${analytics.upcomingCount} upcoming due within 30 days',
                  if (analytics.overdueCount + analytics.upcomingCount == 0)
                    'All checked, up to date!',
                ],
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _tile('History', analytics.history, color: Colors.grey),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Re-analyze health'),
                onPressed: _refresh,
              ),
            ],
          );
        },
      ),
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
