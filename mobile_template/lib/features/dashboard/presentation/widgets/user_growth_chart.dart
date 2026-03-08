import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UserGrowthChart extends StatelessWidget {
  const UserGrowthChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      _ChartData("Jan", 2),
      _ChartData("Feb", 5),
      _ChartData("Mar", 7),
      _ChartData("Apr", 9),
      _ChartData("May", 12),
    ];

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: SfCartesianChart(
        title: ChartTitle(text: "User Growth"),
        legend: const Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          LineSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData d, _) => d.month,
            yValueMapper: (_ChartData d, _) => d.value,
            color: Colors.blue,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
      ),
    );
  }
}

class _ChartData {
  final String month;
  final int value;

  _ChartData(this.month, this.value);
}