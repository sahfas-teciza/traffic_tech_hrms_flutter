import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomInput extends StatelessWidget {
  final String labelTxt;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool obscureText;

  const CustomInput({
    super.key,
    required this.labelTxt,
    required this.controller,
    this.inputType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelTxt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.darkBlue,
            width: 2,
          ),
        ),
      ),
    );
  }
}
