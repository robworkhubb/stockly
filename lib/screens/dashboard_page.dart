import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/product_provider.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final topProducts = provider.topConsumati();
    final categoryDist = provider.distribuzionePerCategoria();
    final monthlyExpense = provider.spesaMensile();
    final months = monthlyExpense.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Icon(
              Icons.analytics_outlined,
              color: Color(0xFF009688),
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'Cruscotto Analitico',
              style: TextStyle(
                color: Color(0xFF009688),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body:
          provider.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiche Magazzino',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Top 5 prodotti consumati
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top 5 prodotti consumati',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF009688),
                              ),
                            ),
                            const SizedBox(height: 70),
                            SizedBox(
                              height: 220,
                              child:
                                  topProducts.isEmpty
                                      ? Center(
                                        child: Text(
                                          'Nessun dato disponibile',
                                          style: TextStyle(
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      )
                                      : BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          barGroups: [
                                            for (
                                              int i = 0;
                                              i < topProducts.length;
                                              i++
                                            )
                                              BarChartGroupData(
                                                x: i,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY:
                                                        topProducts[i].consumati
                                                            .toDouble(),
                                                    color: Color.fromARGB(
                                                      255,
                                                      58,
                                                      255,
                                                      235,
                                                    ),
                                                    width: 22,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ],
                                                showingTooltipIndicators: [0],
                                              ),
                                          ],
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 32,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final idx = value.toInt();
                                                  if (idx <
                                                      topProducts.length) {
                                                    String nome =
                                                        topProducts[idx].nome;
                                                    if (nome.length > 8)
                                                      nome =
                                                          nome.substring(0, 8) +
                                                          '…';
                                                    return Transform.rotate(
                                                      angle: -0.0, //
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8,
                                                            ),
                                                        child: Text(
                                                          nome,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                              0xFF757575,
                                                            ),
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  return Text('');
                                                },
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                          ),
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Distribuzione per categoria
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distribuzione per categoria',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF009688),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child:
                                  categoryDist.isEmpty
                                      ? Center(
                                        child: Text(
                                          'Nessun dato disponibile',
                                          style: TextStyle(
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      )
                                      : PieChart(
                                        PieChartData(
                                          sections: [
                                            for (final entry
                                                in categoryDist.entries)
                                              PieChartSectionData(
                                                value: entry.value.toDouble(),
                                                title: entry.key,
                                                color: Colors
                                                    .primaries[categoryDist.keys
                                                            .toList()
                                                            .indexOf(
                                                              entry.key,
                                                            ) %
                                                        Colors.primaries.length]
                                                    .withOpacity(0.85),
                                                radius: 60,
                                                titleStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 36,
                                        ),
                                      ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children:
                                  categoryDist.keys.map((cat) {
                                    final color = Colors
                                        .primaries[categoryDist.keys
                                                .toList()
                                                .indexOf(cat) %
                                            Colors.primaries.length]
                                        .withOpacity(0.85);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Spesa mensile totale
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spesa mensile totale',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF009688),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child:
                                  months.isEmpty
                                      ? Center(
                                        child: Text(
                                          'Nessun dato disponibile',
                                          style: TextStyle(
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      )
                                      : LineChart(
                                        LineChartData(
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: [
                                                for (
                                                  int i = 0;
                                                  i < months.length;
                                                  i++
                                                )
                                                  FlSpot(
                                                    i.toDouble(),
                                                    monthlyExpense[months[i]] ??
                                                        0,
                                                  ),
                                              ],
                                              isCurved: true,
                                              color: Color(0xFF009688),
                                              barWidth: 5,
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (
                                                  spot,
                                                  percent,
                                                  bar,
                                                  index,
                                                ) {
                                                  return FlDotCirclePainter(
                                                    radius: 6,
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                    strokeColor: Color(
                                                      0xFF009688,
                                                    ),
                                                  );
                                                },
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: Color.fromARGB(
                                                  255,
                                                  223,
                                                  223,
                                                  223,
                                                ).withOpacity(0.08),
                                              ),
                                            ),
                                          ],
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                getTitlesWidget: (value, meta) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 4,
                                                        ),
                                                    child: Text(
                                                      '${value.toStringAsFixed(0)}€',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF757575,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final idx = value.toInt();
                                                  return idx < months.length
                                                      ? Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8,
                                                            ),
                                                        child: Text(
                                                          months[idx],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  240,
                                                                  240,
                                                                  240,
                                                                ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      )
                                                      : Text('');
                                                },
                                              ),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: false,
                                          ),
                                          borderData: FlBorderData(show: false),
                                          lineTouchData: LineTouchData(
                                            enabled: true,
                                            touchTooltipData: LineTouchTooltipData(
                                              getTooltipItems: (touchedSpots) {
                                                return touchedSpots.map((spot) {
                                                  return LineTooltipItem(
                                                    '${months[spot.x.toInt()]}\n${spot.y.toStringAsFixed(2)} €',
                                                    const TextStyle(
                                                      color: Color.fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                            ),
                                          ),
                                          extraLinesData: ExtraLinesData(
                                            horizontalLines: [
                                              HorizontalLine(
                                                y: 0,
                                                color: Colors.grey.shade300,
                                                strokeWidth: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
