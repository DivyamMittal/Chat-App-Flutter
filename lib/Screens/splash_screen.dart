import 'package:chat_app/Apis/apis.dart';
import 'package:chat_app/Auth/login_screen.dart';
import 'package:chat_app/Screens/homepage_screen.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle((SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white)));

      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          child: Icon(
            Icons.message_rounded,
            size: 120,
          ),
        ),
      ),
    );
  }
}
