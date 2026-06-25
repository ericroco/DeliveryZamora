import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/auth/auth_provider.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isRegister = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _phoneCtrl.text.length >= 9 && _passwordCtrl.text.length >= 6;

  Future<void> _submit() async {
    final phone = '+593${_phoneCtrl.text.trim()}';
    final password = _passwordCtrl.text;
    final notifier = ref.read(authStateProvider.notifier);

    if (_isRegister) {
      await notifier.register(phone, password);
    } else {
      await notifier.login(phone, password);
    }

    final authState = ref.read(authStateProvider);
    if (!mounted) return;

    authState.when(
      data: (user) {
        if (user != null) context.go('/');
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString())),
            backgroundColor: Colors.red.shade700,
          ),
        );
      },
      loading: () {},
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('401') || raw.contains('Invalid credentials')) {
      return 'Número o contraseña incorrectos';
    }
    if (raw.contains('409') || raw.contains('already registered')) {
      return 'Este número ya está registrado';
    }
    if (raw.contains('SocketException') || raw.contains('connection')) {
      return 'Sin conexión al servidor';
    }
    return 'Algo salió mal. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final loading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isRegister ? 'Crear cuenta' : 'Bienvenido\nde vuelta',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa tu número y contraseña para continuar.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              // Phone field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.inputBorder),
                        ),
                      ),
                      child: const Text(
                        '🇪🇨 +593',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: '09XXXXXXXX',
                          hintStyle: TextStyle(color: AppColors.muted),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Password field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    hintStyle: const TextStyle(color: AppColors.muted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canSubmit && !loading ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.caseroBorder,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isRegister ? 'Crear cuenta' : 'Ingresar',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isRegister = !_isRegister),
                  child: Text(
                    _isRegister
                        ? '¿Ya tienes cuenta? Ingresar'
                        : '¿No tienes cuenta? Registrarte',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Al continuar aceptas nuestros Términos de Servicio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
