import 'package:attendance/models/user.dart';
import 'package:attendance/repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);

    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      final emailVerified = await authRepository.isEmailVerified();

      if (!emailVerified) {
        emit(AuthError("Email Is Not Verified, Please Verify Your Email."));
        return;
      }

      if (user == null) {
        emit(AuthError("Invalid credentials or user not found"));
        return;
      }

      // Optionally fetch the UserModel from Firestore if needed
      final uid = user.uid;
      final userModel = await authRepository.getUserModel(uid);

      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(AuthError("User profile not found in Firestore"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Sign in with Google → get user
      final user = await authRepository.signInWithGoogle();

      if (user == null) {
        emit(AuthError("Google sign-in failed or was cancelled"));
        return;
      }

      // Optionally fetch Firestore profile
      final userModel = await authRepository.getUserModel(user.uid);

      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(AuthError("User profile not found in Firestore"));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "Authentication failed"));
    } catch (e) {
      emit(AuthError("Unexpected error: $e"));
    }
  }


  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Sign up the user with Firebase Auth
      final user = await authRepository.signUp(
        employeeName: event.employeeName,
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(AuthError("Signup failed"));
        return;
      }

      // Create UserModel
      final userModel = UserModel(
        id: user.uid,
        name: event.employeeName,
        email: event.email,
        role: "Employee",
      );

      // Optional: Save user to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      emit(Authenticated(userModel));
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'Signup failed. ${e.message}';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
    emit(Unauthenticated());
  }
}
