import 'package:flutter/material.dart';
import 'package:teciza_hr/utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CustomCard(
                      imagePath: 'assets/icons/attendance.png',
                      label: 'Request \nAttendance',
                    ),
                    const SizedBox(height: 15),
                    CustomCard(
                      imagePath: 'assets/icons/shift.png',
                      label: 'Request a \nShift',
                    ),
                    const SizedBox(height: 15),
                    CustomCard(
                      imagePath: 'assets/icons/advance.png',
                      label: 'Request an \nadvance',
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomCard(
                      imagePath: 'assets/icons/leave.png',
                      label: 'Request \nLeave',
                    ),
                    const SizedBox(height: 15),
                    CustomCard(
                      imagePath: 'assets/icons/expense.png',
                      label: 'Claim an \nExpense',
                    ),
                    const SizedBox(height: 15),
                    CustomCard(
                      imagePath: 'assets/icons/salary_slips.png',
                      label: 'View Salary\nSlips',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String imagePath;
  final String label;

  const CustomCard({
    super.key,
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      height: 149,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E2E2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 63,
            height: 63,
            decoration: BoxDecoration(
              color: AppColors.lightCyan,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.lightCyan,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF45484D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
