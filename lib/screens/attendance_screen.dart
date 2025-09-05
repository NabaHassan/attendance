import 'package:attendance/bloc/attendance_bloc.dart';
import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/bloc/auth_state.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // You could load preferences if needed
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
        if (state is Authenticated) {
          final employeeId = state.user.id;
          final employeeName = state.user.name;
          final employeeStatus = state.user.role;

          return Scaffold(
            backgroundColor: Constants.background,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        SizedBox(height: screenHeight / 35),
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: screenWidth / 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "$employeeName,",
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          employeeStatus,
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(thickness: 1, color: Colors.grey.shade300),

                        // Today's Status
                        Text(
                          "Today's Status",
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // Attendance Info + Slider
                        StreamBuilder<Map<String, dynamic>?>(
                          stream: context
                              .read<AuthRepository>()
                              .getTodayAttendance(employeeId),
                          builder: (context, snapshot) {
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
                                // Status Box
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Check In",
                                            style: TextStyle(
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            checkInTime,
                                            style: TextStyle(
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Check Out",
                                            style: TextStyle(
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            checkOutTime,
                                            style: TextStyle(
                                              fontSize: screenWidth / 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Slider
                                hasCheckedOutToday
                                    ? Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          "You have already Checked Out today!",
                                          textAlign: TextAlign.center,
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
                                          textStyle: TextStyle(
                                            fontSize: screenWidth / 22,
                                            color: Colors.black54,
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

                        const SizedBox(height: 20),

                        // Date and Live Clock
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: DateTime.now().day.toString(),
                                    style: TextStyle(
                                      fontSize: screenWidth / 12,
                                      color: Constants.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: DateFormat(
                                      " MMM yyyy",
                                    ).format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: screenWidth / 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: StreamBuilder(
                                stream: Stream.periodic(
                                  const Duration(seconds: 1),
                                ),
                                builder: (context, asyncSnapshot) {
                                  return Text(
                                    DateFormat(
                                      "hh:mm:ss a",
                                    ).format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: screenWidth / 18,
                                      color: Colors.black54,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        Divider(thickness: 1, color: Colors.grey.shade300),
                        const SizedBox(height: 15),

                        Text(
                          "Attendance History",
                          style: TextStyle(
                            fontSize: screenWidth / 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // Attendance History List
                        StreamBuilder<Map<String, dynamic>?>(
                          stream: context
                              .read<AuthRepository>()
                              .getUserAttendance(state.user.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text("No attendance records yet"),
                              );
                            }

                            final attendance = snapshot.data!;
                            final entries = attendance.entries.toList();

                            return SizedBox(
                              height: screenHeight / 2.5,
                              child: ListView.separated(
                                itemCount: entries.length,
                                separatorBuilder: (_, __) => Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                                itemBuilder: (context, index) {
                                  final date = entries[index].key;
                                  final record =
                                      entries[index].value
                                          as Map<String, dynamic>;
                                  final checkIn = record['checkIn'];
                                  final checkOut = record['checkOut'];

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      title: Text(
                                        date,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.login,
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Check-in: ${checkIn != null ? DateFormat("hh:mm a").format(DateTime.parse(checkIn)) : "N/A"}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.logout,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Check-out: ${checkOut != null ? DateFormat("hh:mm a").format(DateTime.parse(checkOut)) : "N/A"}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation
                Padding(
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
                        currentIndex: 1,
                        onTap: (index) {
                          if (index == 0) {
                            Navigator.popAndPushNamed(context, '/homePage');
                          }
                          if (index == 2) {
                            context.read<AuthBloc>().add(SignOutRequested());
                            Navigator.popAndPushNamed(context, '/login');
                          }
                        },
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: Constants.primary,
                        unselectedItemColor: Colors.grey.shade600,
                        selectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                        selectedIconTheme: const IconThemeData(size: 24),
                        unselectedIconTheme: const IconThemeData(size: 20),
                        items: const [
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: Icon(Icons.home),
                            ),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: FaIcon(FontAwesomeIcons.calendarCheck),
                            ),
                            label: 'Attendance',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: FaIcon(
                                FontAwesomeIcons.arrowRightFromBracket,
                              ),
                            ),
                            label: 'SignOut',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
