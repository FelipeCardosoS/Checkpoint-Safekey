// App base: inicializa Firebase e define rotas.
// Comentários pensados pra apresentação: diretos e focados no “porquê”.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // gerado pelo flutterfire configure
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase precisa estar pronto antes do runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SafeKeyApp());
}

class SafeKeyApp extends StatelessWidget {
  const SafeKeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeKey',
      theme: ThemeData(
        // tema simples e limpo; dá um “ar” consistente nas telas
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        IntroScreen.route: (_) => const IntroScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        // AuthGate impede acesso a telas internas sem login
        HomeScreen.route: (_) => const AuthGate(child: HomeScreen()),
        NewPasswordScreen.route: (_) =>
            const AuthGate(child: NewPasswordScreen()),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Gate simples pra bloquear rotas se não tiver user logado
class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == null) {
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}
