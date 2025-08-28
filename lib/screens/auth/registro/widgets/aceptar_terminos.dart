import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_exports.dart';
import '../../../../theme/app_theme.dart';

class TermsAcceptanceWidget extends StatelessWidget {
  final bool isTermsAccepted;
  final ValueChanged<bool?> onTermsChanged;

  const TermsAcceptanceWidget({
    super.key,
    required this.isTermsAccepted,
    required this.onTermsChanged,
  });

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Política de Privacidad',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SizedBox(
            width: 80.w,
            height: 60.h,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CandySoft Salon - Política de Privacidad',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Última actualización: 22 de agosto de 2025',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  SizedBox(height: 2.h),
                  _buildPolicySection(
                    'Información que Recopilamos',
                    'Recopilamos información personal como nombre, correo electrónico, número de teléfono y datos de citas para brindar nuestros servicios de salón de belleza.',
                  ),
                  _buildPolicySection(
                    'Uso de la Información',
                    'Utilizamos su información para gestionar citas, enviar recordatorios, procesar pagos y mejorar nuestros servicios.',
                  ),
                  _buildPolicySection(
                    'Protección de Datos',
                    'Implementamos medidas de seguridad técnicas y organizativas para proteger su información personal contra acceso no autorizado.',
                  ),
                  _buildPolicySection(
                    'Sus Derechos',
                    'Tiene derecho a acceder, rectificar, eliminar y portar sus datos personales. Puede ejercer estos derechos contactándonos.',
                  ),
                  _buildPolicySection(
                    'Contacto',
                    'Para consultas sobre privacidad, contáctenos en: privacy@candysoftsalon.com',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(content, style: AppTheme.lightTheme.textTheme.bodyMedium),
        SizedBox(height: 2.h),
      ],
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Términos de Servicio',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: SizedBox(
            width: 80.w,
            height: 60.h,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CandySoft Salon - Términos de Servicio',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Última actualización: 22 de agosto de 2025',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  SizedBox(height: 2.h),
                  _buildPolicySection(
                    'Aceptación de Términos',
                    'Al usar nuestra aplicación, acepta estos términos de servicio y se compromete a cumplir con todas las políticas aplicables.',
                  ),
                  _buildPolicySection(
                    'Servicios Ofrecidos',
                    'Ofrecemos servicios de gestión de citas para salones de belleza, incluyendo reservas, recordatorios y gestión de pagos.',
                  ),
                  _buildPolicySection(
                    'Responsabilidades del Usuario',
                    'Los usuarios deben proporcionar información precisa, mantener la confidencialidad de sus credenciales y usar el servicio de manera apropiada.',
                  ),
                  _buildPolicySection(
                    'Política de Cancelación',
                    'Las citas pueden cancelarse hasta 24 horas antes del servicio programado. Cancelaciones tardías pueden estar sujetas a cargos.',
                  ),
                  _buildPolicySection(
                    'Limitación de Responsabilidad',
                    'CandySoft Salon no será responsable por daños indirectos, incidentales o consecuentes derivados del uso de la aplicación.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isTermsAccepted,
            onChanged: onTermsChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 0.5.h),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'Términos de Servicio',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showTermsOfService(context),
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showPrivacyPolicy(context),
                    ),
                    const TextSpan(text: ' de CandySoft Salon.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
