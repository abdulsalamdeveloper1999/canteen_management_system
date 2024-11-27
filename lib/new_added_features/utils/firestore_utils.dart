import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUtils {
  static String userUid = FirebaseAuth.instance.currentUser!.uid;

  static List<Map<String, dynamic>> snapshotToList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
