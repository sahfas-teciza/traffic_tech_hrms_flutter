import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppApiService {
  static const String baseUrl = 'https://traffictech.tecizasolutions.com/api';
}


class AppColors {

  static const Color primaryYellow = Color(0xFFF7C500);
  static const Color black = Color(0xFF000000);
  static const Color darkYellow = Color(0xFFE0B200);
  static const Color lightYellow = Color(0xFFFFE066);

  static const Color primaryRed = Color(0xFFCA282C);
  static const Color darkRed = Color(0xFFAE181C);
  static const Color goldenYellow = Color(0xFFE89C1E);

  static const Color navyBlue = Color(0xFF1D3343);
  static const Color primaryBlue = Color(0xFF268ECC);
  static const Color darkBlue = Color(0xFF134766);
  static const Color deepBlue = Color(0xFF2B398F);
  static const Color lightCyan = Color(0xFFEAF8FF);

  static const Color neutralGrey = Color(0xFF777777);
  static const Color darkGrey = Color(0xFF45484D);
}

class AppTextStyles {
    static const TextStyle heading = TextStyle(
        fontSize: 32,
        color: Colors.white,
        fontWeight: FontWeight.w700
    );

    static const TextStyle subheading = TextStyle(
        fontSize: 16,
        color: AppColors.navyBlue,
        fontWeight: FontWeight.bold
    );

    static const TextStyle content = TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w400
    );
}

class AppSizes {
    static getSize(BuildContext context) {
        return MediaQuery.of(context).size;
    }

    static calculateHeightRatio(screenSize, double percentage) {
        return screenSize.height * percentage/100;
    }

    static getScreenHeight (){
        return Get.height;
    }

    static getScreenWidth (){
        return Get.width;
    }

    static getHeight (double pixels){
        double x = getScreenHeight()/pixels;
        return getScreenHeight()/x;
    }

    static getWidth (double pixels){
        double x = getScreenWidth()/pixels;
        return getScreenWidth()/x;

    }
}