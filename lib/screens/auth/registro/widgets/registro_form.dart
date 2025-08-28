import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RegistrationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController usernameController;
  final TextEditingController correoController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController tipoDocumentoController;
  final TextEditingController numeroDocumentoController;
  final TextEditingController celularController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.apellidoController,
    required this.usernameController,
    required this.correoController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.tipoDocumentoController,
    required this.numeroDocumentoController,
    required this.celularController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
  });

  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $field es obligatorio';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (v) => _validateRequired(v, 'Nombre'),
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: apellidoController,
            decoration: const InputDecoration(labelText: 'Apellido'),
            validator: (v) => _validateRequired(v, 'Apellido'),
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            validator: (v) => _validateRequired(v, 'Usuario'),
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: correoController,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          SizedBox(height: 2.h),

          DropdownButtonFormField<String>(
            value: null,
            items: [
              'CC',
              'CE',
              'TI',
              'PA',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {
              tipoDocumentoController.text = value ?? '';
            },
            decoration: const InputDecoration(labelText: 'Tipo de documento'),
            validator: (v) =>
                v == null || v.isEmpty ? 'Seleccione un tipo' : null,
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: numeroDocumentoController,
            decoration: const InputDecoration(labelText: 'Número de documento'),
            keyboardType: TextInputType.number,
            validator: (v) => _validateRequired(v, 'Número de documento'),
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: celularController,
            decoration: const InputDecoration(labelText: 'Celular'),
            keyboardType: TextInputType.phone,
            validator: (v) => _validateRequired(v, 'Celular'),
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                onPressed: onPasswordVisibilityToggle,
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            validator: _validatePassword,
          ),
          SizedBox(height: 2.h),

          TextFormField(
            controller: confirmPasswordController,
            obscureText: !isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              suffixIcon: IconButton(
                onPressed: onConfirmPasswordVisibilityToggle,
                icon: Icon(
                  isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),
            validator: _validateConfirmPassword,
          ),
        ],
      ),
    );
  }
}
