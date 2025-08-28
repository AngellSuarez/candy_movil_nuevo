import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';
import './widgets/verificar_codigo.dart';
import './widgets/correo_input.dart';
import './widgets/nueva_password_input.dart';
import './widgets/mensaje_correcto.dart';
import '../../../services/auth/auth_service.dart';

/// Utilidad para mostrar mensajes multiplataforma
class AppNotifier {
  static void showMessage(
    BuildContext context,
    String msg, {
    bool error = false,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      // Linux / Windows / macOS
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error
              ? AppTheme.lightTheme.colorScheme.error
              : AppTheme.lightTheme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  String _currentEmail = '';
  String _currentCode = '';
  bool _isLoading = false;

  /// Enviar correo a la API
  void _handleEmailSubmit(String email) async {
    setState(() => _isLoading = true);
    final result = await AuthService().solicitarCodigoRecuperacion(email);
    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _currentEmail = email);
      _nextStep();
    } else {
      AppNotifier.showMessage(context, result['message'], error: true);
    }
  }

  /// Guardar el código ingresado (la API lo valida en el reset final)
  void _handleCodeVerify(String code) async {
    setState(() => _currentCode = code);
    _nextStep();
  }

  /// Resetear contraseña en la API
  void _handlePasswordReset(String password) async {
    setState(() => _isLoading = true);
    final result = await AuthService().confirmarResetPassword(
      correo: _currentEmail,
      codigo: _currentCode,
      newPassword: password,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccessDialog();
    } else {
      AppNotifier.showMessage(context, result['message'], error: true);
    }
  }

  /// Reenviar código
  void _handleResendCode() async {
    final result = await AuthService().solicitarCodigoRecuperacion(
      _currentEmail,
    );
    if (result['success']) {
      AppNotifier.showMessage(context, 'Código reenviado exitosamente');
    } else {
      AppNotifier.showMessage(context, result['message'], error: true);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        onContinue: () {
          Navigator.of(context).pop(); // Cierra el dialog
          Navigator.of(context).pop(); // Vuelve al login
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progreso
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentStep;
                  final isCompleted = index < _currentStep;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      height: 1.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0.5.h),
                        color: isActive
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                      ),
                      child: isCompleted
                          ? Center(
                              child: CustomIconWidget(
                                iconName: 'check',
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                size: 3.w,
                              ),
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),

            // Títulos de pasos
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepLabel('Email', 0),
                  _buildStepLabel('Código', 1),
                  _buildStepLabel('Contraseña', 2),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: 70.h),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: SizedBox(
                    height: 70.h,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Paso 1: Email
                        Center(
                          child: EmailInputStep(
                            onEmailSubmit: _handleEmailSubmit,
                            isLoading: _isLoading,
                          ),
                        ),

                        // Paso 2: Código
                        Center(
                          child: CodeVerificationStep(
                            email: _currentEmail,
                            onCodeVerify: _handleCodeVerify,
                            onResendCode: _handleResendCode,
                            onBackPressed: _previousStep,
                            isLoading: _isLoading,
                          ),
                        ),

                        // Paso 3: Nueva contraseña
                        Center(
                          child: NewPasswordStep(
                            onPasswordReset: _handlePasswordReset,
                            onBackPressed: _previousStep,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLabel(String label, int stepIndex) {
    final isActive = stepIndex <= _currentStep;

    return Text(
      label,
      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: isActive
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
