import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon App',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 10),
                if (user != null) ...[
                  const Icon(Icons.account_circle, color: Colors.white, size: 40),
                  const SizedBox(height: 5),
                  Text(
                    user.email ?? 'Utilisateur connecté',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ] else
                  const Text(
                    'Non connecté',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
              ],
            ),
          ),

          // Section Navigation
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => _go(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.pages),
            title: const Text('Second Page'),
            onTap: () => _go(context, '/second'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Third Page'),
            onTap: () => _go(context, '/third'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Produits'),
            onTap: () => _go(context, '/products'),
          ),

          const Divider(),

          // Section Authentification
          if (user == null) ...[
            // Si pas connecté
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Se connecter'),
              onTap: () => _go(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('S\'inscrire'),
              onTap: () => _go(context, '/register'),
            ),
          ] else ...[
            // Si connecté
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter'),
              onTap: () => _signOut(context),
            ),
          ],
        ],
      ),
    );
  }
}