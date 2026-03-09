import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> categoryProgress; // 0.0 ~ 1.0

  const RadarChartWidget({super.key, required this.categoryProgress});

  @override
  Widget build(BuildContext context) {
    final categories = ['Start', 'Build', 'Scale', 'Invest', 'Final'];
    final values =
        categories.map((c) => categoryProgress[c] ?? 0.0).toList();

    return SizedBox(
      height: 220,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0),
          tickBorderData:
              BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.3)),
          gridBorderData:
              BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.5), width: 1),
          radarBorderData:
              const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          getTitle: (index, _) {
            return RadarChartTitle(
              text: categories[index],
            );
          },
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.accent.withValues(alpha: 0.2),
              borderColor: AppColors.accent,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: values
                  .map((v) => RadarEntry(value: v * 100))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
