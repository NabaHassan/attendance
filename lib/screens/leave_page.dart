import 'package:attendance/bloc/auth__bloc.dart';
import 'package:attendance/bloc/auth_event.dart';
import 'package:attendance/bloc/leave_bloc.dart';
import 'package:attendance/consts/constants.dart';
import 'package:attendance/repo/leave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(height: height / 20),
          Expanded(
            child: BlocListener<LeaveBloc, LeaveState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Leave request submitted ✅")),
                  );

                  // ✅ Reset form fields instead of navigating away
                  _formKey.currentState?.reset();
                  _titleController.clear();
                  _descriptionController.clear();
                }
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${state.errorMessage}")),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Apply for Leave",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Fill in the details below to submit your leave request.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      // Title Card
                      _buildInputCard(
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: "Leave Title",
                            prefixIcon: Icon(
                              Icons.title,
                              color: Constants.primary,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            context.read<LeaveBloc>().add(
                              LeaveTitleChanged(value),
                            );
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Enter a title"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description Card
                      SizedBox(
                        height: height / 8,
                        child: _buildInputCard(
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: "Description",
                              prefixIcon: Icon(
                                Icons.description,
                                color: Constants.primary,
                              ),
                              border: InputBorder.none,
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                              context.read<LeaveBloc>().add(
                                LeaveDescriptionChanged(value),
                              );
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter description"
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      BlocBuilder<LeaveBloc, LeaveState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: height / 10,
                            child: _buildInputCard(
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
                                      LeaveDateChanged(picked),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Constants.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      state.date != null
                                          ? "Date: ${state.date!.toLocal().toString().split(' ')[0]}"
                                          : "Pick a Date",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: state.date != null
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      BlocBuilder<LeaveBloc, LeaveState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.primary,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
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
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Submit",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
            ),
          ),
        ],
      ),
      // Bottom nav remains fixed
      bottomNavigationBar: Padding(
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
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.popAndPushNamed(context, '/attendance');
                }
                if (index == 2) {
                  SnackBar(
                    content: Text("Signin Out..."),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 1),
                  );
                  context.read<AuthBloc>().add(SignOutRequested());
                  Navigator.popAndPushNamed(context, '/login');
                }
              },

              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: Constants.primary,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
                    child: FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                  ),
                  label: 'SignOut',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper for form input cards
  Widget _buildInputCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: child,
      ),
    );
  }
}
