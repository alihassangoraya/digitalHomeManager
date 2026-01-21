import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String specialty;
  final String phone;
  final String email;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.specialty,
    required this.phone,
    required this.email,
  });

  factory ServiceProvider.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ServiceProvider(
      id: doc.id,
      name: d['name'] ?? '',
      specialty: d['specialty'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
    );
  }
}

class ServiceJob {
  final String id;
  final String providerId;
  final String providerName;
  final String label;
  final DateTime created;
  final String status;

  ServiceJob({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.label,
    required this.created,
    required this.status,
  });

  factory ServiceJob.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ServiceJob(
      id: doc.id,
      providerId: d['providerId'],
      providerName: d['providerName'],
      label: d['label'],
      created: DateTime.parse(d['created']),
      status: d['status'] ?? 'pending',
    );
  }
}

class ServicesService {
  static final _user = FirebaseAuth.instance.currentUser!;
  static final _fs = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _providersRef() =>
      _fs.collection('providers');

  static CollectionReference<Map<String, dynamic>> _userJobsRef() =>
      _fs.collection('users').doc(_user.uid).collection('services');

  // Use providers in cloud (seed test data if empty)
  static Future<List<ServiceProvider>> getProviders() async {
    final snap = await _providersRef().get();
    if (snap.docs.isEmpty) {
      // Seed some example test providers
      await _providersRef().add({
        'name': 'CraftPro s.r.o.',
        'specialty': 'Chimney Cleaning',
        'phone': '420777123456',
        'email': 'contact@craftpro.cz',
      });
      await _providersRef().add({
        'name': 'HeatTech Services',
        'specialty': 'Boiler Maintenance',
        'phone': '420733987654',
        'email': 'support@heattechnology.cz',
      });
      await _providersRef().add({
        'name': 'SolarExperts',
        'specialty': 'PV System Inspection',
        'phone': '420700555888',
        'email': 'info@solarexperts.cz',
      });
      return getProviders();
    }
    return snap.docs.map((d) => ServiceProvider.fromDoc(d)).toList();
  }

  static Stream<List<ServiceJob>> jobsStream() => _userJobsRef()
      .orderBy('created', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => ServiceJob.fromDoc(d)).toList());

  static Future<void> bookService({
    required String providerId,
    required String providerName,
    required String label,
  }) {
    final now = DateTime.now();
    return _userJobsRef().add({
      'providerId': providerId,
      'providerName': providerName,
      'label': label,
      'created': now.toIso8601String(),
      'status': 'pending',
    });
  }

  static Future<void> completeJob(String jobId) =>
      _userJobsRef().doc(jobId).update({'status': 'completed'});
}
