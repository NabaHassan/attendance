import 'package:attendance/bloc/attendance_bloc.dart';
import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/bloc/leave_bloc.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/models/user.dart';
import 'package:attendance/repo/auth_repo.dart';
import 'package:attendance/repo/leave_repo.dart';
import 'package:attendance/screens/history_page.dart';
import 'package:attendance/screens/leave_page.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:attendance/screens/signUp_screen.dart';
import 'package:attendance/screens/attendance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<LeaveRepository>(
          create: (context) => LeaveRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<AttendanceBloc>(
            create: (context) => AttendanceBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<LeaveBloc>(
            create: (context) => LeaveBloc(context.read<LeaveRepository>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Attendance App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Constants.primaryDark),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: const AuthCheck(),
          routes: {
            '/signUp': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/leave': (context) {
              final authState = context.read<AuthBloc>().state;

              if (authState is Authenticated) {
                return LeaveFormScreen(userId: authState.user.id);
              } else {
                return const Scaffold(
                  body: Center(child: Text("Please login first")),
                );
              }
            },
            '/attendance': (context) => const AttendanceScreen(),
            '/history': (context) => const HistoryPage(),
            

          },
        ),
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool? userAvailable;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool("rememberMe") ?? false;
    final user = FirebaseAuth.instance.currentUser;
    
    if (remember && user != null) {
      context.read<AuthBloc>().add(AppStarted());

      setState(() {
        userAvailable = true;
      });
    } else {
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userAvailable == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ Use BlocBuilder so UI reacts to AuthBloc state
    if (userAvailable == true) {
      // If we already know the user is logged in, directly show Attendance
      return const AttendanceScreen();
    } else {
      return const LoginScreen();
    }
  }
}
