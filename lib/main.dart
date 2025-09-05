import 'package:attendance/bloc/attendance_bloc.dart';
import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/bloc/leave_bloc.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/repo/auth_repo.dart';
import 'package:attendance/repo/leave.dart';
import 'package:attendance/screens/leave_page.dart';
import 'package:attendance/screens/login_screen.dart';
import 'package:attendance/screens/signUp_screen.dart';
import 'package:attendance/screens/attendance_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

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
          ),
          home: const AuthCheck(),
          routes: {
            '/signUp': (context) => const SignupScreen(),
            '/login': (context) => LoginScreen(),
            '/homePage': (context) {
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
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print("Employee Id: ${sharedPreferences.getString('employeeId')}");
    try {
      if (sharedPreferences.getString('employeeEmail') != null && sharedPreferences.getString('employeeId') != null) {
        setState(() {
          userAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? const AttendanceScreen() : LoginScreen();
  }
}
