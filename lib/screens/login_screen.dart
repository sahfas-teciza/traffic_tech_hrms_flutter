// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:teciza_hr/screens/home_screen.dart';
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/utils/snackbar_helper.dart';
import 'dart:convert';
import 'package:teciza_hr/utils/preferences.dart';
import 'package:teciza_hr/widgets/bottom_navbar.dart';
// import 'package:teciza_hr/utils/constants.dart';
// import 'package:teciza_hr/widgets/bottom_navbar.dart';
import 'package:teciza_hr/widgets/box_button.dart';
import 'package:teciza_hr/widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        _showSnackBar('Email or Password cannot be empty');
        return;
      }

      final response = await http.post(
        Uri.parse(
          '${AppApiService.baseUrl}/method/traffictech.api.portal.auth.authenticate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': emailController.text,
            'password': passwordController.text,
          }
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];

        if (message['success'] == false) {
          _showSnackBar(message['message']);
        } else {
          if (message['api_key'] != null &&
              message['api_secret'] != null &&
              mounted) {
            final empInfo = {
              'emp_info' : message['emp_info']['data'],
              'token'    : message['api_key'] + ':' + message['api_secret']
            };

            await Preferences.saveData(empInfo);

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BottomNavbar()),
              );
            }
          } else {
            final error = jsonDecode(response.body)['message'] ?? 'Login failed';
            _showSnackBar(error);
          }
        }
      }
    } catch (e) {
      _showSnackBar('An error occurred 1: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    SnackBarHelper.showSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = AppSizes.getSize(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: AppSizes.calculateHeightRatio(screenSize, 50),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 98),
                            child: Image(
                              image: const AssetImage(
                                  'assets/images/erp-logo1.png'),
                              height:
                                  AppSizes.calculateHeightRatio(screenSize, 25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSizes.calculateHeightRatio(screenSize, 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomInput(
                            controller: emailController, labelTxt: 'Email'),
                        const SizedBox(height: 20),
                        CustomInput(
                            controller: passwordController,
                            labelTxt: 'Password',
                            obscureText: true),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {},
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        BoxButton(
                            activity: login,
                            isLoading: isLoading,
                            label: 'Login'),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.content
                                    .copyWith(color: AppColors.darkYellow),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
