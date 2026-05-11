import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> get meetingsHistory => _firestore
      .collection('users')
      .doc(_uid)
      .collection('meetings')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> addToMeetingHistory(String meetingName) async {
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('meetings')
          .add({
        'meetingName': meetingName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // silent fail
    }
  }
}
