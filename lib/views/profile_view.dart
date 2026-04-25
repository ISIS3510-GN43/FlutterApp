import 'dart:developer' as dev;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../cache/profile_image_cache_manager.dart';
import '../models/repositories/usuario_repository.dart';
import '../models/usuario.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';

class ProfileView extends StatefulWidget {
  final Usuario usuario;

  const ProfileView({super.key, required this.usuario});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Usuario _usuario;
  bool _uploading = false;
  final _repo = UsuarioRepository();

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final updated = await _repo.cambiarFoto(_usuario.id, File(picked.path));
      // Evict old entry from LRU cache so next paint fetches the new image
      if (_usuario.foto.isNotEmpty) {
        await ProfileImageCacheManager().removeFile(_usuario.foto);
      }
      if (!mounted) return;
      setState(() {
        _usuario = updated;
        _uploading = false;
      });
    } on PhotoUrlResult catch (e) {
      // Backend 2xx but didn't return full Usuario — update foto field locally
      if (_usuario.foto.isNotEmpty) {
        await ProfileImageCacheManager().removeFile(_usuario.foto);
      }
      if (!mounted) return;
      setState(() {
        _usuario.foto = e.url;
        _uploading = false;
      });
    } catch (e, st) {
      dev.log('changePhoto error: $e', stackTrace: st);
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildAvatar() {
    const radius = 50.0;
    final Widget avatar = _usuario.foto.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: _usuario.foto,
            cacheManager: ProfileImageCacheManager(),
            imageBuilder: (_, imageProvider) => CircleAvatar(
              radius: radius,
              backgroundImage: imageProvider,
            ),
            placeholder: (_, __) => const CircleAvatar(
              radius: radius,
              backgroundColor: Color(0xFF2C666E),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            errorWidget: (_, __, ___) => const CircleAvatar(
              radius: radius,
              backgroundColor: Color(0xFF2C666E),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          )
        : const CircleAvatar(
            radius: radius,
            backgroundColor: Color(0xFF2C666E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          );

    return GestureDetector(
      onTap: _uploading ? null : _changePhoto,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          if (_uploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF07393C),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

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
              _buildAvatar(),
              const SizedBox(height: 8),
              const Text(
                'Tap to change photo',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  color: Color(0xFF07393C),
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(label: 'Username', value: _usuario.username),
              _InfoRow(label: 'Email', value: _usuario.gmail),
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
