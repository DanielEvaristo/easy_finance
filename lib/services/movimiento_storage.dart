import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/movimiento.dart';

class MovimientoStorage {
  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/movimientos.json';
  }

  Future<List<Movimiento>> cargarMovimientos() async {
    final path = await _getFilePath();
    final file = File(path);

    if (!await file.exists()) return [];

    final contenido = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(contenido);
    return jsonList.map((json) => Movimiento.fromJson(json)).toList();
  }

  Future<void> guardarMovimientos(List<Movimiento> movimientos) async {
    final path = await _getFilePath();
    final file = File(path);
    final data = movimientos.map((m) => m.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }
}
