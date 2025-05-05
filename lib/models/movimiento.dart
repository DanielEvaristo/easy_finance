class Movimiento {
  final String categoria;
  final double monto;
  final DateTime fecha;
  final bool esIngreso;

  Movimiento({
    required this.categoria,
    required this.monto,
    required this.fecha,
    required this.esIngreso,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      categoria: json['categoria'],
      monto: json['monto'],
      fecha: DateTime.parse(json['fecha']),
      esIngreso: json['esIngreso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'esIngreso': esIngreso,
    };
  }
}
