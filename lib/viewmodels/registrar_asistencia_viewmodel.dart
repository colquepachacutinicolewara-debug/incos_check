// // viewmodels/registrar_asistencia_viewmodel.dart - VERSIÓN CORREGIDA
// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:provider/provider.dart';
// import '../models/estudiante_model.dart';
// import '../models/database_helper.dart';
// import '../utils/constants.dart';
// import 'estudiantes_viewmodel.dart'; // ✅ IMPORTAR EL VIEWMODEL DE ESTUDIANTES

// class RegistrarAsistenciaViewModel with ChangeNotifier {
//   final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
//   final LocalAuthentication auth = LocalAuthentication();
  
//   List<Estudiante> _estudiantes = [];
//   List<bool> _asistencia = [];
//   bool _isLoading = false;
//   bool _biometricAvailable = false;
//   String _fechaActual = '';
//   String _materiaId = 'materia_actual';
//   String _periodoId = 'periodo_actual';

//   List<Estudiante> get estudiantes => _estudiantes;
//   List<bool> get asistencia => _asistencia;
//   bool get isLoading => _isLoading;
//   bool get biometricAvailable => _biometricAvailable;
//   String get fechaActual => _fechaActual;

//   RegistrarAsistenciaViewModel() {
//     _fechaActual = _obtenerFechaActual();
//     _cargarEstudiantesDesdeMemoria(); // ✅ CAMBIADO: Cargar desde memoria
//     _checkBiometricSupport();
//   }

//   String _obtenerFechaActual() {
//     final now = DateTime.now();
//     return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//   }

//   // ✅ NUEVO MÉTODO: Cargar estudiantes desde el EstudiantesViewModel
//   Future<void> _cargarEstudiantesDesdeMemoria() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       print('🔄 Cargando estudiantes desde memoria...');

//       // Obtener los estudiantes del EstudiantesViewModel
//       // Esto asume que el EstudiantesViewModel ya está cargado con datos
//       _estudiantes = _obtenerEstudiantesDeFuente();
      
//       print('📥 Estudiantes cargados desde memoria: ${_estudiantes.length}');

//       // Verificar si ya hay asistencias registradas para hoy
//       await _cargarAsistenciasDelDia();

//       _isLoading = false;
//       notifyListeners();

//     } catch (e) {
//       print('❌ Error cargando estudiantes desde memoria: $e');
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // ✅ MÉTODO PARA OBTENER ESTUDIANTES DESDE LA FUENTE CORRECTA
//   List<Estudiante> _obtenerEstudiantesDeFuente() {
//     // Aquí deberías obtener los estudiantes de donde los tengas almacenados
//     // Por ahora, vamos a crear la lista directamente como en tu EstudiantesViewModel
    
//     return [
//       // NRO 1-8 con CIs 15590001-15590008
//       Estudiante(
//         id: 'est_001',
//         nombres: 'Jhoshanes Israel',
//         apellidoPaterno: 'Anllon',
//         apellidoMaterno: 'Martínez',
//         ci: '15590001',
//         fechaRegistro: '2024-01-15',
//         huellasRegistradas: 0,
//         carreraId: 'sistemas',
//         turnoId: 'noche',
//         nivelId: 'tercero',
//         paraleloId: 'b',
//         fechaCreacion: DateTime.now().toIso8601String(),
//         fechaActualizacion: DateTime.now().toIso8601String(),
//       ),
//       Estudiante(
//         id: 'est_002',
//         nombres: 'Jade Silvia',
//         apellidoPaterno: 'Anti',
//         apellidoMaterno: 'Quispe',
//         ci: '15590002',
//         fechaRegistro: '2024-01-15',
//         huellasRegistradas: 0,
//         carreraId: 'sistemas',
//         turnoId: 'noche',
//         nivelId: 'tercero',
//         paraleloId: 'b',
//         fechaCreacion: DateTime.now().toIso8601String(),
//         fechaActualizacion: DateTime.now().toIso8601String(),
//       ),
//       // ... AGREGA TODOS LOS 38 ESTUDIANTES AQUÍ
//       // Copia exactamente la misma lista que tienes en EstudiantesViewModel
      
