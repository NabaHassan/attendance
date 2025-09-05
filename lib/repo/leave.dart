import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitLeave({
    required String userId,
    required String title,
    required String description,
    required DateTime? date,
  }) async {
    if (date == null) {
      throw Exception("Leave date is required");
    }

    try {
      await _firestore.collection("leave_applications").add({
        "userId": userId,
        "title": title,
        "description": description,
        "date": date.toIso8601String(),
        "status": "pending", // default status
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to submit leave: $e");
    }
  }
}
