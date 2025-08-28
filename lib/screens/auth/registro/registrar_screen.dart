import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';
import './widgets/registro_form.dart';
import '../../../services/auth/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _tipoDocumentoController =
      TextEditingController();
  final TextEditingController _numeroDocumentoController =
      TextEditingController();
  final TextEditingController _celularController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _addFormListeners();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _usernameController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _tipoDocumentoController.dispose();
    _numeroDocumentoController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  void _addFormListeners() {
    _nombreController.addListener(_validateForm);
    _apellidoController.addListener(_validateForm);
    _usernameController.addListener(_validateForm);
    _correoController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _tipoDocumentoController.addListener(_validateForm);
    _numeroDocumentoController.addListener(_validateForm);
    _celularController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('Por favor complete todos los campos correctamente.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final success = await authService.register({
        "nombre": _nombreController.text.trim(),
        "apellido": _apellidoController.text.trim(),
        "username": _usernameController.text.trim(),
        "correo": _correoController.text.trim(),
        "password": _passwordController.text.trim(),
        "tipo_documento": _tipoDocumentoController.text.trim(),
        "numero_documento": _numeroDocumentoController.text.trim(),
        "celular": _celularController.text.trim(),
      });

      if (success) {
        _showSuccessMessage('Registro exitoso. Ahora puede iniciar sesión.');
        Navigator.pop(context); // volver al login
      }
    } catch (e) {
      _showErrorMessage('Error al registrar: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF27AE60),
        duration: const Duration(seconds: 2),
      ),
    );

    // Redirigir después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // volver al login
      }
    });
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 25.w,
                      height: 25.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary,
                            AppTheme.lightTheme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'content_cut',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 12.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'CandySoft Salon',
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Crea tu cuenta y gestiona tus citas',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // Formulario
              RegistrationFormWidget(
                formKey: _formKey,
                nombreController: _nombreController,
                apellidoController: _apellidoController,
                usernameController: _usernameController,
                correoController: _correoController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                tipoDocumentoController: _tipoDocumentoController,
                numeroDocumentoController: _numeroDocumentoController,
                celularController: _celularController,
                isPasswordVisible: _isPasswordVisible,
                isConfirmPasswordVisible: _isConfirmPasswordVisible,
                onPasswordVisibilityToggle: _togglePasswordVisibility,
                onConfirmPasswordVisibilityToggle:
                    _toggleConfirmPasswordVisibility,
              ),

              SizedBox(height: 4.h),

              // Botón crear cuenta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading
                      ? _handleRegistration
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Crear Cuenta'),
                ),
              ),
              SizedBox(height: 3.h),

              // Link a login
              Center(
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
