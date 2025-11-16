// services/fingerprint_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FingerprintTemplate {
  final String templateId;
  final String estudianteId;
  final String dedo;
  final DateTime fecha;

  FingerprintTemplate({
    required this.templateId,
    required this.estudianteId,
    required this.dedo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
    'templateId': templateId,
    'estudianteId': estudianteId,
    'dedo': dedo,
    'fecha': fecha.toIso8601String(),
  };

  factory FingerprintTemplate.fromMap(Map<String, dynamic> map) {
    return FingerprintTemplate(
      templateId: map['templateId'] as String,
      estudianteId: map['estudianteId'] as String,
      dedo: map['dedo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
    );
  }
}

class FingerprintService {
  static const _prefsKey = 'fingerprint_templates';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Guarda localmente (shared_preferences) una lista de plantillas
  Future<List<FingerprintTemplate>> _readLocalTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw) as List;
    return decoded.map((e) => FingerprintTemplate.fromMap(e)).toList();
  }

  Future<void> _writeLocalTemplates(List<FingerprintTemplate> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((e) => e.toMap()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  Future<FingerprintTemplate> enrollTemplate({
    required String estudianteId,
    required String dedo,
    bool uploadToFirestore = true,
  }) async {
    // generar templateId simulado
    final templateId = _uuid.v4();
    final template = FingerprintTemplate(
      templateId: templateId,
      estudianteId: estudianteId,
      dedo: dedo,
      fecha: DateTime.now(),
    );

    // guardar localmente
    final current = await _readLocalTemplates();
    current.add(template);
    await _writeLocalTemplates(current);

    // opcional: subir a Firestore
    if (uploadToFirestore) {
      await _firestore.collection('huellas').doc(templateId).set({
        'templateId': template.templateId,
        'estudianteId': template.estudianteId,
        'dedo': template.dedo,
        'fecha': FieldValue.serverTimestamp(),
      });
    }

    // También guardamos un valor que simula "finger currently on reader"
    // Esto ayuda a la identificación simulada (modo demo).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sim_current_template', templateId);

    return template;
  }

  Future<List<FingerprintTemplate>> listLocalTemplates() async {
    return _readLocalTemplates();
  }

  // Simulación de lo que el lector devolvería al poner un dedo
  // Por defecto retorna el último template enrolado en este dispositivo
  Future<String?> getSimulatedCurrentTemplateId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sim_current_template');
  }

  // Permitir setear manualmente el current template (útil para pruebas)
  Future<void> setSimulatedCurrentTemplateId(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sim_current_template', templateId);
  }

  // Identifica un templateId y devuelve info del estudiante (si existe)
  Future<Map<String, dynamic>?> identifyByTemplate(String templateId) async {
    // Buscamos localmente primero
    final local = await _readLocalTemplates();
    final found = local.firstWhere(
      (t) => t.templateId == templateId,
      orElse: () => null as FingerprintTemplate,
    );

    if (found != null) {
      return {
        'estudianteId': found.estudianteId,
        'dedo': found.dedo,
        'fecha': found.fecha.toIso8601String(),
      };
    }

    // Si no está localmente, intentamos Firestore (por si subiste desde otra app)
    try {
      final doc = await _firestore.collection('huellas').doc(templateId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return {'estudianteId': data['estudianteId'], 'dedo': data['dedo']};
      }
    } catch (e) {
      // ignore
    }

    return null;
  }
}
