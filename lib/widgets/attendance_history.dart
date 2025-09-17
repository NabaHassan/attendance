import 'package:attendance/consts/constants.dart';
import 'package:attendance/repo/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceHistory extends StatefulWidget {
  final String userId;
  const AttendanceHistory({super.key, required this.userId});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  String _filter = "Day"; // default filter

  String formatAttendanceTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return "--";
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return "--";
    }
  }

  DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateFormat("d MMMM yyyy").parse(value);
      } catch (_) {
        return DateTime.tryParse(value); // fallback ISO
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Title
        Center(
          child: Text(
            "Attendance History",
            style: GoogleFonts.poppins(
              fontSize: screenWidth / 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Modern Filter Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["Day", "Month", "Year"].map((filter) {
              final isSelected = _filter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _filter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Constants.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Attendance List
        StreamBuilder<Map<String, dynamic>?>(
          stream: context.read<AuthRepository>().getUserAttendance(
            widget.userId,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No attendance history"));
            }

            final attendance = snapshot.data ?? {};
            final entries = attendance.entries.toList();

            // Apply filter
            final now = DateTime.now();
            final filteredEntries = entries.where((entry) {
              final date = _toDate(entry.key);
              if (date == null) return false;

              if (_filter == "Day") {
                return date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;
              } else if (_filter == "Month") {
                return date.month == now.month && date.year == now.year;
              } else if (_filter == "Year") {
                return date.year == now.year;
              }
              return true;
            }).toList();

            if (filteredEntries.isEmpty) {
              return const Center(child: Text("No records found for filter"));
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final date = filteredEntries[index].key;
                final record = Map<String, dynamic>.from(
                  filteredEntries[index].value,
                );
                final checkIn = record['checkIn'] as String?;
                final checkOut = record['checkOut'] as String?;

                final parsedDate = DateFormat("d MMMM yyyy").parse(date);
                final dayNumber = DateFormat("d").format(parsedDate);
                final monthName = DateFormat("MMM").format(parsedDate);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Calendar Style Day Badge
                        Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: Constants.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Constants.primary.withOpacity(0.8),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  monthName.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  dayNumber,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Times Info
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   DateFormat(
                              //     "EEEE, dd MMM yyyy",
                              //   ).format(parsedDate),
                              //   style: GoogleFonts.poppins(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 15,
                              //     color: Colors.black87,
                              //   ),
                              // ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.login,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatAttendanceTime(checkIn),
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatAttendanceTime(checkOut),
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
