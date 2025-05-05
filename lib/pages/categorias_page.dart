import 'package:easy_finance/models/categoria.dart';
import 'package:easy_finance/services/categoria_storage.dart';
import 'package:easy_finance/widgets/background.dart';
import 'package:flutter/material.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final CategoriaStorage _storage = CategoriaStorage();
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  void _cargarCategorias() async {
    final categoriasCargadas = await _storage.cargarCategorias();
    setState(() {
      _categorias = categoriasCargadas;
    });
  }

  void _mostrarFormularioEditar(Categoria categoria, int index) {
    final TextEditingController controller = TextEditingController(
      text: categoria.nombre,
    );
    int selectedColor = categoria.colorValue;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text('Editar categoría'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Color:'),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final nuevoColor = await showDialog(
                              context: context,
                              builder:
                                  (_) =>
                                      _ColorPickerDialog(Color(selectedColor)),
                            );
                            if (nuevoColor != null) {
                              setStateDialog(() {
                                selectedColor = nuevoColor.value;
                              });
                            }
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(selectedColor),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
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
                      final nuevoNombre = controller.text.trim();
                      if (nuevoNombre.isNotEmpty) {
                        setState(() {
                          _categorias[index] = Categoria(
                            nombre: nuevoNombre,
                            colorValue: selectedColor,
                          );
                        });
                        _storage.guardarCategorias(_categorias);
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

  void _mostrarFormularioAgregar() {
    final TextEditingController controller = TextEditingController();
    int selectedColor = Colors.grey.value;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text('Nueva categoría'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Nombre'),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Color:'),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final nuevoColor = await showDialog(
                              context: context,
                              builder:
                                  (_) =>
                                      _ColorPickerDialog(Color(selectedColor)),
                            );
                            if (nuevoColor != null) {
                              setStateDialog(() {
                                selectedColor = nuevoColor.value;
                              });
                            }
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(selectedColor),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
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
                      final nombre = controller.text.trim();
                      if (nombre.isNotEmpty) {
                        setState(() {
                          _categorias.add(
                            Categoria(
                              nombre: nombre,
                              colorValue: selectedColor,
                            ),
                          );
                        });
                        _storage.guardarCategorias(_categorias);
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

  void _confirmarEliminar(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Eliminar categoría'),
            content: Text(
              '¿Estás seguro de que deseas eliminar esta categoría?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    _categorias.removeAt(index);
                  });
                  _storage.guardarCategorias(_categorias);
                  Navigator.pop(context);
                },
                child: Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Background(),
          SafeArea(
            child:
                _categorias.isEmpty
                    ? Center(
                      child: Text(
                        'No hay categorías aún.',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final cat = _categorias[index];
                        return Card(
                          color: cat.color.withAlpha(150),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: cat.color),
                            title: Text(
                              cat.nombre,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _confirmarEliminar(index),
                            ),
                            onTap: () => _mostrarFormularioEditar(cat, index),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: CustomFABs(onPressed: _mostrarFormularioAgregar),
    );
  }
}

class CustomFABs extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFABs({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'categoria',
      backgroundColor: Color(0xFF00FFB0),
      onPressed: onPressed,
      child: Icon(Icons.add),
    );
  }
}

class _ColorPickerDialog extends StatelessWidget {
  final Color initialColor;

  const _ColorPickerDialog(this.initialColor);

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red,
      Colors.redAccent,
      Colors.orange,
      Colors.deepOrange,
      Colors.yellow,
      Colors.amber,
      Colors.green,
      Colors.lightGreen,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.lightBlue,
      Colors.indigo,
      Colors.deepPurple,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.lime,
      Colors.white,
    ];

    return AlertDialog(
      title: Text('Selecciona un color'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              colors.map((color) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 20,
                    child:
                        color == initialColor
                            ? Icon(Icons.check, color: Colors.white)
                            : null,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
