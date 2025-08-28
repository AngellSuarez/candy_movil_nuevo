import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_exports.dart';

class CodeVerificationStep extends StatefulWidget {
  final String email;
  final Function(String) onCodeVerify;
  final Function() onResendCode;
  final Function() onBackPressed;
  final bool isLoading;

  const CodeVerificationStep({
    Key? key,
    required this.email,
    required this.onCodeVerify,
    required this.onResendCode,
    required this.onBackPressed,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<CodeVerificationStep> createState() => _CodeVerificationStepState();
}

class _CodeVerificationStepState extends State<CodeVerificationStep> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;
  String _currentCode = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }

    // Update current code
    _updateCurrentCode();
  }

  void _updateCurrentCode() {
    final code = _controllers.map((controller) => controller.text).join();
    setState(() {
      _currentCode = code;
    });

    // Auto-verify when 6 digits entered
    if (code.length == 6) {
      widget.onCodeVerify(code);
    }
  }

  void _onPaste(String value) {
    // Handle paste operation
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.length >= 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = cleanValue[i];
      }
      _updateCurrentCode();
      _focusNodes[5].unfocus();
    }
  }

  void _clearCode() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _currentCode = '';
    });
    _focusNodes[0].requestFocus();
  }

  void _handleResend() {
    if (_canResend && !widget.isLoading) {
      widget.onResendCode();
      _startResendTimer();
      _clearCode();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                'Verificar Código',
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
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'Hemos enviado un código de 6 dígitos a\n'),
              TextSpan(
                text: widget.email,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),

        // Code input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 12.w,
              height: 7.h,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                enabled: !widget.isLoading,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.w),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => _onCodeChanged(index, value),
                onTap: () {
                  // Handle paste on any field
                  if (index == 0) {
                    Clipboard.getData(Clipboard.kTextPlain).then((data) {
                      if (data?.text != null) {
                        _onPaste(data!.text!);
                      }
                    });
                  }
                },
              ),
            );
          }),
        ),
        SizedBox(height: 4.h),

        // Loading indicator or verify button
        if (widget.isLoading) ...[
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 6.w,
                  width: 6.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Verificando código...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ] else if (_currentCode.length == 6) ...[
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: () => widget.onCodeVerify(_currentCode),
              child: Text(
                'Verificar Código',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 3.h),

        // Resend code section
        Center(
          child: Column(
            children: [
              Text(
                '¿No recibiste el código?',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 1.h),
              TextButton(
                onPressed: _canResend && !widget.isLoading
                    ? _handleResend
                    : null,
                child: Text(
                  _canResend
                      ? 'Reenviar Código'
                      : 'Reenviar en ${_resendCountdown}s',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: _canResend && !widget.isLoading
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
