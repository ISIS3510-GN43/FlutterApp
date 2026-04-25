import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class ProfileView extends StatelessWidget {
  final Usuario usuario;

  const ProfileView({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDEE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF2C666E),
                backgroundImage: usuario.foto.isNotEmpty
                    ? NetworkImage(usuario.foto)
                    : null,
                child: usuario.foto.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 24),
              _InfoRow(label: 'Username', value: usuario.username),
              _InfoRow(label: 'Email', value: usuario.gmail),
              _InfoRow(label: 'Birthday', value: usuario.cumpleanios),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final authViewModel = AuthViewModel();
                  await authViewModel.logout();
                  authViewModel.dispose();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07393C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Color(0xFF07393C),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }
}
