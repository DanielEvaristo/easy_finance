import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/categoria.dart';

class CategoriaStorage {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/categorias.json';
  }

  Future<List<Categoria>> cargarCategorias() async {
    final path = await _getFilePath();
    final file = File(path);

    // 🔁 Si el archivo no existe en almacenamiento local, lo copiamos desde assets
    if (!await file.exists()) {
      final contenidoInicial = await rootBundle.loadString(
        'assets/data/categorias.json',
      );
      await file.writeAsString(contenidoInicial);
    }

    final contenido = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(contenido);
    return jsonList.map((json) => Categoria.fromJson(json)).toList();
  }

  Future<void> guardarCategorias(List<Categoria> categorias) async {
    final path = await _getFilePath();
    final file = File(path);

    final data = categorias.map((e) => e.toJson()).toList();
    final contenido = jsonEncode(data);
    await file.writeAsString(contenido);

    // Desarrollo: Imprimir el contenido guardado y la ruta del archivo
    print('Contenido guardado: $contenido');
    print('Archivo guardado en: $path');
  }
}
