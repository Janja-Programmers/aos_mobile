import '../domain/sales_chart.dart';

class SalesChartModel extends SalesChart {
  const SalesChartModel({
    required super.labels,
    required super.values,
    required super.datasetName,
    required super.chartType,
    required super.colors,
  });

  factory SalesChartModel.fromJson(Map<String, dynamic> json) {
    final chartData = json['chart']['data'];
    final labels = List<String>.from(chartData['labels'] ?? []);
    final dataset = (chartData['datasets'] as List).first;
    final values = List<double>.from(
      dataset['values'].map((e) => (e as num).toDouble()),
    );
    final datasetName = dataset['name'];
    final chartType = json['chart']['type'] ?? 'bar';
    final colors = List<String>.from(json['chart']['colors'] ?? []);

    return SalesChartModel(
      labels: labels,
      values: values,
      datasetName: datasetName,
      chartType: chartType,
      colors: colors,
    );
  }
}
