import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'provider.dart';

class SalesChartCard extends StatefulWidget {
  const SalesChartCard({super.key});

  @override
  State<SalesChartCard> createState() => _SalesChartCardState();
}

class _SalesChartCardState extends State<SalesChartCard> {
  double _minFilterValue = 0;

  void _showFilterDialog(SalesChartProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        double tempFilter = _minFilterValue;
        return AlertDialog(
          title: const Text('Filter Minimum Sales'),
          content: Slider(
            min: 0,
            max: provider.chart!.values.reduce((a, b) => a > b ? a : b),
            divisions: 20,
            value: tempFilter,
            label: tempFilter.toStringAsFixed(0),
            onChanged: (val) {
              setState(() {
                tempFilter = val;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _minFilterValue = tempFilter;
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Error: Can't load chart",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (chart == null) {
      return const SizedBox.shrink();
    }

    // Apply filter
    final filteredLabels = <String>[];
    final filteredValues = <double>[];
    for (int i = 0; i < chart.values.length; i++) {
      if (chart.values[i] >= _minFilterValue) {
        filteredLabels.add(chart.labels[i]);
        filteredValues.add(chart.values[i]);
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with filter icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item-wise Sales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () => _showFilterDialog(provider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return index < filteredLabels.length
                              ? SideTitleWidget(
                                meta: meta,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    filteredLabels[index],
                                    style: const TextStyle(fontSize: 10),
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
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(filteredValues.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: filteredValues[i],
                          width: 18,
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(6),
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
