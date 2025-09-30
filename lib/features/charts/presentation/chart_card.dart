import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'provider.dart';

class SalesChartCard extends StatelessWidget {
  const SalesChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesChartProvider>();
    final chart = provider.chart;

    if (provider.loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (provider.failure != null) {
      return Card(
        color: Colors.red[50],
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Error: Can't load chart",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (chart == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item-wise Sales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  groupsSpace: 18,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.black,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toStringAsFixed(0),
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return index < chart.labels.length
                              ? SideTitleWidget(
                                meta: meta,
                                child: Transform.rotate(
                                  angle:
                                      -0.6, // rotate ~ -35° so they don’t overlap
                                  child: Text(
                                    chart.labels[index],
                                    style: const TextStyle(fontSize: 9),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget:
                            (value, meta) => SideTitleWidget(
                              meta: meta,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(chart.values.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: chart.values[i],
                          width: 16,
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
