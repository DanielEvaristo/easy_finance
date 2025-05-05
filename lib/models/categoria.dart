import 'package:flutter/material.dart';

class Categoria {
  String nombre;
  int colorValue;

  Categoria({required this.nombre, required this.colorValue});

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {'nombre': nombre, 'colorValue': colorValue};

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      Categoria(nombre: json['nombre'], colorValue: json['colorValue']);
}
