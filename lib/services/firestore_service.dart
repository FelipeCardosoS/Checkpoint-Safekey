// Camada mínima de acesso ao Firestore.
// Coleção: users/{uid}/passwords (um doc por senha).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream pra listar em tempo real (ordenado do mais novo pro mais antigo)
  Stream<List<Map<String, dynamic>>> passwordsStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('passwords')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // Insere um doc com label + senha + timestamp
  Future<void> addPassword(
      {required String label, required String password}) async {
    await _db.collection('users').doc(_uid).collection('passwords').add({
      'label': label,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove pelo id do doc
  Future<void> deletePassword(String id) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('passwords')
        .doc(id)
        .delete();
  }
}
