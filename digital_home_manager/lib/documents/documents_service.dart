import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StoredDocument {
  final String id;
  final String label;
  final String filename;
  final String url;
  final DateTime uploaded;

  StoredDocument({
    required this.id,
    required this.label,
    required this.filename,
    required this.url,
    required this.uploaded,
  });

  factory StoredDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StoredDocument(
      id: doc.id,
      label: data['label'],
      filename: data['filename'],
      url: data['url'],
      uploaded: DateTime.parse(data['uploaded']),
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'filename': filename,
        'url': url,
        'uploaded': uploaded.toIso8601String(),
      };
}

class DocumentsService {
  static final _user = FirebaseAuth.instance.currentUser!;
  static final _fs = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static CollectionReference<Map<String, dynamic>> _colRef() =>
      _fs.collection('users').doc(_user.uid).collection('documents');

  static Stream<List<StoredDocument>> docsStream() => _colRef().snapshots().map(
      (snap) => snap.docs.map((d) => StoredDocument.fromDoc(d)).toList());

  static Future<void> deleteDoc(StoredDocument doc) async {
    await _colRef().doc(doc.id).delete();
    await _storage.refFromURL(doc.url).delete();
  }

  static Future<void> uploadFile(File file, String label) async {
    final path = "users/${_user.uid}/documents/${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
    final task = await _storage.ref(path).putFile(file);
    final url = await task.ref.getDownloadURL();
    await _colRef().add({
      'label': label,
      'filename': p.basename(file.path),
      'url': url,
      'uploaded': DateTime.now().toIso8601String(),
    });
  }
}
