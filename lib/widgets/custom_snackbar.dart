import 'package:flutter/material.dart';

class CustomSnackbar extends StatelessWidget {
  final String text;
  final Color? backgroundColor;

  const CustomSnackbar({
    Key? key,
    required this.text,
    this.backgroundColor,
  }) : super(key: key);
    


  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.black,
    );
  }
}