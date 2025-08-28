import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_exports.dart';

class NewPasswordStep extends StatefulWidget {
  final Function(String) onPasswordReset;
  final Function() onBackPressed;
  final bool isLoading;

  const NewPasswordStep({
    Key? key,
    required this.onPasswordReset,
    required this.onBackPressed,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<NewPasswordStep> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePasswordMatch);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  bool get _isPasswordStrong {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  bool get _canSubmit {
    return _isPasswordStrong && _passwordsMatch && !widget.isLoading;
  }

  String? _validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (!_isPasswordStrong) {
      return 'La contraseña no cumple con los requisitos';
    }
    return null;
  }

  String? _validateConfirmPasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onPasswordReset(_passwordController.text);
    }
  }

  Color _getStrengthColor() {
    final strengthCount = [
      _hasMinLength,
      _hasUppercase,
      _hasLowercase,
      _hasNumber,
      _hasSpecialChar,
    ].where((condition) => condition).length;

    if (strengthCount <= 2) return AppTheme.lightTheme.colorScheme.error;
    if (strengthCount <= 4) return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.primary;
  }

  String _getStrengthText() {
    final strengthCount = [
      _hasMinLength,
      _hasUppercase,
      _hasLowercase,
      _hasNumber,
      _hasSpecialChar,
    ].where((condition) => condition).length;

    if (strengthCount <= 2) return 'Débil';
    if (strengthCount <= 4) return 'Media';
    return 'Fuerte';
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validatePasswordMatch);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: widget.isLoading ? null : widget.onBackPressed,
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
              Expanded(
                child: Text(
                  'Nueva Contraseña',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12.w), // Balance the back button
            ],
          ),
          SizedBox(height: 2.h),

          // Description
          Text(
            'Crea una nueva contraseña segura para tu cuenta. Asegúrate de que cumpla con todos los requisitos.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // New password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            enabled: !widget.isLoading,
            validator: _validatePasswordField,
            decoration: InputDecoration(
              labelText: 'Nueva Contraseña',
              hintText: 'Ingresa tu nueva contraseña',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: CustomIconWidget(
                  iconName: _isPasswordVisible
                      ? 'visibility_off'
                      : 'visibility',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Password strength indicator
          if (_passwordController.text.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Fortaleza: ',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _getStrengthText(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getStrengthColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            LinearProgressIndicator(
              value:
                  [
                    _hasMinLength,
                    _hasUppercase,
                    _hasLowercase,
                    _hasNumber,
                    _hasSpecialChar,
                  ].where((condition) => condition).length /
                  5,
              backgroundColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
            ),
            SizedBox(height: 2.h),
          ],

          // Password requirements
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requisitos de la contraseña:',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildRequirement('Al menos 8 caracteres', _hasMinLength),
                _buildRequirement('Una letra mayúscula', _hasUppercase),
                _buildRequirement('Una letra minúscula', _hasLowercase),
                _buildRequirement('Un número', _hasNumber),
                _buildRequirement(
                  'Un carácter especial (!@#\$%^&*)',
                  _hasSpecialChar,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            enabled: !widget.isLoading,
            validator: _validateConfirmPasswordField,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              hintText: 'Confirma tu nueva contraseña',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_passwordsMatch &&
                      _confirmPasswordController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: _isConfirmPasswordVisible
                          ? 'visibility_off'
                          : 'visibility',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),

          // Submit button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: _canSubmit ? _handleSubmit : null,
              child: widget.isLoading
                  ? SizedBox(
                      height: 5.w,
                      width: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Restablecer Contraseña',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isMet ? 'check_circle' : 'radio_button_unchecked',
            color: isMet
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isMet
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
