import 'package:flutter/material.dart';

class AuthImage extends StatelessWidget {
  const AuthImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 400,
      right: 0,
      bottom: 0,
      left: 150.0,
      child: Image.asset('assets/images/earth-img.png', fit: BoxFit.fitHeight),
    );
  }
}
