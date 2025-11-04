import '../utils/helpers.dart';

class InicioModel {
  final DateTime currentDate;
  final String systemStatus;

  InicioModel({required this.currentDate, required this.systemStatus});

  String get formattedDate => Helpers.formatDate(currentDate);
  String get formattedTime => Helpers.formatTime(currentDate);
}
