import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_exports.dart';

class SalonLogoWidget extends StatelessWidget {
  const SalonLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo container con fondo gradiente
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.8,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 3.w,
                  offset: Offset(0, 1.w),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'spa',
                color: Colors.white,
                size: 12.w,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          //app nombre
          Text(
            'Candy Nails',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 0.5.h),

          //subtitulo
          Text(
            'Bienvenido',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
            ),
          ),

          SizedBox(height: 1.h),

          //frase
          Text(
            'Gestiona tus citas profesionalmente',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
