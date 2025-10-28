// Serviço de geração de senha.
// 1) Tenta a API oficial do checkpoint (POST /generate conforme Swagger).
// 2) Se falhar (rede/endpoint fora), gera localmente pra não travar a demo.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class PasswordApiService {
  final String baseUrl;
  PasswordApiService({
    this.baseUrl = 'https://safekey-api-a1bd9aa97953.herokuapp.com',
  });

  Future<String> generatePassword({
    int length = 16,
    bool uppercase = true,
    bool lowercase = true,
    bool numbers = true,
    bool symbols = false,
  }) async {
    final uri = Uri.parse('$baseUrl/generate');
    final body = {
      'length': length,
      'includeLowercase': lowercase,
      'includeUppercase': uppercase,
      'includeNumbers': numbers,
      'includeSymbols': symbols,
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      // Log básico pra debugar retorno
      // ignore: avoid_print
      print('[PasswordApi] POST $uri -> ${res.statusCode} ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // contrato esperado: {"password": "..."}
        if (data is Map && data['password'] is String) {
          return data['password'] as String;
        }
        // fallback pra texto
        return res.body.toString().trim();
      }

      throw Exception('API ${res.statusCode}: ${res.body}');
    } catch (e) {
      // se não deu certo, gera local (evita bloquear a apresentação)
      // ignore: avoid_print
      print('[PasswordApi] Falha na API, usando gerador local: $e');
      return _localGenerate(
        length: length,
        uppercase: uppercase,
        lowercase: lowercase,
        numbers: numbers,
        symbols: symbols,
      );
    }
  }

  // Gerador local simples, com garantia de pelo menos 1 char de cada grupo marcado
  String _localGenerate({
    required int length,
    required bool uppercase,
    required bool lowercase,
    required bool numbers,
    required bool symbols,
  }) {
    const upp = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const low = 'abcdefghijklmnopqrstuvwxyz';
    const num = '0123456789';
    const sym = r'!@#$%^&*()-_=+[]{};:,.?/';

    var pool = '';
    if (uppercase) pool += upp;
    if (lowercase) pool += low;
    if (numbers) pool += num;
    if (symbols) pool += sym;
    if (pool.isEmpty) pool = low; // evita string vazia

    final rand = Random.secure();
    final buf = StringBuffer();

    final groups = <String>[];
    if (uppercase) groups.add(upp);
    if (lowercase) groups.add(low);
    if (numbers) groups.add(num);
    if (symbols) groups.add(sym);

    // garante diversidade mínima
    for (final g in groups) {
      buf.write(g[rand.nextInt(g.length)]);
    }
    // completa até o tamanho pedido
    while (buf.length < length) {
      buf.write(pool[rand.nextInt(pool.length)]);
    }
    // embaralha a ordem
    final chars = buf.toString().split('');
    for (var i = chars.length - 1; i > 0; i--) {
      final j = rand.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    return chars.join();
  }
}
