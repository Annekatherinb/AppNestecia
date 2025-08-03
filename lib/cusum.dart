import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CusumPage extends StatefulWidget {
  const CusumPage({super.key});

  @override
  State<CusumPage> createState() => _CusumPageState();
}

class _CusumPageState extends State<CusumPage> {
  String selectedProcedure = 'orotraqueal';

  final Map<String, List<double>> cusumDataByType = {
    'orotraqueal': [0.1, 0.2, -0.7, -0.6, -0.5],
    'subaracnoidea': [-0.2, -0.1, 0.1, 0.3, 0.5],
    'mascara_laringea': [0.0, 0.1, 0.1, 0.2, 0.1],
    'nasotraqueal': [-0.3, -0.2, -0.1, 0.0, 0.2],
  };

  @override
  Widget build(BuildContext context) {
    final cusumData = cusumDataByType[selectedProcedure]!;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Análisis CUSUM",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Selector de procedimiento
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: ['orotraqueal', 'nasotraqueal', 'mascara_laringea', 'subaracnoidea']
                  .map((type) => GestureDetector(
                onTap: () => setState(() => selectedProcedure = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedProcedure == type
                        ? Colors.orangeAccent
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      type.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: selectedProcedure == type
                            ? Colors.black
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Gráfico
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          '${value.toStringAsFixed(1)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white30),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        cusumData.length,
                            (index) => FlSpot(index.toDouble() + 1, cusumData[index]),
                      ),
                      isCurved: false,
                      color: Colors.orangeAccent,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
