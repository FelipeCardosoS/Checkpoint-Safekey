// Intro: 3 telas curtas explicando o app (com Lottie).
// Marca “não mostrar novamente” via SharedPreferences.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  static const route = '/intro';
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _dontShowAgain = false;

  // troca os textos conforme for apresentar
  final _pages = const [
    (
      'Bem-vindo ao SafeKey',
      'Gere e salve senhas fortes com poucos toques.',
      'assets/lottie/intro1.json'
    ),
    (
      'Tudo na nuvem',
      'Autenticação com Firebase e senhas no Firestore.',
      'assets/lottie/intro2.json'
    ),
    (
      'Seu fluxo',
      'Ajuste tamanho e tipos e salve com um rótulo.',
      'assets/lottie/intro3.json'
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    // se marcar pra não mostrar, a próxima inicialização vai direto pro app
    await prefs.setBool('show_intro', !_dontShowAgain);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // logo pequeno pra dar identidade
            Image.asset('assets/images/logo.png', height: 24),
            const SizedBox(width: 8),
            const Text('Introdução'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) {
                final (title, subtitle, anim) = _pages[i];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(anim, height: 220),
                      const SizedBox(height: 16),
                      Text(title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center),
                      if (i == _pages.length - 1) ...[
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _dontShowAgain,
                              onChanged: (v) =>
                                  setState(() => _dontShowAgain = v ?? false),
                            ),
                            const Text('Não mostrar novamente'),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // navegação da intro (voltar/avançar ou concluir)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _index == 0
                      ? null
                      : () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                  child: const Text('Voltar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(
                      _index == _pages.length - 1 ? 'Concluir' : 'Avançar'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
