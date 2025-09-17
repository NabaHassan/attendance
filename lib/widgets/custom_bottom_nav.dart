import 'dart:async';
import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/consts/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FadingBottomNav extends StatefulWidget {
  final int initialIndex;

  const FadingBottomNav({super.key, required this.initialIndex});

  @override
  State<FadingBottomNav> createState() => _FadingBottomNavState();
}

class _FadingBottomNavState extends State<FadingBottomNav> {
  double _opacity = 10.0;
  Timer? _inactivityTimer;
  late int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    setState(() => _opacity = 1.0);

    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      setState(() => _opacity = 0.3);
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // detects taps anywhere
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(), // detects screen touch/move

      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _opacity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  _resetTimer(); // reset when nav tapped
                  if (index == 0) {
                    Navigator.popAndPushNamed(context, '/leave');
                    setState(() {
                      currentIndex = 0;
                    });
                  }
                  if (index == 1) {
                    Navigator.popAndPushNamed(context, '/attendance');
                    setState(() {
                      currentIndex = 1;
                    });
                  }

                  if (index == 2) {
                    context.read<AuthBloc>().add(SignOutRequested());
                    Navigator.popAndPushNamed(context, '/login');
                  }
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Constants.primary,
                unselectedItemColor: Colors.grey.shade600,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_note),
                    label: 'Leave',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.calendarCheck),
                    label: 'Attendance',
                  ),
                  BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                    label: 'SignOut',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
