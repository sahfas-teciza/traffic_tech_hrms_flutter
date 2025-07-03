import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teciza_hr/utils/base64_decode.dart';
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/utils/date_time_utils.dart';
import 'package:teciza_hr/utils/preferences.dart';
import 'package:teciza_hr/utils/snackbar_helper.dart';
import 'package:teciza_hr/widgets/profile_info.dart';
import 'package:teciza_hr/widgets/face_recognize.dart';
import 'package:teciza_hr/widgets/qr_scan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool punchStatus = false;
  List<Map<String, String>> logs = [];
  bool isQRActive = false, isFaceActive = true, isLoading = false;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    _fetchCheckinStatus();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  bool checkTime(String formattedTime) {
    try {
      formattedTime = formattedTime.trim();

      DateTime inputTime = DateFormat("h:mm a").parse(formattedTime);
      DateTime referenceTime = DateFormat("h:mm a").parse("05:30 PM");

      return inputTime.isBefore(referenceTime);
    } catch (e) {
      return false;
    }
  }

  void _punch() async {
    await Preferences.saveData(
        {"isQRActive": isQRActive, "isFaceActive": isFaceActive});
    _startExpiryTimer();

    if (!isFaceActive && mounted) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => FaceRecognize()));
      final isFaceActiveValue =
          await Preferences.getData<bool>('isFaceActive') ?? true;
      setState(() => isFaceActive = isFaceActiveValue);
    }

    if (!isFaceActive) return;

    if (!isQRActive && mounted) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => QrScan()));
      final isQRActiveValue =
          await Preferences.getData<bool>('isQRActive') ?? false;
      setState(() => isQRActive = isQRActiveValue);
    }

    if (!isQRActive) return;

    final isQRActiveFinal =
        await Preferences.getData<bool>("isQRActive") ?? false;
    final isFaceActiveFinal =
        await Preferences.getData<bool>("isFaceActive") ?? true;

    if (!isQRActiveFinal || !isFaceActiveFinal) {
      _showSnackBar('QR not recognized yet');
      return;
    }

    await checkinOrCheckout();
  }

  Future<String?> _showReasonBottomSheet() async {
    String reason = '';

    return await showModalBottomSheet<String>(
          context: context,
          isDismissible: true, // Allows the user to dismiss the sheet
          enableDrag: true, // Allows dragging down to close
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please provide a reason',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      reason = value;
                    },
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Enter reason here...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop('');
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(reason);
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ) ??
        '';
  }

  Future<void> checkinOrCheckout() async {
    await _fetchCheckinStatus();
    setState(() => isLoading = true);
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    try {
      var empData = await Preferences.getData<Map<String, dynamic>>("emp_info");
      if (empData == null) {
        _showSnackBar('Session expired, please login again.');
        return;
      }

      final token = await Preferences.getData<String>('token');
      final logType = punchStatus ? 'OUT' : 'IN';

      String? reason;
      if (logType == 'OUT' && checkTime(formattedTime)) {
        reason = await _showReasonBottomSheet();

        if (reason == null || reason.isEmpty) {
          _showSnackBar('Please provide a reason.');
          return;
        }
      }

      final response = await http.post(
        Uri.parse('${AppApiService.baseUrl}/method/traffictech.api.portal.hrms.checkin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        },
        body: jsonEncode({
          'employee': empData['name'] ?? '',
          'log_type': logType,
          'device_id': 'any',
          'reason': reason ?? ''
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['message']['success']) {
          _showSnackBar(data['message']['message']);
        } else {
          await _fetchCheckinStatus();
          await Preferences.saveData(
              {"isQRActive": true, "isFaceActive": true});
        }
      }
    } catch (e) {
      _showSnackBar('An error occurred 2: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCheckinStatus() async {
    try {
      var empData = await Preferences.getData<Map<String, dynamic>>("emp_info");
      if (empData == null)
        return _showSnackBar('Session expired, please login again.');

      final token = await Preferences.getData<String>('token');

      final response = await http.post(
        Uri.parse(
            '${AppApiService.baseUrl}/method/traffictech.api.portal.hrms.get_recent_log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token'
        },
        body: jsonEncode({'employee': empData['name']}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['message']['success']) {
          _showSnackBar(data['message']['message']);
        } else {
          setState(() {
            punchStatus =
                data['message']['current_status'] == 'IN' ? true : false;

            logs = List<Map<String, String>>.from(
                data['message']['logs'].map((log) => {
                      'log_type': log['log_type'] as String,
                      'time': log['time'] as String,
                    }));
          });
        }
      }
    } catch (e) {
      _showSnackBar('An error occurred 3: $e');
    }
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(const Duration(minutes: 1), () async {
      await Preferences.saveData({"isQRActive": true, "isFaceActive": true});
      setState(() {
        isQRActive = false;
        isFaceActive = true;
      });
    });
  }

  void _showSnackBar(String message) {
    SnackBarHelper.showSnackBar(context, message);
  }

  Widget _buildLogRow(String label, String dateTime, String icon) {
    final timestring = dateTime.split(' ')[1];

    final time = timestring.split('.')[0];

    return Column(
      children: [
        Image.asset(icon),
        const SizedBox(height: 5),
        Text(time),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> employeeInfo(BuildContext context) async {
    var empData = await Preferences.getData<Map<String, dynamic>>("emp_info");

    if (empData == null) {
      return {};
    }

    return empData;
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FutureBuilder<Map<String, dynamic>>(
        future: employeeInfo(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final empInfo = snapshot.data!;

            var empImage = empInfo['image_base64'];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileInfo()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red[200],
                        child: empImage?.isNotEmpty ?? false
                            ? ClipOval(
                                child: Image.memory(
                                  Base64ToImage.base64Decoder(empImage)!,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 25,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          empInfo['employee_name'] ?? 'Unknown',
                          style: AppTextStyles.subheading,
                        ),
                        Text(
                          empInfo['name'] ?? 'No name',
                          style: AppTextStyles.content
                              .copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                // IconButton(
                //   onPressed: () => logout(context),
                //   icon: const Icon(
                //     FluentSystemIcons.ic_fluent_power_regular,
                //     color: AppColors.darkBlue,
                //   ),
                // ),
              ],
            );
          } else {
            return const Text('No employee info available');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = DateTimeUtils.getFormattedTime(now);
    String formattedDate = DateTimeUtils.getFormattedDate(now);

    final today = DateTime.now().toString().split(' ')[0];

    // Filter logs for today and separate punch in and out
    final todayLogs =
        logs.where((log) => log['time']?.startsWith(today) ?? false).toList();
    final punchInLogs =
        todayLogs.where((log) => log['log_type'] == 'IN').toList();
    final punchOutLogs =
        todayLogs.where((log) => log['log_type'] == 'OUT').toList();

    var displayLogs = [...punchInLogs].take(1);

    if (!punchStatus) {
      displayLogs = [...displayLogs, ...punchOutLogs.take(1)];
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const Spacer(),
            Column(
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: AppColors.navyBlue,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _punch,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE2E6EA),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFE2E6EA), width: 5)),
                    child: !punchStatus
                        ? Container()
                        : const CircularProgressIndicator(
                            value: 0.75,
                            strokeWidth: 5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.goldenYellow)),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 5)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_outlined,
                            color: !punchStatus
                                ? AppColors.darkRed
                                : AppColors.goldenYellow,
                            size: 40),
                        const SizedBox(height: 8),
                        Text(!punchStatus ? 'PUNCH IN' : 'PUNCH OUT',
                            style: AppTextStyles.subheading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: displayLogs.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: displayLogs.map((log) {
                        return _buildLogRow(
                            log['log_type'] == 'IN' ? 'Punch In' : 'Punch Out',
                            log['time'] ?? '--',
                            log['log_type'] == 'IN'
                                ? 'assets/icons/check_in.png'
                                : 'assets/icons/check_out.png');
                      }).toList(),
                    )
                  : const Center(child: Text('No punch logs available today.')),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
