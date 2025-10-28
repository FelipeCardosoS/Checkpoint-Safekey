// Splash: mostra a Lottie e decide pra onde ir (Intro, Login ou Home).

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'intro_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const route = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Delay curto pra animação aparecer
    await Future.delayed(const Duration(milliseconds: 600));
    final prefs = await SharedPreferences.getInstance();
    final shouldShowIntro = prefs.getBool('show_intro') ?? true;
    final user = FirebaseAuth.instance.currentUser;

    // fluxo de decisão bem direto
    if (shouldShowIntro) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(IntroScreen.route);
      return;
    }

    if (user == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(LoginScreen.route);
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(HomeScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // mostra a animação do splash
        child: Lottie.asset('assets/lottie/splash.json', width: 220),
      ),
    );
  }
}
