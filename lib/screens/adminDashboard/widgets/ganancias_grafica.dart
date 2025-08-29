import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_exports.dart';
import '../../../theme/app_theme.dart';

class RevenueChartCard extends StatefulWidget {
  final Map<String, dynamic> revenueData;

  const RevenueChartCard({Key? key, required this.revenueData})
    : super(key: key);

  @override
  State<RevenueChartCard> createState() => _RevenueChartCardState();
}

class _RevenueChartCardState extends State<RevenueChartCard> {
  String selectedPeriod = 'Semanal';
  final List<String> periods = ['Diario', 'Semanal', 'Mensual'];

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
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ingresos',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPeriod,
                      isDense: true,
                      items: periods.map((String period) {
                        final hasData = widget.revenueData.containsKey(
                          period.toLowerCase(),
                        );
                        return DropdownMenuItem<String>(
                          value: period,
                          enabled: hasData,
                          child: Text(
                            period,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color: hasData
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            widget.revenueData.containsKey(
                              newValue.toLowerCase(),
                            )) {
                          setState(() {
                            selectedPeriod = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '\$${_getCurrentPeriodRevenue()}',
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _getPeriodSubtitle(),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            _buildChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final chartData = _getChartData();
    if (chartData.isEmpty) {
      return SizedBox(
        height: 20.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'show_chart',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 48,
              ),
              SizedBox(height: 1.h),
              Text(
                'No hay datos disponibles',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxY = _getMaxY(chartData);
    final minY = _getMinY(chartData);

    return SizedBox(
      height: 20.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 5 : 1000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      _getBottomTitle(value.toInt()),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY > 0 ? maxY / 5 : 1000,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    _formatCurrency(value),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
                reservedSize: 50,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.2,
              ),
            ),
          ),
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
          minY: minY * 0.9,
          maxY: maxY * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.lightTheme.colorScheme.secondary,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    strokeWidth: 2,
                    strokeColor: AppTheme.lightTheme.colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                    AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentPeriodRevenue() {
    final data =
        widget.revenueData[selectedPeriod.toLowerCase()]
            as Map<String, dynamic>?;
    final total = data?['total']?.toString() ?? '0';

    // Handle both string and number formats
    if (total.contains('.')) {
      final number = double.tryParse(total) ?? 0.0;
      return number.toStringAsFixed(0);
    }
    return total;
  }

  String _getPeriodSubtitle() {
    switch (selectedPeriod) {
      case 'Diario':
        return 'Promedio diario esta semana';
      case 'Semanal':
        return 'Esta semana (25-31 agosto)';
      case 'Mensual':
        return 'Este mes (estimado)';
      default:
        return '';
    }
  }

  List<FlSpot> _getChartData() {
    final data =
        widget.revenueData[selectedPeriod.toLowerCase()]
            as Map<String, dynamic>?;
    final chartData = data?['chartData'] as List<dynamic>? ?? [];

    if (chartData.isEmpty) return [];

    return chartData.asMap().entries.map((entry) {
      final value = entry.value;
      double yValue;

      if (value is num) {
        yValue = value.toDouble();
      } else if (value is String) {
        yValue = double.tryParse(value) ?? 0.0;
      } else {
        yValue = 0.0;
      }

      return FlSpot(entry.key.toDouble(), yValue);
    }).toList();
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 5000;
    final maxValue = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue : 5000;
  }

  double _getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    final minValue = spots
        .map((spot) => spot.y)
        .reduce((a, b) => a < b ? a : b);
    return minValue < 0 ? minValue : 0;
  }

  String _getBottomTitle(int index) {
    switch (selectedPeriod) {
      case 'Diario':
      case 'Semanal':
        const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        return index < days.length ? days[index] : '';
      case 'Mensual':
        const weeks = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'];
        return index < weeks.length ? weeks[index] : '';
      default:
        return index.toString();
    }
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  }
}
