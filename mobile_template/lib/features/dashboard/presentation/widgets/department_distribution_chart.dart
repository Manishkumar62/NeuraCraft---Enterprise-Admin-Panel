import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DepartmentDistributionChart extends StatelessWidget {
  const DepartmentDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      _PieData("IT", 40),
      _PieData("HR", 25),
      _PieData("Sales", 20),
      _PieData("Finance", 15),
    ];

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: SfCircularChart(
        title: ChartTitle(text: "Department Distribution"),
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
        ),
        series: <CircularSeries>[
          PieSeries<_PieData, String>(
            dataSource: data,
            xValueMapper: (_PieData d, _) => d.name,
            yValueMapper: (_PieData d, _) => d.value,
            dataLabelSettings:
                const DataLabelSettings(isVisible: true),
          )
        ],
      ),
    );
  }
}

class _PieData {
  final String name;
  final int value;

  _PieData(this.name, this.value);
}