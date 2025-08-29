import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';

class StaffPerformanceCard extends StatelessWidget {
  final List<Map<String, dynamic>> staffPerformance;
  final VoidCallback? onViewAll;

  const StaffPerformanceCard({
    Key? key,
    required this.staffPerformance,
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
                  'Rendimiento del Personal',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'Ver detalles',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          staffPerformance.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Center(
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'people',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No hay datos de personal',
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
                  itemCount: staffPerformance.length > 3
                      ? 3
                      : staffPerformance.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final staff = staffPerformance[index];
                    return Padding(
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
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: staff['avatar'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: CustomIconWidget(
                                      iconName: staff['avatar'] as String,
                                      size: 12.w,
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      (staff['name'] as String)
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.w600,
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
                                  staff['name'] as String,
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
                                  '${staff['completedAppointments']} citas completadas',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'star',
                                    color: const Color(0xFFF39C12),
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    staff['rating'].toString(),
                                    style: AppTheme.dataTextStyleBold(
                                      isLight: true,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPerformanceColor(
                                    staff['performance'] as String,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  staff['performance'] as String,
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: _getPerformanceColor(
                                          staff['performance'] as String,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(String performance) {
    switch (performance.toLowerCase()) {
      case 'excelente':
        return const Color(0xFF27AE60);
      case 'bueno':
        return const Color(0xFF3498DB);
      case 'regular':
        return const Color(0xFFF39C12);
      case 'bajo':
        return const Color(0xFFE74C3C);
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
