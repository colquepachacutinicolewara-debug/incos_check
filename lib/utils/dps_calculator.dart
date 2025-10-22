// utils/dps_calculator.dart
class DPSCalculator {
  /// Calcula la nota DPS según reglas del INCOS
  /// @param totalSesiones: Total de sesiones del bimestre
  /// @param asistencias: Total de asistencias del estudiante
  /// @param tardanzas: Total de tardanzas del estudiante
  /// @return double: Nota DPS entre 10.0 y 20.0
  static double calcularDPS(int totalSesiones, int asistencias, int tardanzas) {
    if (totalSesiones == 0) return 10.0;
    
    final double porcentajeAsistencia = (asistencias / totalSesiones) * 100;
    final double descuentoTardanzas = (tardanzas * 0.5); // Cada tardanza resta 0.5
    
    double notaBase = _obtenerNotaBase(porcentajeAsistencia);
    final double notaFinal = (notaBase - descuentoTardanzas).clamp(10.0, 20.0);
    
    return double.parse(notaFinal.toStringAsFixed(1));
  }

  static double _obtenerNotaBase(double porcentaje) {
    if (porcentaje >= 90) return 20.0;
    if (porcentaje >= 80) return 18.0;
    if (porcentaje >= 70) return 16.0;
    if (porcentaje >= 60) return 14.0;
    if (porcentaje >= 50) return 12.0;
    return 10.0;
  }

  /// Calcula porcentaje de asistencia
  static double calcularPorcentajeAsistencia(int totalSesiones, int asistencias) {
    if (totalSesiones == 0) return 0.0;
    return double.parse(((asistencias / totalSesiones) * 100).toStringAsFixed(1));
  }

  /// Determina el estado de asistencia
  static String determinarEstado(int totalSesiones, int asistencias) {
    final double porcentaje = calcularPorcentajeAsistencia(totalSesiones, asistencias);
    if (porcentaje >= 80) return 'Óptimo';
    if (porcentaje >= 60) return 'Regular';
    return 'Crítico';
  }
}