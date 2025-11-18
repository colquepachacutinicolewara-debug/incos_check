// models/horario_tercer_b.dart
import 'horario_clase_model.dart';

class HorariosTercerB {
  static List<HorarioClase> generarHorariosCompletos() {
    final horarios = <HorarioClase>[];
    final paraleloBId = 'paralelo_b_tercero';
    final carrera = 'Sistemas Informáticos';
    final anio = 3;
    final turno = 'Noche';

    // IDs de materias (debes usar los mismos IDs que en tu MateriaViewModel)
    final materiasIds = {
      'analisis2': 'analisis2_b_noche',
      'moviles2': 'moviles2_b_noche', 
      'basedatos2': 'basedatos2_b_noche',
      'emprendimiento': 'emprendimiento_b_noche',
      'redes2': 'redes2_b_noche',
      'web3': 'web3_b_noche',
      'taller3d': 'taller-grado_b_noche', // Usando el ID existente
    };

    // ========== LUNES ==========
    horarios.add(HorarioClase(
      id: 'lun_19_analisis2_b',
      materiaId: materiasIds['analisis2']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_analisis', // Reemplazar con ID real
      diaSemana: 'Lunes',
      periodoNumero: 1,
      horaInicio: '19:00',
      horaFin: '20:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'lun_20_web3_b',
      materiaId: materiasIds['web3']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_web',
      diaSemana: 'Lunes',
      periodoNumero: 2,
      horaInicio: '20:00',
      horaFin: '21:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'lun_21_taller3d_b',
      materiaId: materiasIds['taller3d']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_taller',
      diaSemana: 'Lunes',
      periodoNumero: 3,
      horaInicio: '21:00',
      horaFin: '22:00',
      fechaCreacion: DateTime.now(),
    ));

    // ========== MARTES ==========
    horarios.add(HorarioClase(
      id: 'mar_19_moviles2_b',
      materiaId: materiasIds['moviles2']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_moviles',
      diaSemana: 'Martes',
      periodoNumero: 1,
      horaInicio: '19:00',
      horaFin: '20:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'mar_20_moviles2_b',
      materiaId: materiasIds['moviles2']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_moviles',
      diaSemana: 'Martes',
      periodoNumero: 2,
      horaInicio: '20:00',
      horaFin: '21:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'mar_21_web3_b',
      materiaId: materiasIds['web3']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_web',
      diaSemana: 'Martes',
      periodoNumero: 3,
      horaInicio: '21:00',
      horaFin: '22:00',
      fechaCreacion: DateTime.now(),
    ));

    // ========== MIÉRCOLES ==========
    horarios.add(HorarioClase(
      id: 'mie_19_basedatos2_b',
      materiaId: materiasIds['basedatos2']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_basedatos',
      diaSemana: 'Miércoles',
      periodoNumero: 1,
      horaInicio: '19:00',
      horaFin: '20:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'mie_20_basedatos2_b',
      materiaId: materiasIds['basedatos2']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_basedatos',
      diaSemana: 'Miércoles',
      periodoNumero: 2,
      horaInicio: '20:00',
      horaFin: '21:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'mie_21_web3_b',
      materiaId: materiasIds['web3']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_web',
      diaSemana: 'Miércoles',
      periodoNumero: 3,
      horaInicio: '21:00',
      horaFin: '22:00',
      fechaCreacion: DateTime.now(),
    ));

    // ========== JUEVES ==========
    horarios.add(HorarioClase(
      id: 'jue_19_emprendimiento_b',
      materiaId: materiasIds['emprendimiento']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_emprendimiento',
      diaSemana: 'Jueves',
      periodoNumero: 1,
      horaInicio: '19:00',
      horaFin: '20:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'jue_20_taller3d_b',
      materiaId: materiasIds['taller3d']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_taller',
      diaSemana: 'Jueves',
      periodoNumero: 2,
      horaInicio: '20:00',
      horaFin: '21:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'jue_21_emprendimiento_b',
      materiaId: materiasIds['emprendimiento']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_emprendimiento',
      diaSemana: 'Jueves',
      periodoNumero: 3,
      horaInicio: '21:00',
      horaFin: '22:00',
      fechaCreacion: DateTime.now(),
    ));

    // ========== VIERNES ==========
    horarios.add(HorarioClase(
      id: 'vie_19_redes2_b',
      materiaId: materiasIds['redes2']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_redes',
      diaSemana: 'Viernes',
      periodoNumero: 1,
      horaInicio: '19:00',
      horaFin: '20:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'vie_20_web3_b',
      materiaId: materiasIds['web3']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_web',
      diaSemana: 'Viernes',
      periodoNumero: 2,
      horaInicio: '20:00',
      horaFin: '21:00',
      fechaCreacion: DateTime.now(),
    ));

    horarios.add(HorarioClase(
      id: 'vie_21_emprendimiento_b',
      materiaId: materiasIds['emprendimiento']!,
      paraleloId: paraleloBId,
      docenteId: 'docente_emprendimiento',
      diaSemana: 'Viernes',
      periodoNumero: 3,
      horaInicio: '21:00',
      horaFin: '22:00',
      fechaCreacion: DateTime.now(),
    ));

    return horarios;
  }

  // Método para obtener horarios del día actual
  static List<HorarioClase> obtenerHorariosDeHoy(List<HorarioClase> todosHorarios) {
    final hoy = _obtenerDiaActual();
    return todosHorarios.where((h) => h.diaSemana == hoy).toList();
  }

  static String _obtenerDiaActual() {
    final now = DateTime.now();
    final dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    return dias[now.weekday - 1];
  }
}