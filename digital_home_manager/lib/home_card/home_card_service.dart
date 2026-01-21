import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeCardService {
  static final _users = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _docRef() =>
      _firestore.collection('users').doc(_users.currentUser!.uid).collection('profile').doc('home_card');

  static Future<Map<String, dynamic>?> getProfile() async {
    final doc = await _docRef().get();
    return doc.data();
  }

  static Stream<Map<String, dynamic>?> profileStream() =>
    _docRef().snapshots().map((doc) => doc.data());

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _docRef().set(profile, SetOptions(merge: true));
  }
}
