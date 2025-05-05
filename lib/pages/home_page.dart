import 'package:easy_finance/models/movimiento.dart';
import 'package:easy_finance/models/categoria.dart';
import 'package:easy_finance/pages/categorias_page.dart';
import 'package:easy_finance/pages/resumen_page.dart';
import 'package:easy_finance/services/movimiento_storage.dart';
import 'package:easy_finance/services/categoria_storage.dart';
import 'package:easy_finance/widgets/background.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final MovimientoStorage _movimientoStorage = MovimientoStorage();
  final CategoriaStorage _categoriaStorage = CategoriaStorage();

  List<Movimiento> _movimientos = [];
  List<Categoria> _categoriasList = [];

  double _saldo = 0;
  double _totalIngresos = 0;
  double _totalGastos = 0;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarMovimientos();
  }

  void _cargarCategorias() async {
    final datos = await _categoriaStorage.cargarCategorias();
    setState(() {
      _categoriasList = datos;
    });
  }

  void _cargarMovimientos() async {
    final datos = await _movimientoStorage.cargarMovimientos();
    double ingresos = 0, gastos = 0;
    for (var mov in datos) {
      if (mov.esIngreso)
        ingresos += mov.monto;
      else
        gastos += mov.monto;
    }
    setState(() {
      _movimientos = datos;
      _totalIngresos = ingresos;
      _totalGastos = gastos;
      _saldo = ingresos - gastos;
    });
  }

  void _mostrarFormularioMovimiento(bool esIngreso) {
    final montoController = TextEditingController();
    String categoriaSeleccionada =
        _categoriasList.isNotEmpty ? _categoriasList.first.nombre : 'General';

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text(esIngreso ? 'Agregar ingreso' : 'Agregar gasto'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Monto'),
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categoriaSeleccionada,
                      items:
                          _categoriasList.map((cat) {
                            return DropdownMenuItem(
                              value: cat.nombre,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: cat.color,
                                    radius: 10,
                                  ),
                                  SizedBox(width: 8),
                                  Text(cat.nombre),
                                ],
                              ),
                            );
                          }).toList(),
                      decoration: InputDecoration(labelText: 'Categoría'),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            categoriaSeleccionada = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final monto = double.tryParse(montoController.text);
                      if (monto != null && monto > 0) {
                        final nuevo = Movimiento(
                          categoria: categoriaSeleccionada,
                          monto: monto,
                          fecha: DateTime.now(),
                          esIngreso: esIngreso,
                        );
                        setState(() {
                          _movimientos.insert(0, nuevo);
                          if (esIngreso) {
                            _totalIngresos += monto;
                            _saldo += monto;
                          } else {
                            _totalGastos += monto;
                            _saldo -= monto;
                          }
                        });
                        _movimientoStorage.guardarMovimientos(_movimientos);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Guardar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _cargarCategorias();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeBody(
        saldo: _saldo,
        ingresos: _totalIngresos,
        gastos: _totalGastos,
        movimientos: _movimientos,
        categorias: _categoriasList,
      ),
      CategoriasPage(),
      ResumenPage(movimientos: _movimientos),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Easy Finance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(children: [Background(), pages[_selectedIndex]]),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? CustomFABs(
                onAgregarGasto: () => _mostrarFormularioMovimiento(false),
                onAgregarIngreso: () => _mostrarFormularioMovimiento(true),
              )
              : null,
    );
  }
}

class HomeBody extends StatelessWidget {
  final double saldo;
  final double ingresos;
  final double gastos;
  final List<Movimiento> movimientos;
  final List<Categoria> categorias;

  HomeBody({
    Key? key,
    required this.saldo,
    required this.ingresos,
    required this.gastos,
    required this.movimientos,
    required this.categorias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(Duration(days: 7));
    final recientes =
        movimientos.where((m) => m.fecha.isAfter(cutoff)).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Saldo actual: \$${saldo.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SummaryBox(
                    title: 'Gastos',
                    amount: '\$${gastos.toStringAsFixed(2)}',
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SummaryBox(
                    title: 'Ingresos',
                    amount: '\$${ingresos.toStringAsFixed(2)}',
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Últimos movimientos',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 12),
            ...recientes.map((mov) {
              final cat = categorias.firstWhere(
                (c) => c.nombre == mov.categoria,
                orElse:
                    () => Categoria(
                      nombre: mov.categoria,
                      colorValue: Colors.grey.value,
                    ),
              );
              return Card(
                color: Colors.white.withAlpha(50),
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    mov.esIngreso ? Icons.add_circle : Icons.remove_circle,
                    color: cat.color,
                  ),
                  title: Text(
                    '${mov.categoria} - \$${mov.monto.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${mov.fecha.day}/${mov.fecha.month}/${mov.fecha.year}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class SummaryBox extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  SummaryBox({
    Key? key,
    required this.title,
    required this.amount,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
          SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFABs extends StatelessWidget {
  final VoidCallback onAgregarIngreso;
  final VoidCallback onAgregarGasto;

  CustomFABs({
    Key? key,
    required this.onAgregarIngreso,
    required this.onAgregarGasto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'gasto',
          backgroundColor: Color(0xFF00FFB0),
          onPressed: onAgregarGasto,
          child: Icon(Icons.remove),
        ),
        SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'ingreso',
          backgroundColor: Color(0xFF00FFB0),
          onPressed: onAgregarIngreso,
          child: Icon(Icons.add),
        ),
      ],
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      selectedItemColor: Color(0xFF00FFB0),
      backgroundColor: Color(0xFF1E2A47),
      unselectedItemColor: Color(0xFF9AA0B5),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categorías',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Resumen'),
      ],
    );
  }
}
