import 'package:equatable/equatable.dart';

class SalesChart extends Equatable {
  final List<String> labels;
  final List<double> values;
  final String datasetName;
  final String chartType;
  final List<String> colors;

  const SalesChart({
    required this.labels,
    required this.values,
    required this.datasetName,
    required this.chartType,
    required this.colors,
  });

  @override
  List<Object?> get props => [labels, values, datasetName, chartType, colors];
}
