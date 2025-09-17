import 'package:attendance/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // login
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }


  // Check if user is already logged in (Remember Me effect)
  User? getCurrentUser() {
    return _firebaseAuth.currentUser; // null if not logged in
  }


  //method to signin using google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn
          .signIn();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user; // return Firebase user
    } catch (e) {
      return null;
    }
  }

  // logout
  Future<void> signOut() async {
    try {
      // Firebase sign out
      await _firebaseAuth.signOut();

      // Google sign out (if logged in with Google)
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      return null;
    }
  }

  // register
  Future<User?> signUp({
    required String employeeName,
    required String email,
    required String password,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // Save user data in Firestore
        final data = <String, dynamic>{
          'name': employeeName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'id': user.uid,
          'role': 'Employee',
          ...?extraData,
        };

        await _firestore.collection('users').doc(user.uid).set(data);

        // Send verification email
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors (e.g., email already in use)
      throw Exception(e.message);
    } catch (e) {
      // Handle unexpected errors
      throw Exception("Sign up failed: $e");
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // refresh user state
    return user?.emailVerified ?? false;
  }

  /// ✅ New Method: Fetch user profile from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Async version: refreshes current user and returns UID
  Future<String?> fetchCurrentEmployeeId() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload(); // refresh user state
      return user.uid;
    }
    return null;
  }

  // Store attendance
  // Store attendance (check-in / check-out)
  Future<void> storeAttendanceTime(
    String userId,
    String type,
    DateTime time,
  ) async {
    final docRef = _firestore.collection('users').doc(userId);
    final today = DateFormat('d MMMM yyyy').format(DateTime.now());

    final snapshot = await docRef.get();
    final data = snapshot.data();
    final attendance = Map<String, dynamic>.from(data?['attendance'] ?? {});
    final todayAttendance = attendance[today] ?? {};

    // Save based on type
    await docRef.set({
      'attendance': {
        today: {
          'checkIn': type == "checkIn"
              ? time.toIso8601String().trim()
              : todayAttendance['checkIn'],
          'checkOut': type == "checkOut"
              ? time.toIso8601String()
              : todayAttendance['checkOut'],
        },
      },
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> getTodayAttendance(String userId) {
    final today = DateFormat('d MMMM yyyy').format(DateTime.now());

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) return null;
      final attendance = data['attendance'] ?? {};
      return attendance[today];
    });
  }

  Stream<Map<String, dynamic>?> getUserAttendance(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) return null;
      print("data:" + data.toString());
      return data['attendance'] ?? {};
    });
  }

  // auth state stream
  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();
}
