import 'package:flutter/material.dart';
import 'dart:convert';

class FiltroHistorial {
  final bool mostrarTodasMaterias;
  final String queryBusqueda;

  FiltroHistorial({
    required this.mostrarTodasMaterias,
    required this.queryBusqueda,
  });

  FiltroHistorial copyWith({
    bool? mostrarTodasMaterias,
    String? queryBusqueda,
  }) {
    return FiltroHistorial(
      mostrarTodasMaterias: mostrarTodasMaterias ?? this.mostrarTodasMaterias,
      queryBusqueda: queryBusqueda ?? this.queryBusqueda,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mostrar_todas_materias': mostrarTodasMaterias ? 1 : 0,
      'query_busqueda': queryBusqueda,
    };
  }

  factory FiltroHistorial.fromMap(Map<String, dynamic> map) {
    return FiltroHistorial(
      mostrarTodasMaterias: (map['mostrar_todas_materias'] ?? 0) == 1,
      queryBusqueda: map['query_busqueda'] ?? '',
    );
  }

  bool get tieneBusqueda => queryBusqueda.isNotEmpty;
  bool get filtroActivo => mostrarTodasMaterias || queryBusqueda.isNotEmpty;

  @override
  String toString() {
    return 'FiltroHistorial(mostrarTodas: $mostrarTodasMaterias, busqueda: $queryBusqueda)';
  }
}

class RegistroHistorial {
  final String id;
  final String estudianteId;
  final String materiaId;
  final String periodoId;
  final DateTime fechaConsulta;
  final bool filtroMostrarTodasMaterias;
  final String? queryBusqueda;
  final Map<String, dynamic>? datosConsulta;

  RegistroHistorial({
    required this.id,
    required this.estudianteId,
    required this.materiaId,
    required this.periodoId,
    required this.fechaConsulta,
    required this.filtroMostrarTodasMaterias,
    this.queryBusqueda,
    this.datosConsulta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estudiante_id': estudianteId,
      'materia_id': materiaId,
      'periodo_id': periodoId,
      'fecha_consulta': fechaConsulta.toIso8601String(),
      'filtro_mostrar_todas_materias': filtroMostrarTodasMaterias ? 1 : 0,
      'query_busqueda': queryBusqueda,
      'datos_consulta': datosConsulta != null ? json.encode(datosConsulta) : null,
    };
  }

  factory RegistroHistorial.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic>? datosConsulta;
    try {
      if (map['datos_consulta'] is String && map['datos_consulta'].toString().isNotEmpty) {
        datosConsulta = Map<String, dynamic>.from(json.decode(map['datos_consulta']));
      }
    } catch (e) {
      print('Error parsing datos_consulta: $e');
    }

    return RegistroHistorial(
      id: map['id'] ?? '',
      estudianteId: map['estudiante_id'] ?? '',
      materiaId: map['materia_id'] ?? '',
      periodoId: map['periodo_id'] ?? '',
      fechaConsulta: map['fecha_consulta'] != null
          ? DateTime.parse(map['fecha_consulta'])
          : DateTime.now(),
      filtroMostrarTodasMaterias: (map['filtro_mostrar_todas_materias'] ?? 0) == 1,
      queryBusqueda: map['query_busqueda'],
      datosConsulta: datosConsulta,
    );
  }

  RegistroHistorial copyWith({
    String? id,
    String? estudianteId,
    String? materiaId,
    String? periodoId,
    DateTime? fechaConsulta,
    bool? filtroMostrarTodasMaterias,
    String? queryBusqueda,
    Map<String, dynamic>? datosConsulta,
  }) {
    return RegistroHistorial(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      materiaId: materiaId ?? this.materiaId,
      periodoId: periodoId ?? this.periodoId,
      fechaConsulta: fechaConsulta ?? this.fechaConsulta,
      filtroMostrarTodasMaterias: filtroMostrarTodasMaterias ?? this.filtroMostrarTodasMaterias,
      queryBusqueda: queryBusqueda ?? this.queryBusqueda,
      datosConsulta: datosConsulta ?? this.datosConsulta,
    );
  }

  bool get tieneFiltros => filtroMostrarTodasMaterias || (queryBusqueda?.isNotEmpty ?? false);
  String get fechaConsultaFormateada {
    return '${fechaConsulta.day}/${fechaConsulta.month}/${fechaConsulta.year}';
  }

  @override
  String toString() {
    return 'RegistroHistorial($id: $estudianteId - $fechaConsultaFormateada)';
  }
}

// VIEW MODEL COMPLETO
class HistorialAsistenciaViewModel extends ChangeNotifier {
  FiltroHistorial _filtro = FiltroHistorial(
    mostrarTodasMaterias: false,
    queryBusqueda: '',
  );
  
  FiltroHistorial get filtro => _filtro;
  bool get mostrarTodasMaterias => _filtro.mostrarTodasMaterias;
  String get queryBusqueda => _filtro.queryBusqueda;
  
  void toggleMostrarTodasMaterias() {
    _filtro = _filtro.copyWith(mostrarTodasMaterias: !_filtro.mostrarTodasMaterias);
    notifyListeners();
  }
  
  void setQueryBusqueda(String query) {
    _filtro = _filtro.copyWith(queryBusqueda: query);
    notifyListeners();
  }
  
  void limpiarFiltros() {
    _filtro = FiltroHistorial(mostrarTodasMaterias: false, queryBusqueda: '');
    notifyListeners();
  }
  
  String obtenerTextoFiltros(int anioSeleccionado) {
    List<String> filtros = [];
    
    if (mostrarTodasMaterias) {
      filtros.add('Todas las materias');
    } else {
      filtros.add('Año $anioSeleccionado');
    }
    
    if (queryBusqueda.isNotEmpty) {
      filtros.add('Búsqueda: "$queryBusqueda"');
    }
    
    return filtros.join(' • ');
  }
  
  // Métodos para temas/colores
  Color getFilterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade100;
  }
  
  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
  
  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }
  
  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade400;
  }
  
  Color getDropdownBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }
  
  Color getSearchBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }
  
  Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }
}