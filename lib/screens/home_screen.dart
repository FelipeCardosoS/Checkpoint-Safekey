// Home: lista senhas, copia ao tocar, mostra/oculta, deleta.
// Aqui usei os assets: banner “promo_premium” e imagem de empty state.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import 'new_password_screen.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 24), // logo na AppBar
            const SizedBox(width: 8),
            const Text('SafeKey'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(NewPasswordScreen.route),
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // info rápida do usuário logado
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Logado: ${user.email}',
                style: Theme.of(context).textTheme.bodyMedium),
          ),

          // banner “promo” usando imagem (só visual, sem back-end real)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Lottie.asset(
                'assets/lottie/premium.json',
                height: 90,
                fit: BoxFit.contain, // contain pra não cortar a animação
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fs.passwordsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Erro: ${snap.error}'));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  // estado vazio com imagem dedicada
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/empty_state.png',
                            width: 260),
                        const SizedBox(height: 12),
                        const Text('Nenhuma senha salva ainda.'),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _PasswordTile(
                      id: item['id'],
                      label: item['label'] ?? '(sem rótulo)',
                      password: item['password'] ?? '',
                      onDelete: () => fs.deletePassword(item['id']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordTile extends StatefulWidget {
  final String id;
  final String label;
  final String password;
  final VoidCallback onDelete;
  const _PasswordTile(
      {required this.id,
      required this.label,
      required this.password,
      required this.onDelete});

  @override
  State<_PasswordTile> createState() => _PasswordTileState();
}

class _PasswordTileState extends State<_PasswordTile> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label),
      subtitle: Text(_obscure ? '••••••••••••' : widget.password),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      onTap: () async {
        // copia a senha pro clipboard ao tocar no item (rápido de usar)
        await Clipboard.setData(ClipboardData(text: widget.password));
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Senha copiada!')));
      },
    );
  }
}
