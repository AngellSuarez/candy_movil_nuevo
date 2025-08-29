import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';

class ServicesOverviewCard extends StatelessWidget {
  final List<Map<String, dynamic>> popularServices;
  final VoidCallback? onViewAll;

  const ServicesOverviewCard({
    Key? key,
    required this.popularServices,
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
                  'Servicios Populares',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'Ver todos',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          popularServices.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Center(
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'spa',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No hay servicios disponibles',
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
                  itemCount: popularServices.length > 4
                      ? 4
                      : popularServices.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final service = popularServices[index];
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
                              color: AppTheme.lightTheme.colorScheme.secondary
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: service['image'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CustomImageWidget(
                                      imageUrl: service['image'] as String,
                                      width: 12.w,
                                      height: 12.w,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: CustomIconWidget(
                                      iconName: 'spa',
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .secondary,
                                      size: 20,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'] as String,
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
                                  '${service['bookings']} reservas',
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
                              SizedBox(height: 0.5.h),
                              Container(
                                width: 8.w,
                                height: 1.h,
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      (service['popularity'] as num) / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
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
}
