import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/chart_point_model.dart';
import '../theme/app_theme.dart';

class PriceChartWidget extends StatelessWidget {
  final List<ChartPoint> points;
  final bool isPositive;
  final Function(ChartPoint?) onTouchPoint;

  const PriceChartWidget({
    super.key,
    required this.points,
    required this.isPositive,
    required this.onTouchPoint,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.green),
        ),
      );
    }

    final double minPrice = points.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    final double maxPrice = points.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    final double padding = (maxPrice - minPrice) * 0.08;

    final spots = <FlSpot>[];
    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].price));
    }

    final chartColor = isPositive ? AppTheme.green : AppTheme.red;

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (points.length - 1).toDouble(),
          minY: (minPrice - padding).clamp(0, double.infinity),
          maxY: maxPrice + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxPrice - minPrice == 0) ? 1 : (maxPrice - minPrice) / 3,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.border.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
              if (!event.isInterestedForInteractions ||
                  touchResponse == null ||
                  touchResponse.lineBarSpots == null ||
                  touchResponse.lineBarSpots!.isEmpty) {
                onTouchPoint(null);
                return;
              }
              final spotIndex = touchResponse.lineBarSpots!.first.spotIndex;
              if (spotIndex >= 0 && spotIndex < points.length) {
                onTouchPoint(points[spotIndex]);
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceElevated,
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.spotIndex;
                  final pt = points[index];
                  final formattedPrice = pt.price >= 1
                      ? NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(pt.price)
                      : '\$${pt.price.toStringAsFixed(6)}';
                  final timeStr = DateFormat('MMM d, HH:mm').format(pt.dateTime);
                  return LineTooltipItem(
                    '$formattedPrice\n$timeStr',
                    const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: chartColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    chartColor.withValues(alpha: 0.28),
                    chartColor.withValues(alpha: 0.0),
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
}
