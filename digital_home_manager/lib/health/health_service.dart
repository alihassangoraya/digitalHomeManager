import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../deadlines/deadlines_service.dart';

class HealthAnalytics {
  final int overdueCount;
  final int upcomingCount;
  final List<String> recommendations;
  final List<String> risks;
  final List<String> history;

  const HealthAnalytics({
    required this.overdueCount,
    required this.upcomingCount,
    required this.recommendations,
    required this.risks,
    required this.history,
  });
}

class HealthService {
  static final _user = FirebaseAuth.instance.currentUser!;
  static final _fs = FirebaseFirestore.instance;

  /// Returns health analytics based on deadlines and service history.
  static Future<HealthAnalytics> getAnalytics() async {
    final dlSnap = await _fs
        .collection('users')
        .doc(_user.uid)
        .collection('deadlines')
        .get();

    final serviceSnap = await _fs
        .collection('users')
        .doc(_user.uid)
        .collection('services')
        .orderBy('created', descending: true)
        .get();

    final now = DateTime.now();
    int overdueCount = 0;
    int upcomingCount = 0;
    List<String> recommendations = [];
    List<String> risks = [];
    List<String> history = [];

    for (var doc in dlSnap.docs) {
      final deadline = Deadline.fromDoc(doc);
      if (!deadline.completed) {
        if (deadline.due.isBefore(now)) {
          overdueCount++;
          risks.add('Missed: ${deadline.label} was due on ${_dateFmt(deadline.due)}');
        } else if (deadline.due.difference(now).inDays <= 30) {
          upcomingCount++;
          recommendations.add('Upcoming: ${deadline.label} due soon (${_dateFmt(deadline.due)})');
        }
      }
      if (deadline.completed) {
        history.add('Completed ${deadline.label} on ${_dateFmt(deadline.due)}');
      }
    }
    for (var doc in serviceSnap.docs) {
      final data = doc.data();
      final label = data['label'] ?? 'Service';
      final status = data['status'] ?? 'completed';
      final date = data['date'] != null ? DateTime.parse(data['date']) : null;
      if (status == 'completed' && date != null) {
        history.add('Service: $label completed on ${_dateFmt(date)}');
      }
      if (status == 'pending') {
        recommendations.add('Follow up pending service order: $label');
      }
    }
    if (overdueCount > 0) {
      risks.add('Risk: Property value or insurance at risk due to overdue inspections/services.');
    }
    if (overdueCount == 0 && upcomingCount == 0) {
      recommendations.add('All checks up to date. Great maintenance!');
    }

    return HealthAnalytics(
      overdueCount: overdueCount,
      upcomingCount: upcomingCount,
      recommendations: recommendations,
      risks: risks,
      history: history,
    );
  }

  static String _dateFmt(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
