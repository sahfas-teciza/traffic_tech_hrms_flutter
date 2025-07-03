import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/utils/preferences.dart';
import 'package:teciza_hr/utils/snackbar_helper.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  QrScanState createState() => QrScanState();
}

class QrScanState extends State<QrScan> {
  String? qrData;
  bool scanner = true; 

  void _onScan(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty && scanner) {
      setState(() {
        scanner = false;

        qrData = capture.barcodes.first.rawValue;
      });

      if (qrData != null) {
        _qrVaildation();
      }
    }
  }

  Future<void> _qrVaildation() async {
    try {
      final token = await Preferences.getData<String>('token');

      final response = await http.post(
        Uri.parse('${AppApiService.baseUrl}/method/traffictech.api.portal.hrms.validate_qr_code'),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $token'
      },
        body: jsonEncode({'scanned_code': qrData}),
      );

      if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (!data['message']['success']) {
          _showSnackBar(data['message']['message']);
        } else {
          _showSnackBar('QR scanned successfully!');
          await Preferences.saveData({"isQRActive": true}); 
        }

      } else {
        _showSnackBar('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        Navigator.pop(context);  
      }
    }
  }

  void _showSnackBar(String message) {
    SnackBarHelper.showSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                _onScan(capture);
              },
            ),
          ),
        ],
      ),
    );
  }
}