//       Estudiante(
//         id: 'est_038',
//         nombres: 'Alejandro Gabriel',
//         apellidoPaterno: 'Villa',
//         apellidoMaterno: 'Salinas',
//         ci: '15600462',
//         fechaRegistro: '2024-01-15',
//         huellasRegistradas: 0,
//         carreraId: 'sistemas',
//         turnoId: 'noche',
//         nivelId: 'tercero',
//         paraleloId: 'b',
//         fechaCreacion: DateTime.now().toIso8601String(),
//         fechaActualizacion: DateTime.now().toIso8601String(),
//       ),
//     ];
//   }

//   // ✅ MÉTODO ALTERNATIVO: Si quieres usar Provider para obtener los estudiantes
//   List<Estudiante> _obtenerEstudiantesDesdeProvider(BuildContext context) {
//     try {
//       final estudiantesVM = Provider.of<EstudiantesViewModel>(context, listen: false);
//       return estudiantesVM.estudiantes;
//     } catch (e) {
//       print('⚠️ No se pudo obtener estudiantes del Provider: $e');
//       return _obtenerEstudiantesDeFuente(); // Fallback a la lista local
//     }
//   }

//   Future<void> _cargarAsistenciasDelDia() async {
//     try {
//       // Verificar si ya existen asistencias para hoy
//       final asistenciasHoy = await _databaseHelper.rawQuery('''
//         SELECT da.asistencia_id, a.estudiante_id 
//         FROM detalle_asistencias da
//         JOIN asistencias a ON da.asistencia_id = a.id
//         WHERE da.fecha = ? AND a.materia_id = ?
//       ''', [_fechaActual, _materiaId]);

//       // Inicializar lista de asistencia
//       _asistencia = List.filled(_estudiantes.length, false);

//       // Marcar como presentes los que ya tienen asistencia
//       for (final asistenciaReg in asistenciasHoy) {
//         final estudianteId = asistenciaReg['estudiante_id']?.toString();
//         final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
//         if (index != -1) {
//           _asistencia[index] = true;
//         }
//       }

//       print('✅ Asistencias del día cargadas: ${asistenciasHoy.length}');
//     } catch (e) {
//       print('⚠️ Error cargando asistencias del día: $e');
//       _asistencia = List.filled(_estudiantes.length, false);
//     }
//   }

//   // Los demás métodos permanecen IGUALES...
//   Future<void> _checkBiometricSupport() async {
//     try {
//       final bool canCheckBiometrics = await auth.canCheckBiometrics;
//       final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

//       _biometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
//       print('🔐 Soporte biométrico: $_biometricAvailable');
//       notifyListeners();
//     } catch (e) {
//       _biometricAvailable = false;
//       print('❌ Error verificando soporte biométrico: $e');
//       notifyListeners();
//     }
//   }

//   Future<void> registrarConHuella(int index, BuildContext context) async {
//     if (_isLoading || _asistencia[index]) return;

//     final estudiante = _estudiantes[index];
    
//     if (!estudiante.tieneHuellasRegistradas) {
//       _mostrarSnackbar(
//         context,
//         "❌ ${estudiante.nombreCompleto} no tiene huellas registradas",
//         getErrorColor(context),
//       );
//       return;
//     }

//     if (!_biometricAvailable) {
//       _mostrarSnackbar(
//         context,
//         "📱 El dispositivo no soporta autenticación biométrica",
//         getWarningColor(context),
//       );
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       print('🔐 Autenticando huella para: ${estudiante.nombreCompleto}');

//       final bool autenticado = await auth.authenticate(
//         localizedReason: "Autentica tu huella para registrar asistencia de ${estudiante.nombreCompleto}",
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           useErrorDialogs: true,
//           stickyAuth: true,
//         ),
//       );

//       if (autenticado) {
//         await _guardarAsistenciaEnSQLite(estudiante.id, 'biometrico');
        
