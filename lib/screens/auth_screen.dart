import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _isSignInMode = true;

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignInMode = !_isSignInMode;
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleSignIn(AuthProvider auth, ProjectProvider projects) async {
    final form = _signInFormKey.currentState;
    if (form == null || !form.validate()) return;

    final success = await auth.signIn(
      email: _signInEmailController.text.trim(),
      password: _signInPasswordController.text,
    );

    if (!success) {
      _showError(auth.error);
      return;
    }

    await _navigateToHome(projects);
  }

  Future<void> _handleSignUp(AuthProvider auth, ProjectProvider projects) async {
    final form = _signUpFormKey.currentState;
    if (form == null || !form.validate()) return;

    final success = await auth.signUp(
      name: _signUpNameController.text.trim(),
      email: _signUpEmailController.text.trim(),
      password: _signUpPasswordController.text,
    );

    if (!success) {
      _showError(auth.error);
      return;
    }

    await _navigateToHome(projects);
  }

  Future<void> _navigateToHome(ProjectProvider projects) async {
    await projects.loadProjects();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showError(String? message) {
    if (!mounted || message == null || message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final projects = context.read<ProjectProvider>();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('assets/images/logo.png', height: 120),
                      const SizedBox(height: 24),
                      Text(
                        _isSignInMode ? 'Selamat datang kembali' : 'Buat akun',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF2D3436),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSignInMode
                            ? 'Masuk untuk melanjutkan mengelola proyek Anda.'
                            : 'Lengkapi formulir di bawah ini untuk memulai.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF636E72),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _isSignInMode
                            ? _buildSignInForm(auth, projects)
                            : _buildSignUpForm(auth, projects),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: auth.isLoading ? null : _toggleMode,
                        child: Text(
                          _isSignInMode
                              ? "Belum punya akun? Daftar"
                              : 'Sudah punya akun? Masuk',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(AuthProvider auth, ProjectProvider projects) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signInEmailController,
            decoration: _inputDecoration('Email'),
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signInPasswordController,
            decoration: _inputDecoration('Kata Sandi'),
            obscureText: true,
            validator: _passwordValidator,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: auth.isLoading
                ? null
                : () => _handleSignIn(auth, projects),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFE07A5F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Masuk',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(AuthProvider auth, ProjectProvider projects) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signUpNameController,
            decoration: _inputDecoration('Nama'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signUpEmailController,
            decoration: _inputDecoration('Email'),
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signUpPasswordController,
            decoration: _inputDecoration('Kata Sandi (min. 8 karakter)'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Kata sandi minimal harus 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: auth.isLoading
                ? null
                : () => _handleSignUp(auth, projects),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFE07A5F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Daftar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.4),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
      ),
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email harus diisi';
    }
    if (!value.contains('@')) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.length < 6) {
      return 'Kata sandi minimal harus 6 karakter';
    }
    return null;
  }
}
