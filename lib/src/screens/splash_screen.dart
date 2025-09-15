import 'dart:async';
import 'package:digicart/src/utils/colors.dart';
import 'package:flutter/material.dart';
import '../components/central_logo.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Dashboard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: second,
      body: const CentralLogo(width: 250, height: 250),
    );
  }
}
