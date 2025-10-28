// Flag simples (show_intro) usando SharedPreferences.
// Não obrigatório pra rodar, mas deixa o UX melhor.

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<bool> shouldShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('show_intro') ?? true;
  }

  Future<void> setShowIntro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_intro', value);
  }
}
