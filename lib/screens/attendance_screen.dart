import 'package:attendance/bloc/attendance_bloc.dart';
import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/repo/auth_repo.dart';
import 'package:attendance/widgets/attendance_history.dart';
import 'package:attendance/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:analog_clock/analog_clock.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        if (state is AuthError) {
          SnackBar(content: Text(state.message));
          Navigator.pushReplacementNamed(context, '/login');
        }

        if (state is Authenticated) {
          final employeeId = state.user.id;
          final employeeName = state.user.name;
          final employeeStatus = state.user.role;

          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: Column(
              children: [
                // Gradient Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Constants.primary,
                        Constants.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth / 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            employeeName,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth / 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            employeeStatus,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth / 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      // Right side profile avatar
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          getInitials(employeeName),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Today's Status Section
                        Text(
                          "Today's Status",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth / 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        StreamBuilder<Map<String, dynamic>?>(
                          stream: context
                              .read<AuthRepository>()
                              .getTodayAttendance(employeeId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            // if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            //   return const Center(
                            //     child: Text("No attendance data found"),
                            //   );
                            // }

                            final todayAttendance = snapshot.data;
                            final hasCheckedInToday =
                                todayAttendance?['checkIn'] != null;
                            final hasCheckedOutToday =
                                todayAttendance?['checkOut'] != null;

                            String checkInTime = hasCheckedInToday
                                ? DateFormat("hh:mm a").format(
                                    DateTime.parse(todayAttendance!['checkIn']),
                                  )
                                : "--:--";

                            String checkOutTime = hasCheckedOutToday
                                ? DateFormat("hh:mm a").format(
                                    DateTime.parse(
                                      todayAttendance!['checkOut'],
                                    ),
                                  )
                                : "--:--";

                            final GlobalKey<SlideActionState> slideKey =
                                GlobalKey();

                            return Column(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.login,
                                              size: 30,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Check In",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              checkInTime,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 1,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                        ),
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              size: 30,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Check Out",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              checkOutTime,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                hasCheckedOutToday
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          "✅ You have already Checked Out today!",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                      )
                                    : BlocListener<
                                        AttendanceBloc,
                                        AttendanceState
                                      >(
                                        listener: (context, state) {
                                          if (state is AttendanceSuccess) {
                                            Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                                slideKey.currentState?.reset();
                                              },
                                            );
                                          }
                                        },
                                        child: SlideAction(
                                          key: slideKey,
                                          text: hasCheckedInToday
                                              ? "Slide to Check Out"
                                              : "Slide to Check In",
                                          outerColor: Colors.white,
                                          innerColor: hasCheckedInToday
                                              ? Constants.error
                                              : Constants.primary,
                                          elevation: 4,
                                          borderRadius: 12,
                                          textStyle: GoogleFonts.poppins(
                                            fontSize: screenWidth / 24,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          sliderButtonIcon: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                          ),
                                          onSubmit: () {
                                            context.read<AttendanceBloc>().add(
                                              StoreAttendance(
                                                employeeId,
                                                hasCheckedInToday
                                                    ? "checkOut"
                                                    : "checkIn",
                                                DateTime.now(),
                                              ),
                                            );
                                            return null;
                                          },
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        // Date and Live Clock
                        Center(
                          child: Column(
                            children: [
                              Center(
                                child: AnalogClock(
                                  width: screenWidth / 2,
                                  height: screenWidth / 2,
                                  isLive: true, // updates every second
                                  hourHandColor: Colors.black,
                                  minuteHandColor: Colors.black,
                                  secondHandColor: Colors.red,
                                  numberColor: Colors.black54,
                                  showSecondHand: true,
                                  showNumbers: true,
                                  textScaleFactor: 1.2,
                                  showAllNumbers: true,
                                  datetime: DateTime.now(),
                                ),
                              ),
                              const SizedBox(height: 6),

                              Text(
                                DateFormat(
                                  "EEEE, dd MMM yyyy",
                                ).format(DateTime.now()),
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth / 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Attendance History Section
                        AttendanceHistory(userId: employeeId),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation
              ],
            ),
            bottomNavigationBar: FadingBottomNav(initialIndex: 1),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
