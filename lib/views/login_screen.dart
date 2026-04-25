import 'package:app_flutter/views/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import '../models/repositories/auth_repository.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_schedule_viewmodel.dart';
import 'friends_screen.dart';
import 'app_nav.dart';
import 'nrc_screen.dart';
import 'profile_view.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthViewModel _authViewModel = AuthViewModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    final success = await _authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final usuario = _authViewModel.usuarioActual!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', usuario.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainShell(userId: usuario.id, usuario: usuario),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authViewModel.errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authViewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0EDEE),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      "QEE",
                      style: TextStyle(
                        fontSize: 40,
                        color: Color(0xFF2C666E),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _authViewModel.isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07393C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _authViewModel.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Dont have an account? Register',
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

class MainShell extends StatefulWidget {
  final String userId;
  final Usuario? usuario;

  const MainShell({super.key, required this.userId, this.usuario});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final HomeScheduleViewModel _scheduleViewModel;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _scheduleViewModel = HomeScheduleViewModel(userId: widget.userId);
    _usuario = widget.usuario;
    if (_usuario == null) {
      _loadUsuario();
    }
  }

  Future<void> _loadUsuario() async {
    try {
      final repo = AuthRepository();
      final user = await repo.fetchUsuario(widget.userId);
      if (mounted) setState(() => _usuario = user);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CalendarView(
            userId: widget.userId,
            viewModel: _scheduleViewModel,
            showBottomNav: false,
          ),
          FriendsScreen(userId: widget.userId),
          const Center(child: Text('Grades')),
          _usuario != null
              ? ProfileView(usuario: _usuario!)
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF07393C),
              foregroundColor: Colors.white,
              onPressed: () {
                final horarioId = _scheduleViewModel.horarioId;
                if (horarioId == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NrcScreen(
                      userId: widget.userId,
                      horarioId: horarioId,
                    ),
                  ),
                ).then((_) => _scheduleViewModel.loadSchedule());
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}