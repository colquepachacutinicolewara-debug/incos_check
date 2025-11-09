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
}
