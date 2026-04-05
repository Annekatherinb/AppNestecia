// lib/cusum.dart  ← reemplaza tu archivo actual
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/api_service.dart';

class CusumPage extends StatefulWidget {
  const CusumPage({super.key});

  @override
  State<CusumPage> createState() => _CusumPageState();
}

class _CusumPageState extends State<CusumPage> {
  String selectedProcedure = 'orotraqueal';
  bool _loading = true;

  Map<String, List<double>> cusumDataByType = {
    'orotraqueal':    [],
    'subaracnoidea':  [],
    'mascara_laringea': [],
    'nasotraqueal':   [],
  };

  @override
  void initState() {
    super.initState();
    _loadCusum();
  }

  Future<void> _loadCusum() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getCusum();
      final Map<String, List<double>> result = {};
      for (final item in data) {
        result[item['tipo_procedimiento']] =
            List<double>.from(item['valores'].map((v) => (v as num).toDouble()));
      }
      setState(() {
        cusumDataByType = {
          'orotraqueal':      result['orotraqueal']      ?? [],
          'subaracnoidea':    result['subaracnoidea']    ?? [],
          'mascara_laringea': result['mascara_laringea'] ?? [],
          'nasotraqueal':     result['nasotraqueal']     ?? [],
        };
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        showApiError(context, e);
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cusumData = cusumDataByType[selectedProcedure] ?? [];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCusum,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              children: [
                const SizedBox(height: 16),
                // ─── Selector ──────────────────────────────────
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

                // ─── Gráfico ───────────────────────────────────
                Expanded(
                  child: cusumData.isEmpty
                      ? const Center(
                          child: Text(
                            "Sin datos para este procedimiento",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
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
                                      value.toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                                    ),
                                  ),
                                ),
                                topTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                    (i) => FlSpot(i.toDouble() + 1, cusumData[i]),
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
