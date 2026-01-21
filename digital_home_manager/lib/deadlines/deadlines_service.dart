import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Deadline {
  String id;
  String label;
  DateTime due;
  bool completed;

  Deadline({
    required this.id,
    required this.label,
    required this.due,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'due': due.toIso8601String(),
        'completed': completed,
      };

  static Deadline fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Deadline(
      id: doc.id,
      label: data['label'] ?? '',
      due: DateTime.parse(data['due']),
      completed: data['completed'] ?? false,
    );
  }
}

class DeadlinesService {
  static final _user = FirebaseAuth.instance.currentUser!;
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _colRef() =>
      _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('deadlines');

  static Stream<List<Deadline>> deadlinesStream() =>
      _colRef().snapshots().map((snap) =>
          snap.docs.map((doc) => Deadline.fromDoc(doc)).toList());

  static Future<void> addDeadline(String label, DateTime due) =>
      _colRef().add({
        'label': label,
        'due': due.toIso8601String(),
        'completed': false,
      });

  static Future<void> updateDeadline(String id, {String? label, DateTime? due, bool? completed}) =>
      _colRef().doc(id).update({
        if (label != null) 'label': label,
        if (due != null) 'due': due.toIso8601String(),
        if (completed != null) 'completed': completed,
      });

  static Future<void> deleteDeadline(String id) =>
      _colRef().doc(id).delete();
}
