import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/movimiento.dart';

enum Periodo { dia, semana, mes, year }

class ResumenPage extends StatefulWidget {
  final List<Movimiento> movimientos;

  ResumenPage({Key? key, required this.movimientos}) : super(key: key);

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  Periodo _periodo = Periodo.dia;
  Map<String, Map<String, double>> _agruparDatosDual() {
    final ahora = DateTime.now();
    DateTime inicio;
    switch (_periodo) {
      case Periodo.dia:
        inicio = ahora.subtract(Duration(days: 1));
        break;
      case Periodo.semana:
        inicio = ahora.subtract(Duration(days: 7));
        break;
      case Periodo.mes:
        inicio = DateTime(ahora.year, ahora.month - 1, ahora.day);
        break;
      case Periodo.year:
        inicio = DateTime(ahora.year - 1, ahora.month, ahora.day);
        break;
    }

    final datos = <String, Map<String, double>>{};
    for (var mov in widget.movimientos) {
      if (mov.fecha.isBefore(inicio)) continue;

      String etiqueta;
      switch (_periodo) {
        case Periodo.dia:
          etiqueta = '${mov.fecha.hour}:00';
          break;
        case Periodo.semana:
          etiqueta = '${mov.fecha.day}/${mov.fecha.month}';
          break;
        case Periodo.mes:
          final semanaNum = ((mov.fecha.day - 1) ~/ 7) + 1;
          etiqueta = 'Sem $semanaNum';
          break;
        case Periodo.year:
          const meses = [
            'Ene',
            'Feb',
            'Mar',
            'Abr',
            'May',
            'Jun',
            'Jul',
            'Ago',
            'Sep',
            'Oct',
            'Nov',
            'Dic',
          ];
          etiqueta = meses[mov.fecha.month - 1];
          break;
      }

      datos.putIfAbsent(etiqueta, () => {'ingreso': 0.0, 'gasto': 0.0});
      if (mov.esIngreso) {
        datos[etiqueta]!['ingreso'] = datos[etiqueta]!['ingreso']! + mov.monto;
      } else {
        datos[etiqueta]!['gasto'] = datos[etiqueta]!['gasto']! + mov.monto;
      }
    }
    return datos;
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final raw = _agruparDatosDual();
    final etiquetas = raw.keys.toList();
    final ingresos = etiquetas.map((e) => raw[e]!['ingreso']!).toList();
    final gastos = etiquetas.map((e) => raw[e]!['gasto']!).toList();

    final maximos = <double>[
      if (ingresos.isNotEmpty) ingresos.reduce((a, b) => a > b ? a : b),
      if (gastos.isNotEmpty) gastos.reduce((a, b) => a > b ? a : b),
    ];
    final maxY =
        (maximos.isEmpty ? 1.0 : maximos.reduce((a, b) => a > b ? a : b)) * 1.2;
    final intervalo = maxY / 5;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // — Selector de periodo —
            Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<Periodo>(
                    value: _periodo,
                    underline: SizedBox(),
                    dropdownColor: Colors.blueGrey[900],
                    style: TextStyle(color: Colors.white),
                    items:
                        Periodo.values.map((p) {
                          final texto =
                              {
                                Periodo.dia: 'Día',
                                Periodo.semana: 'Semana',
                                Periodo.mes: 'Mes',
                                Periodo.year: 'Año',
                              }[p]!;
                          return DropdownMenuItem(value: p, child: Text(texto));
                        }).toList(),
                    onChanged: (p) {
                      if (p != null) setState(() => _periodo = p);
                    },
                  ),
                ),
              ),
            ),

            // — Leyenda —
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _buildLegendDot(Colors.greenAccent, 'Ingresos'),
                  SizedBox(width: 12),
                  _buildLegendDot(Colors.redAccent, 'Gastos'),
                ],
              ),
            ),

            // — Gráfico —
            Expanded(
              child:
                  raw.isEmpty
                      ? Center(
                        child: Text(
                          'No hay datos para este período',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                      : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          color: Colors.white24,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxY,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    // No personalizamos fondo para evitar incompatibilidades
                                    getTooltipItem: (
                                      BarChartGroupData group,
                                      int groupIndex,
                                      BarChartRodData rod,
                                      int rodIndex,
                                    ) {
                                      final label =
                                          rodIndex == 0
                                              ? 'Ingresos: '
                                              : 'Gastos: ';
                                      return BarTooltipItem(
                                        '$label${rod.toY.toStringAsFixed(2)}',
                                        TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  horizontalInterval: intervalo,
                                  getDrawingHorizontalLine:
                                      (_) => FlLine(
                                        color: Colors.white12,
                                        strokeWidth: 1,
                                      ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: intervalo,
                                      reservedSize: 40,
                                      getTitlesWidget:
                                          (v, _) => Text(
                                            v.toInt().toString(),
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                          ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (x, _) {
                                        final i = x.toInt();
                                        if (i < 0 || i >= etiquetas.length)
                                          return Text('');
                                        return Text(
                                          etiquetas[i],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    left: BorderSide(color: Colors.white54),
                                    bottom: BorderSide(color: Colors.white54),
                                    top: BorderSide(color: Colors.transparent),
                                    right: BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(etiquetas.length, (i) {
                                  return BarChartGroupData(
                                    x: i,
                                    barsSpace: 4,
                                    barRods: [
                                      BarChartRodData(
                                        toY: ingresos[i],
                                        width: 12,
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.greenAccent,
                                      ),
                                      BarChartRodData(
                                        toY: gastos[i],
                                        width: 12,
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.redAccent,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