//         _asistencia[index] = true;
//         _mostrarSnackbar(
//           context,
//           "✅ Asistencia biométrica confirmada - ${estudiante.nombreCompleto}",
//           getSuccessColor(context),
//         );
        
//         print('✅ Asistencia biométrica registrada para: ${estudiante.nombreCompleto}');
//       } else {
//         _mostrarSnackbar(
//           context,
//           "❌ Huella no reconocida - ${estudiante.nombreCompleto}",
//           getErrorColor(context),
//         );
//       }
//     } catch (e) {
//       print('❌ Error en autenticación biométrica: $e');
//       _mostrarSnackbar(
//         context,
//         "⚠️ Error de autenticación biométrica",
//         getErrorColor(context),
//       );
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> registrarManual(int index, BuildContext context) async {
//     if (_isLoading || _asistencia[index]) return;

//     final estudiante = _estudiantes[index];

//     final bool confirmado = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmar Asistencia Manual'),
//         content: Text('¿Registrar asistencia manual para ${estudiante.nombreCompleto}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancelar'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Confirmar'),
//           ),
//         ],
//       ),
//     ) ?? false;

//     if (!confirmado) return;

//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _guardarAsistenciaEnSQLite(estudiante.id, 'manual');
      
//       _asistencia[index] = true;
//       _mostrarSnackbar(
//         context,
//         "✅ Asistencia manual registrada - ${estudiante.nombreCompleto}",
//         getSuccessColor(context),
//       );
      
//       print('📋 Asistencia manual registrada para: ${estudiante.nombreCompleto}');

//     } catch (e) {
//       print('❌ Error registrando asistencia manual: $e');
//       _mostrarSnackbar(
//         context,
//         "⚠️ Error registrando asistencia: ${e.toString()}",
//         getErrorColor(context),
//       );
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _guardarAsistenciaEnSQLite(String estudianteId, String tipo) async {
//     try {
//       final now = DateTime.now();
//       final nowString = now.toIso8601String();

//       final asistenciaExistente = await _databaseHelper.rawQuery('''
//         SELECT id FROM asistencias 
//         WHERE estudiante_id = ? AND periodo_id = ? AND materia_id = ?
//       ''', [estudianteId, _periodoId, _materiaId]);

//       String asistenciaId;

//       if (asistenciaExistente.isNotEmpty) {
//         asistenciaId = asistenciaExistente.first['id']?.toString() ?? '';
        
//         await _databaseHelper.rawUpdate('''
//           UPDATE asistencias 
//           SET asistencia_registrada_hoy = ?, datos_asistencia = ?, ultima_actualizacion = ?
//           WHERE id = ?
//         ''', [
//           1,
//           '{"fecha": "$nowString", "tipo": "$tipo", "fecha_registro": "$_fechaActual"}',
//           nowString,
//           asistenciaId
//         ]);
//       } else {
//         asistenciaId = 'asist_${estudianteId}_${now.millisecondsSinceEpoch}';
        
//         await _databaseHelper.rawInsert('''
//           INSERT INTO asistencias (
//             id, estudiante_id, periodo_id, materia_id, 
//             asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion
//           ) VALUES (?, ?, ?, ?, ?, ?, ?)
//         ''', [
//           asistenciaId,
//           estudianteId,
//           _periodoId,
//           _materiaId,
//           1,
//           '{"fecha": "$nowString", "tipo": "$tipo", "fecha_registro": "$_fechaActual"}',
//           nowString,
//         ]);
//       }

//       await _guardarDetalleAsistencia(asistenciaId, estudianteId);

//       print('💾 Asistencia guardada en SQLite: $estudianteId - $tipo');

//     } catch (e) {
//       print('❌ Error guardando asistencia en SQLite: $e');
//       rethrow;
//     }
//   }

//   Future<void> _guardarDetalleAsistencia(String asistenciaId, String estudianteId) async {
//     try {
//       final now = DateTime.now();
      
//       final detalleExistente = await _databaseHelper.rawQuery('''
//         SELECT id FROM detalle_asistencias 
//         WHERE asistencia_id = ? AND fecha = ?
//       ''', [asistenciaId, _fechaActual]);

//       if (detalleExistente.isNotEmpty) {
//         await _databaseHelper.rawUpdate('''
//           UPDATE detalle_asistencias 
//           SET estado = 'P', porcentaje = 100, dia = ?
//           WHERE asistencia_id = ? AND fecha = ?
//         ''', [
//           DateTime.now().day.toString(),
//           asistenciaId,
//           _fechaActual
//         ]);
//       } else {
//         await _databaseHelper.rawInsert('''
//           INSERT INTO detalle_asistencias (
//             id, asistencia_id, dia, porcentaje, estado, fecha
//           ) VALUES (?, ?, ?, ?, ?, ?)
//         ''', [
//           'det_${asistenciaId}_${now.millisecondsSinceEpoch}',
//           asistenciaId,
//           DateTime.now().day.toString(),
//           100,
//           'P',
//           _fechaActual
//         ]);
//       }

//       print('📝 Detalle de asistencia guardado: $estudianteId');

//     } catch (e) {
//       print('❌ Error guardando detalle de asistencia: $e');
//       rethrow;
//     }
//   }

//   void registrarAsistenciaPorId(String estudianteId, BuildContext context, {bool esManual = false}) {
//     final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
//     if (index != -1 && !_asistencia[index]) {
//       if (esManual) {
//         registrarManual(index, context);
//       } else {
//         registrarConHuella(index, context);
//       }
//     } else if (index != -1) {
//       _mostrarSnackbar(
//         context,
//         "ℹ️ ${_estudiantes[index].nombreCompleto} ya tiene asistencia registrada",
//         getWarningColor(context),
//       );
//     }
//   }

//   Future<void> limpiarAsistencias() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _databaseHelper.rawDelete('''
//         DELETE FROM detalle_asistencias 
//         WHERE fecha = ?
//       ''', [_fechaActual]);

//       _asistencia = List.filled(_estudiantes.length, false);

//       _isLoading = false;
//       notifyListeners();

//       print('🗑️ Asistencias del día limpiadas');

//     } catch (e) {
//       print('❌ Error limpiando asistencias: $e');
//       _isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   Map<String, dynamic> getEstadisticas() {
//     final total = _estudiantes.length;
//     final presentes = _asistencia.where((a) => a).length;
//     final ausentes = total - presentes;
//     final porcentaje = total > 0 ? (presentes / total * 100) : 0;

//     return {
//       'total': total,
//       'presentes': presentes,
//       'ausentes': ausentes,
//       'porcentaje': porcentaje.roundToDouble(),
//       'fecha': _fechaActual,
//     };
//   }

//   void _mostrarSnackbar(BuildContext context, String mensaje, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           mensaje, 
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: color,
//         duration: const Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   // Getters para la UI
//   int get totalAsistencias => _asistencia.where((element) => element).length;
//   int get totalEstudiantes => _estudiantes.length;
//   int get estudiantesConHuellas => _estudiantes.where((est) => est.tieneHuellasRegistradas).length;

//   Estudiante? obtenerEstudiantePorId(String id) {
//     try {
//       return _estudiantes.firstWhere((est) => est.id == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   bool tieneAsistenciaRegistrada(String estudianteId) {
//     final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
//     return index != -1 ? _asistencia[index] : false;
//   }

//   Future<void> recargarEstudiantes() async {
//     await _cargarEstudiantesDesdeMemoria();
//   }

//   // Funciones para obtener colores según el tema
//   Color getBackgroundColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.grey.shade900
//         : AppColors.background;
//   }

//   Color getCardColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.grey.shade800
//         : Colors.white;
//   }

//   Color getTextColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.white
//         : Colors.black;
//   }

//   Color getSecondaryTextColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.white70
//         : Colors.black87;
//   }

//   Color getBorderColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.grey.shade600
//         : AppColors.border;
//   }

//   Color getSuccessColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.green.shade700
//         : AppColors.success;
//   }

//   Color getWarningColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.orange.shade700
//         : AppColors.warning;
//   }

//   Color getErrorColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.red.shade700
//         : AppColors.error;
//   }

//   Color getAccentColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? Colors.blue.shade700
//         : AppColors.accent;
//   }
// }
// viewmodels/registrar_asistencia_viewmodel.dart - VERSIÓN CON PROVIDER
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../models/estudiante_model.dart';
import '../models/database_helper.dart';
import '../utils/constants.dart';
import 'estudiantes_viewmodel.dart'; // ✅ IMPORTAR EL VIEWMODEL DE ESTUDIANTES

class RegistrarAsistenciaViewModel with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final LocalAuthentication auth = LocalAuthentication();
  
  List<Estudiante> _estudiantes = [];
  List<bool> _asistencia = [];
  bool _isLoading = false;
  bool _biometricAvailable = false;
  String _fechaActual = '';
  final String _materiaId = 'materia_actual';
  final String _periodoId = 'periodo_actual';

  List<Estudiante> get estudiantes => _estudiantes;
  List<bool> get asistencia => _asistencia;
  bool get isLoading => _isLoading;
  bool get biometricAvailable => _biometricAvailable;
  String get fechaActual => _fechaActual;

  RegistrarAsistenciaViewModel() {
    _fechaActual = _obtenerFechaActual();
    _checkBiometricSupport();
    // ✅ NO cargamos estudiantes aquí, los obtendremos del EstudiantesViewModel
  }

  String _obtenerFechaActual() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ✅ NUEVO MÉTODO: Cargar estudiantes desde EstudiantesViewModel
  Future<void> cargarEstudiantesDesdeProvider(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Cargando estudiantes desde EstudiantesViewModel...');

      // Obtener estudiantes del EstudiantesViewModel via Provider
      final estudiantesVM = Provider.of<EstudiantesViewModel>(context, listen: false);
      
      // ✅ Asegurarnos que los estudiantes estén cargados
      if (estudiantesVM.estudiantes.isEmpty) {
        print('📥 EstudiantesViewModel vacío, recargando...');
        await estudiantesVM.recargarEstudiantes();
      }

      _estudiantes = List.from(estudiantesVM.estudiantes);
      
      print('🎯 Estudiantes cargados desde Provider: ${_estudiantes.length}');

      // Verificar si ya hay asistencias registradas para hoy
      await _cargarAsistenciasDelDia();

      _isLoading = false;
      notifyListeners();

    } catch (e) {
      print('❌ Error cargando estudiantes desde Provider: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _cargarAsistenciasDelDia() async {
    try {
      // Verificar si ya existen asistencias para hoy
      final asistenciasHoy = await _databaseHelper.rawQuery('''
        SELECT da.asistencia_id, a.estudiante_id 
        FROM detalle_asistencias da
        JOIN asistencias a ON da.asistencia_id = a.id
        WHERE da.fecha = ? AND a.materia_id = ?
      ''', [_fechaActual, _materiaId]);

      // Inicializar lista de asistencia
      _asistencia = List.filled(_estudiantes.length, false);

      // Marcar como presentes los que ya tienen asistencia
      for (final asistenciaReg in asistenciasHoy) {
        final estudianteId = asistenciaReg['estudiante_id']?.toString();
        final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
        if (index != -1) {
          _asistencia[index] = true;
        }
      }

      print('✅ Asistencias del día cargadas: ${asistenciasHoy.length}');
    } catch (e) {
      print('⚠️ Error cargando asistencias del día: $e');
      _asistencia = List.filled(_estudiantes.length, false);
    }
  }

  // Los demás métodos permanecen IGUALES...
  Future<void> _checkBiometricSupport() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      _biometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
      print('🔐 Soporte biométrico: $_biometricAvailable');
      notifyListeners();
    } catch (e) {
      _biometricAvailable = false;
      print('❌ Error verificando soporte biométrico: $e');
      notifyListeners();
    }
  }

  Future<void> registrarConHuella(int index, BuildContext context) async {
    if (_isLoading || _asistencia[index]) return;

    final estudiante = _estudiantes[index];
    
    if (!estudiante.tieneHuellasRegistradas) {
      _mostrarSnackbar(
        context,
        "❌ ${estudiante.nombreCompleto} no tiene huellas registradas",
        getErrorColor(context),
      );
      return;
    }

    if (!_biometricAvailable) {
      _mostrarSnackbar(
        context,
        "📱 El dispositivo no soporta autenticación biométrica",
        getWarningColor(context),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔐 Autenticando huella para: ${estudiante.nombreCompleto}');

      final bool autenticado = await auth.authenticate(
        localizedReason: "Autentica tu huella para registrar asistencia de ${estudiante.nombreCompleto}",
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (autenticado) {
        await _guardarAsistenciaEnSQLite(estudiante.id, 'biometrico');
        
        _asistencia[index] = true;
        _mostrarSnackbar(
          context,
          "✅ Asistencia biométrica confirmada - ${estudiante.nombreCompleto}",
          getSuccessColor(context),
        );
        
        print('✅ Asistencia biométrica registrada para: ${estudiante.nombreCompleto}');
      } else {
        _mostrarSnackbar(
          context,
          "❌ Huella no reconocida - ${estudiante.nombreCompleto}",
          getErrorColor(context),
        );
      }
    } catch (e) {
      print('❌ Error en autenticación biométrica: $e');
      _mostrarSnackbar(
        context,
        "⚠️ Error de autenticación biométrica",
        getErrorColor(context),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registrarManual(int index, BuildContext context) async {
    if (_isLoading || _asistencia[index]) return;

    final estudiante = _estudiantes[index];

    final bool confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Asistencia Manual'),
        content: Text('¿Registrar asistencia manual para ${estudiante.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmado) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _guardarAsistenciaEnSQLite(estudiante.id, 'manual');
      
      _asistencia[index] = true;
      _mostrarSnackbar(
        context,
        "✅ Asistencia manual registrada - ${estudiante.nombreCompleto}",
        getSuccessColor(context),
      );
      
      print('📋 Asistencia manual registrada para: ${estudiante.nombreCompleto}');

    } catch (e) {
      print('❌ Error registrando asistencia manual: $e');
      _mostrarSnackbar(
        context,
        "⚠️ Error registrando asistencia: ${e.toString()}",
        getErrorColor(context),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _guardarAsistenciaEnSQLite(String estudianteId, String tipo) async {
    try {
      final now = DateTime.now();
      final nowString = now.toIso8601String();

      final asistenciaExistente = await _databaseHelper.rawQuery('''
        SELECT id FROM asistencias 
        WHERE estudiante_id = ? AND periodo_id = ? AND materia_id = ?
      ''', [estudianteId, _periodoId, _materiaId]);

      String asistenciaId;

      if (asistenciaExistente.isNotEmpty) {
        asistenciaId = asistenciaExistente.first['id']?.toString() ?? '';
        
        await _databaseHelper.rawUpdate('''
          UPDATE asistencias 
          SET asistencia_registrada_hoy = ?, datos_asistencia = ?, ultima_actualizacion = ?
          WHERE id = ?
        ''', [
          1,
          '{"fecha": "$nowString", "tipo": "$tipo", "fecha_registro": "$_fechaActual"}',
          nowString,
          asistenciaId
        ]);
      } else {
        asistenciaId = 'asist_${estudianteId}_${now.millisecondsSinceEpoch}';
        
        await _databaseHelper.rawInsert('''
          INSERT INTO asistencias (
            id, estudiante_id, periodo_id, materia_id, 
            asistencia_registrada_hoy, datos_asistencia, ultima_actualizacion
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          asistenciaId,
          estudianteId,
          _periodoId,
          _materiaId,
          1,
          '{"fecha": "$nowString", "tipo": "$tipo", "fecha_registro": "$_fechaActual"}',
          nowString,
        ]);
      }

      await _guardarDetalleAsistencia(asistenciaId, estudianteId);

      print('💾 Asistencia guardada en SQLite: $estudianteId - $tipo');

    } catch (e) {
      print('❌ Error guardando asistencia en SQLite: $e');
      rethrow;
    }
  }

  Future<void> _guardarDetalleAsistencia(String asistenciaId, String estudianteId) async {
    try {
      final now = DateTime.now();
      
      final detalleExistente = await _databaseHelper.rawQuery('''
        SELECT id FROM detalle_asistencias 
        WHERE asistencia_id = ? AND fecha = ?
      ''', [asistenciaId, _fechaActual]);

      if (detalleExistente.isNotEmpty) {
        await _databaseHelper.rawUpdate('''
          UPDATE detalle_asistencias 
          SET estado = 'P', porcentaje = 100, dia = ?
          WHERE asistencia_id = ? AND fecha = ?
        ''', [
          DateTime.now().day.toString(),
          asistenciaId,
          _fechaActual
        ]);
      } else {
        await _databaseHelper.rawInsert('''
          INSERT INTO detalle_asistencias (
            id, asistencia_id, dia, porcentaje, estado, fecha
          ) VALUES (?, ?, ?, ?, ?, ?)
        ''', [
          'det_${asistenciaId}_${now.millisecondsSinceEpoch}',
          asistenciaId,
          DateTime.now().day.toString(),
          100,
          'P',
          _fechaActual
        ]);
      }

      print('📝 Detalle de asistencia guardado: $estudianteId');

    } catch (e) {
      print('❌ Error guardando detalle de asistencia: $e');
      rethrow;
    }
  }

  void registrarAsistenciaPorId(String estudianteId, BuildContext context, {bool esManual = false}) {
    final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
    if (index != -1 && !_asistencia[index]) {
      if (esManual) {
        registrarManual(index, context);
      } else {
        registrarConHuella(index, context);
      }
    } else if (index != -1) {
      _mostrarSnackbar(
        context,
        "ℹ️ ${_estudiantes[index].nombreCompleto} ya tiene asistencia registrada",
        getWarningColor(context),
      );
    }
  }

  Future<void> limpiarAsistencias() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseHelper.rawDelete('''
        DELETE FROM detalle_asistencias 
        WHERE fecha = ?
      ''', [_fechaActual]);

      _asistencia = List.filled(_estudiantes.length, false);

      _isLoading = false;
      notifyListeners();

      print('🗑️ Asistencias del día limpiadas');

    } catch (e) {
      print('❌ Error limpiando asistencias: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Map<String, dynamic> getEstadisticas() {
    final total = _estudiantes.length;
    final presentes = _asistencia.where((a) => a).length;
    final ausentes = total - presentes;
    final porcentaje = total > 0 ? (presentes / total * 100) : 0;

    return {
      'total': total,
      'presentes': presentes,
      'ausentes': ausentes,
      'porcentaje': porcentaje.roundToDouble(),
      'fecha': _fechaActual,
    };
  }

  void _mostrarSnackbar(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje, 
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Getters para la UI
  int get totalAsistencias => _asistencia.where((element) => element).length;
  int get totalEstudiantes => _estudiantes.length;
  int get estudiantesConHuellas => _estudiantes.where((est) => est.tieneHuellasRegistradas).length;

  Estudiante? obtenerEstudiantePorId(String id) {
    try {
      return _estudiantes.firstWhere((est) => est.id == id);
    } catch (e) {
      return null;
    }
  }

  bool tieneAsistenciaRegistrada(String estudianteId) {
    final index = _estudiantes.indexWhere((est) => est.id == estudianteId);
    return index != -1 ? _asistencia[index] : false;
  }

  // ✅ NUEVO: Recargar desde Provider
  Future<void> recargarEstudiantes(BuildContext context) async {
    await cargarEstudiantesDesdeProvider(context);
  }

  // Funciones para obtener colores según el tema
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : AppColors.background;
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : AppColors.border;
  }

  Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade700
        : AppColors.success;
  }

  Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.orange.shade700
        : AppColors.warning;
  }

  Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade700
        : AppColors.error;
  }

  Color getAccentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blue.shade700
        : AppColors.accent;
  }
}