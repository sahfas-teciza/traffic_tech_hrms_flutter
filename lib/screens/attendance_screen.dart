import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/utils/preferences.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDay = DateTime.now();
  bool isLoading = false;
  DateTime startOfMonth = DateTime.now();
  DateTime endOfMonth = DateTime.now();

  List<Map<String, String>> attendanceEntries = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    updateStartEndOfMonth(selectedDay);
    await fetchAttendance();
  }

  void updateStartEndOfMonth(DateTime date) {
    setState(() {
      startOfMonth = DateTime(date.year, date.month, 1);
      endOfMonth = DateTime(date.year, date.month + 1, 0); 
    });
  }

  final List<Color> cardColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

 String formatDate(String inputDate) {
    try {
      final parsedDate = DateTime.parse(inputDate);
      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = monthNames[parsedDate.month - 1];
      final day = parsedDate.day.toString().padLeft(2, '0');
      return '$month\n$day'; 
    } catch (e) {
      return inputDate; 
    }
  }

  String extractTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      return "N/A"; 
    }

    try {
      final parts = timestamp.split(' ');
      if (parts.length > 1) {
        return parts[1].split('.').first; 
      }
      return "Invalid Format"; 
    } catch (e) {
      return "Error";
    }
  }

  Future<void> fetchAttendance() async {
    if (!mounted) return; 

    setState(() => isLoading = true);

    try {
      var empData = await Preferences.getData<Map<String, dynamic>>("emp_info");
      final token = await Preferences.getData<String>('token');

      if (empData == null || token == null) {
        if (mounted) _showSnackBar('Session expired, please login again.');
        return;
      }

      final response = await http.post(
        Uri.parse(
            '${AppApiService.baseUrl}/method/traffictech.api.portal.hrms.get_attendance_calendar_events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        },
        body: jsonEncode({
          'employee': empData['name'],
          'from_date': '${startOfMonth.year.toString().padLeft(4, '0')}-${(startOfMonth.month).toString().padLeft(2, '0')}-${(startOfMonth.day).toString().padLeft(2, '0')}',
          'to_date': '${endOfMonth.year.toString().padLeft(4, '0')}-${(endOfMonth.month).toString().padLeft(2, '0')}-${(endOfMonth.day).toString().padLeft(2, '0')}',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['message'] != null) {
          final message = data['message'] as Map<String, dynamic>;

           attendanceEntries = message.entries.map((entry) {
            final value = entry.value as Map<String, dynamic>;

            return {
              'date': formatDate(entry.key),
              'status': value['status']?.toString() ?? 'N/A',
              'hours': value['hours']?.toString() ?? 'N/A',
              'in_time': value['in_time'] != null ? extractTime(value['in_time']!.toString()) : "N/A",
              'out_time': value['out_time'] != null ? extractTime(value['out_time']!.toString()) : "N/A",
            };
          }).toList();
        }
      } else {
        if (mounted) _showSnackBar('Failed to fetch attendance.');
      }
    } catch (e) {
      if (mounted) _showSnackBar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    // SnackBarHelper.showSnackBar(context, message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget buildAttendanceRow(Map<String, String> entry, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date
          Container(
            decoration: BoxDecoration(
              color: cardColors[index % cardColors.length],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              entry['date']!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (entry['status'] == 'Absent' || entry['status'] == 'Holiday')
            Column(
              children: [
                Text(
                  entry['status']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                entry['status'] == 'Absent'
                    ? const Text("No Punch Info")
                    : const SizedBox.shrink(),
              ],
            )
          else ...[
            Column(
              children: [
                Text(entry['in_time']!),
                const Text("Punch In"),
              ],
            ),
            Column(
              children: [
                Text(entry['out_time']!),
                const Text("Punch Out"),
              ],
            ),
            Column(
              children: [
                Text(entry['hours']!),
                const Text("Total Hours"),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Attendance Calendar'),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/background.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Scrollbar(
              thumbVisibility: true,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Calendar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          focusedDay: selectedDay,
                          firstDay: DateTime(2020),
                          lastDay: DateTime.now(),
                          calendarFormat: CalendarFormat.month,
                          selectedDayPredicate: (day) =>
                              isSameDay(day, selectedDay),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              this.selectedDay = selectedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            updateStartEndOfMonth(focusedDay);
                          },
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            weekendTextStyle: TextStyle(color: Colors.red),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Attendance List
                      isLoading
                          ? const CircularProgressIndicator()
                          : attendanceEntries.isEmpty
                              ? const Text('No attendance records found.')
                              : ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: attendanceEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = attendanceEntries[index];
                                    return buildAttendanceRow(entry, index);
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
    );
  }
}
