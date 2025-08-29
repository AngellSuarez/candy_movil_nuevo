import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';
import '../../../theme/app_theme.dart';
import 'widgets/login_form_widget.dart';
import 'widgets/salon_logo_widget.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.checkLogin(email, password);

    if (authProvider.isAuthenticated) {
      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );

        // Redirección según el rol
        final userRole = authProvider
            .userRole; // Asegúrate de que AuthProvider exponga el rol
        if (userRole == 'Admin' || userRole == 'Administrador') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (userRole == 'Cliente') {
          Navigator.pushReplacementNamed(context, '/cliente-dashboard');
        } else if (userRole == 'Manicurista') {
          Navigator.pushReplacementNamed(context, '/manicurista-dashboard');
        } else {
          // Rol desconocido, redirigir a una pantalla por defecto
          Navigator.pushReplacementNamed(context, '/news-feed');
        }
      }
    } else {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorDialog(
          'Error de inicio de sesión',
          'El correo electrónico o la contraseña son incorrectos.',
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Entendido',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),
                      SalonLogoWidget(),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4.w),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.shadow
                                  .withValues(alpha: 0.1),
                              blurRadius: 2.w,
                              offset: Offset(0, 1.w),
                            ),
                          ],
                        ),
                        child: LoginFormWidget(
                          onLogin: _handleLogin,
                          isLoading: authProvider.isLoading,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Column(
                          children: [
                            Text(
                              'Versión 1.0.0',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '© 2024 Candysoft. Todos los derechos reservados.',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                    fontSize: 10.sp,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
