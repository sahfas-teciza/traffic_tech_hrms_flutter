import 'package:flutter/material.dart';
import 'package:teciza_hr/screens/login_screen.dart';
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = AppSizes.getSize(context);

    return Scaffold(
      body: Stack(
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
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    height: AppSizes.calculateHeightRatio(screenSize, 5),
                  ),
                  Image(
                    image: const AssetImage('assets/images/erp-logo1.png'),
                    height: AppSizes.calculateHeightRatio(screenSize, 21),
                  ),
                  SizedBox(
                    height: AppSizes.calculateHeightRatio(screenSize, 1),
                  ),
                  Image(
                    image: const AssetImage('assets/images/banner.png'),
                    height: AppSizes.calculateHeightRatio(screenSize, 30),
                  ),
                  SizedBox(
                    height: AppSizes.calculateHeightRatio(screenSize, 3),
                  ),
                  Container(
                    height: AppSizes.calculateHeightRatio(screenSize, 40),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.1,
                      vertical: screenSize.height * 0.03,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome!",
                          style: AppTextStyles.heading,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Our platform is designed to streamline your resource management, making it efficient and intuitive. Let’s get started on optimizing your workflow and achieving your goals effortlessly.",
                          style: AppTextStyles.content,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        CustomButton(
                          btnTxt: 'SIGN IN',
                          activity: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
