import 'package:attendance/bloc/leave_bloc.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/repo/leave_repo.dart';
import 'package:attendance/widgets/custom_bottom_nav.dart';
import 'package:attendance/widgets/custom_drop_down.dart';
import 'package:attendance/widgets/custom_leave_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LeaveFormScreen extends StatelessWidget {
  final String userId;
  const LeaveFormScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaveBloc(context.read<LeaveRepository>()),
      child: LeaveFormView(userId: userId),
    );
  }
}

class LeaveFormView extends StatefulWidget {
  final String userId;
  const LeaveFormView({super.key, required this.userId});

  @override
  State<LeaveFormView> createState() => _LeaveFormViewState();
}

class _LeaveFormViewState extends State<LeaveFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedLeaveType = '';
  bool showForm = true;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top header strip
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 15, right: 15),
            child: Text(
              "Leave",
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
          ),

          /// Toggle
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Container(
              height: height / 13,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                color: Colors.grey.shade300,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ToggleButton(
                  width: width - 50,
                  height: height,
                  activeTextColor: Colors.black,
                  inactiveTextColor: Colors.black,
                  toggleBackgroundColor: Colors.grey.shade300,
                  toggleBorderColor: Colors.transparent,
                  toggleColor: Colors.white,
                  leftDescription: 'Apply Leave',
                  rightDescription: 'History',
                  onLeftToggleActive: () {
                    setState(() => showForm = true);
                  },
                  onRightToggleActive: () {
                    setState(() => showForm = false);
                  },
                ),
              ),
            ),
          ),

          /// Dynamic content area
          Expanded(
            child: BlocListener<LeaveBloc, LeaveState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Leave request submitted ✅",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                  _formKey.currentState?.reset();
                  _descriptionController.clear();
                }
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: ${state.errorMessage}",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                }
              },
              child: showForm
                  ? _buildLeaveForm(context, height, width)
                  : _buildHistoryView(),
            ),
          ),
        ],
      ),

      /// Bottom nav remains fixed
      bottomNavigationBar: FadingBottomNav(initialIndex: 0),
    );
  }

  /// Leave Form
  Widget _buildLeaveForm(BuildContext context, double height, double width) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Leave Type
              Text(
                "Leave Type",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CustDropDown(
                  enabled: true,
                  icon: Icons.category,
                  borderRadius: 16,
                  hintText: 'Select Leave Type',

                  items: const [
                    CustDropdownMenuItem(
                      value: "Sick Leave",
                      child: Text("Sick Leave"),
                    ),
                    CustDropdownMenuItem(
                      value: "Casual Leave",
                      child: Text("Casual Leave"),
                    ),
                    CustDropdownMenuItem(
                      value: "Annual Leave",
                      child: Text("Annual Leave"),
                    ),
                    CustDropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedLeaveType = value);
                      context.read<LeaveBloc>().add(LeaveTitleChanged(value));
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// Date Pickers Row
              Text(
                "Leave Duration",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              context.read<LeaveBloc>().add(
                                LeaveFromDateChanged(picked),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Constants.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.fromDate != null
                                        ? "From: ${state.fromDate!.toUtc().toString().split(' ')[0]}"
                                        : "From Date",
                                    style: GoogleFonts.poppins(
                                      color: state.fromDate != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              context.read<LeaveBloc>().add(
                                LeaveToDateChanged(picked),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Constants.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.toDate != null
                                        ? "To: ${state.toDate!.toLocal().toString().split(' ')[0]}"
                                        : "To Date",
                                    style: GoogleFonts.poppins(
                                      color: state.toDate != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Description
              Text(
                "Description",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Enter leave description...",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Constants.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Constants.primary, width: 2),
                  ),
                ),
                maxLines: 4,
                minLines: 3,
                onChanged: (value) {
                  context.read<LeaveBloc>().add(LeaveDescriptionChanged(value));
                },
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter description" : null,
              ),

              const SizedBox(height: 24),

              /// Submit Button
              BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) {
                  return FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Constants.primary,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<LeaveBloc>().add(
                                SubmitLeave(widget.userId),
                              );
                            }
                          },
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            "Submit Leave",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// History Page
  Widget _buildHistoryView() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: context.read<LeaveRepository>().getUserLeaveApplications(
          widget.userId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final leaves = snapshot.data ?? [];
          if (leaves.isEmpty) {
            return Center(
              child: Text(
                "No leave requests yet",
                style: GoogleFonts.poppins(),
              ),
            );
          }

          String formatDate(dynamic date) {
            if (date == null) return "N/A";

            if (date is Timestamp) {
              return DateFormat("d MMM yyyy").format(date.toDate());
            }
            if (date is DateTime) {
              return DateFormat("d MMM yyyy").format(date);
            }
            if (date is String) {
              try {
                final parsed = DateTime.parse(date);
                return DateFormat("d MMM yyyy").format(parsed);
              } catch (_) {
                return date; // fallback if string isn't a valid date
              }
            }
            return date.toString();
          }

          IconData getLeaveIcon(String type) {
            switch (type) {
              case "Sick Leave":
                return Icons.sick;
              case "Casual Leave":
                return Icons.weekend;
              case "Annual Leave":
                return Icons.beach_access;
              case "Other":
                return Icons.event;
              default:
                return Icons.work_history;
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Constants.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Leave History",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // Leave cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaves.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = leaves[index];
                    final leaveType =
                        record['title'] ?? record['type'] ?? "N/A";
                    final reason =
                        record['description'] ??
                        record['reason'] ??
                        "No reason provided";
                    final status = record['status'] ?? "Pending";

                    final fromDate = formatDate(record['fromDate']);
                    final toDate = formatDate(record['toDate']);
                    final appliedOn = formatDate(record['createdAt']);
                    final remarks = record['remarks'] ?? "No remarks";

                    // Status color & icon
                    Color statusColor;
                    IconData statusIcon;
                    switch (status) {
                      case "Approved":
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case "Rejected":
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.orange;
                        statusIcon = Icons.hourglass_bottom;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + Status Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      getLeaveIcon(leaveType),
                                      color: Constants.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      leaveType,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        size: 16,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        status,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Date Range
                            if (fromDate != "N/A" && toDate != "N/A")
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$fromDate - $toDate",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // Reason
                            _buildDetailRow("Reason", reason),

                            const SizedBox(height: 12),

                            // Applied On
                            if (appliedOn != "N/A")
                              _buildDetailRow("Applied On", appliedOn),

                            const SizedBox(height: 12),

                            // Remarks
                            _buildDetailRow("Admin Remarks", remarks),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Helper Widget
Widget _buildDetailRow(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.poppins(fontSize: 14)),
    ],
  );
}
