import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitLeave({
    required String userId,
    required String title,
    required String description,
    required DateTime? fromDate,
    required DateTime? toDate,
  }) async {
    if (fromDate == null || toDate == null) {
      throw Exception("Leave from and to dates are required");
    }

    try {
      await _firestore.collection("leave_applications").add({
        "userId": userId,
        "title": title,
        "description": description,
        "fromDate": fromDate.toIso8601String(),
        "toDate": toDate.toIso8601String(),
        "status": "pending", // default status
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to submit leave: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getUserLeaveApplications(String userId) {
    return _firestore
        .collection('leave_applications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {"id": doc.id, ...doc.data()})
              .toList(),
        );
  }
}
