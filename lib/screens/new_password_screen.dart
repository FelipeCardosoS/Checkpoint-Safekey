// Gera a senha (via API) e salva no Firestore.
// Aqui não mudei o fluxo: só comentários e um about simples.

import 'package:flutter/material.dart';
import '../services/password_api_service.dart';
import '../services/firestore_service.dart';

class NewPasswordScreen extends StatefulWidget {
  static const route = '/new';
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _api = PasswordApiService();
  final _fs = FirestoreService();

  double _length = 16;
  bool _upper = true;
  bool _lower = true;
  bool _numbers = true;
  bool _symbols = false;
  String? _result;
  bool _expansion = true;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      // chamada direta; se a API cair, o serviço já faz fallback local
      final pwd = await _api.generatePassword(
        length: _length.toInt(),
        uppercase: _upper,
        lowercase: _lower,
        numbers: _numbers,
        symbols: _symbols,
      );
      setState(() => _result = pwd);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_result == null || _result!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gere uma senha primeiro.')));
      return;
    }
    final labelController = TextEditingController();
    // pede o rótulo num diálogo simples
    final label = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Salvar senha'),
        content: TextField(
            controller: labelController,
            decoration: const InputDecoration(labelText: 'Rótulo')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, labelController.text.trim()),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (label == null || label.isEmpty) return;
    await _fs.addPassword(label: label, password: _result!);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Senha salva!')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova senha'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'SafeKey',
              applicationVersion: '1.0.0',
              children: const [
                Text('Gera senhas fortes e salva no Firestore por usuário.')
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // bloco dobrável com as opções de geração
            ExpansionPanelList(
              expansionCallback: (_, isOpen) =>
                  setState(() => _expansion = !isOpen),
              children: [
                ExpansionPanel(
                  isExpanded: _expansion,
                  headerBuilder: (_, __) =>
                      const ListTile(title: Text('Opções de geração')),
                  body: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tamanho'),
                          Text(_length.toInt().toString())
                        ],
                      ),
                      Slider(
                        value: _length,
                        min: 6,
                        max: 64,
                        divisions: 58,
                        label: _length.toInt().toString(),
                        onChanged: (v) => setState(() => _length = v),
                      ),
                      SwitchListTile(
                          value: _upper,
                          onChanged: (v) => setState(() => _upper = v),
                          title: const Text('Letras maiúsculas')),
                      SwitchListTile(
                          value: _lower,
                          onChanged: (v) => setState(() => _lower = v),
                          title: const Text('Letras minúsculas')),
                      SwitchListTile(
                          value: _numbers,
                          onChanged: (v) => setState(() => _numbers = v),
                          title: const Text('Números')),
                      SwitchListTile(
                          value: _symbols,
                          onChanged: (v) => setState(() => _symbols = v),
                          title: const Text('Símbolos')),
                      const SizedBox(height: 8),
                      _loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              onPressed: _generate,
                              icon: const Icon(Icons.bolt),
                              label: const Text('Gerar senha'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resultado',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(_result!),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
