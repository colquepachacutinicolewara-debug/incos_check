// models/inicio_model.dart
import '../utils/helpers.dart';

class InicioModel {
  final DateTime currentDate;
  final String systemStatus;

  InicioModel({
    required this.currentDate,
    required this.systemStatus,
  });

  InicioModel copyWith({
    DateTime? currentDate,
    String? systemStatus,
  }) {
    return InicioModel(
      currentDate: currentDate ?? this.currentDate,
      systemStatus: systemStatus ?? this.systemStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fecha_actual': currentDate.toIso8601String(),
      'system_status': systemStatus,
    };
  }

  factory InicioModel.fromMap(Map<String, dynamic> map) {
    return InicioModel(
      currentDate: map['fecha_actual'] != null
          ? DateTime.parse(map['fecha_actual'])
          : DateTime.now(),
      systemStatus: map['system_status'] ?? 'Sistema Operativo',
    );
  }

  String get formattedDate => Helpers.formatDate(currentDate);
  String get formattedTime => Helpers.formatTime(currentDate);
  String get diaSemana => Helpers.getDiaSemana(currentDate);
  String get mesAnio => Helpers.getMesAnio(currentDate);

  bool get sistemaOperativo => systemStatus.toLowerCase().contains('operativo');
  bool get sistemaConProblemas => systemStatus.toLowerCase().contains('problema') || 
                                 systemStatus.toLowerCase().contains('error');

  @override
  String toString() {
    return 'InicioModel($formattedDate - $systemStatus)';
  }
}