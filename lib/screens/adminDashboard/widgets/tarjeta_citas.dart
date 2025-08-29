import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';

class AppointmentOverviewCard extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final VoidCallback? onViewAll;

  const AppointmentOverviewCard({
    Key? key,
    required this.appointments,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(
              alpha: 0.1,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Próximas Citas',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'Ver todas',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          appointments.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Center(
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'event_available',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No hay citas programadas',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length > 3 ? 3 : appointments.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to appointment details
                      },
                      onLongPress: () {
                        _showQuickActions(context, appointment);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 3.w,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.secondary
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  (appointment['time'] as String).substring(
                                    0,
                                    2,
                                  ),
                                  style: AppTheme.dataTextStyleBold(
                                    isLight: true,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment['clientName'] as String,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    (appointment['services'] as List).join(
                                      ', ',
                                    ),
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  appointment['time'] as String,
                                  style: AppTheme.dataTextStyle(
                                    isLight: true,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      appointment['status'] as String,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    appointment['status'] as String,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _getStatusColor(
                                            appointment['status'] as String,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terminada':
        return const Color(0xFF27AE60);
      case 'pendiente':
        return const Color(0xFFF39C12);
      case 'cancelada':
        return const Color(0xFFE74C3C);
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  void _showQuickActions(
    BuildContext context,
    Map<String, dynamic> appointment,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Acciones Rápidas',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Reprogramar'),
              onTap: () {
                Navigator.pop(context);
                // Handle reschedule
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'cancel',
                color: const Color(0xFFE74C3C),
                size: 24,
              ),
              title: const Text('Cancelar'),
              onTap: () {
                Navigator.pop(context);
                // Handle cancel
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'phone',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
              title: const Text('Contactar Cliente'),
              onTap: () {
                Navigator.pop(context);
                // Handle contact
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
