import 'package:attendance/consts/constants.dart';
import 'package:attendance/widgets/custom_leave_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Constants.primary,
              ),
              width: width / 1.5,
              height: height / 18,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leave",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: height / 13,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      color: Colors.grey.shade300,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: ToggleButton(
                        width: width - 50,
                        height: height,
                        activeTextColor: Colors.black,
                        inactiveTextColor: Colors.black,
                        toggleBackgroundColor: Colors.grey.shade300,
                        toggleBorderColor: Colors.transparent,
                        toggleColor: Colors.white,
                        leftDescription: 'ApplyLeave',
                        rightDescription: 'History',
                        onLeftToggleActive: () {
                          Navigator.pushReplacementNamed(context, '/leave');
                        },
                        onRightToggleActive: () {
                          //Navigator.pushReplacementNamed(context, '/history');
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
