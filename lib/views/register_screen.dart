import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthViewModel _authViewModel = AuthViewModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _selectedImage;
  bool _uploadingPhoto = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String> _uploadPhoto(String userId) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profiles/$userId/foto.jpg');
    await ref.putFile(_selectedImage!);
    return ref.getDownloadURL();
  }

  Future<void> _registerUser() async {
    setState(() => _uploadingPhoto = _selectedImage != null);

    final usuario = Usuario(
      id: '',
      foto: '',
      gmail: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      cumpleanios: '',
      amigosIds: [],
      amigosUsernames: [],
      horarios: [],
      solicitudes: [],
      eventos: [],
    );

    final success = await _authViewModel.register(usuario);

    if (!mounted) return;

    if (success) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final loginSuccess = await _authViewModel.login(email, password);

      if (!mounted) return;

      if (loginSuccess) {
        var registeredUser = _authViewModel.usuarioActual!;

        if (_selectedImage != null) {
          try {
            final photoUrl = await _uploadPhoto(registeredUser.id);
            registeredUser.foto = photoUrl;
          } catch (_) {
          }
        }

        setState(() => _uploadingPhoto = false);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', registeredUser.id);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainShell(userId: registeredUser.id, usuario: registeredUser),
          ),
          (_) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authViewModel.errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF2C666E),
            backgroundImage:
                _selectedImage != null ? FileImage(_selectedImage!) : null,
            child: _selectedImage == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF07393C),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authViewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0EDEE),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "WOR",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      "QEEE",
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xFF2C666E),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create you account',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF07393C),
                  ),
                ),
                const SizedBox(height: 32),
                _buildPhotoPicker(),
                const SizedBox(height: 8),
                const Text(
                  'Tap to add a profile photo (optional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    color: Color(0xFF07393C),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_authViewModel.isLoading || _uploadingPhoto)
                      ? null
                      : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07393C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: (_authViewModel.isLoading || _uploadingPhoto)
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Have an account? Login',
                    style: TextStyle(color: Color(0xFF2C666E)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}