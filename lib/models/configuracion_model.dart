import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionModel {
  final String? id; // ID del documento en Firestore
  bool notificationsEnabled;
  bool darkModeEnabled;
  bool biometricEnabled;
  bool autoSyncEnabled;
  String selectedLanguage;
  String selectedTheme;
  String cacheSize;
  DateTime? lastUpdated;

  ConfiguracionModel({
    this.id,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.biometricEnabled,
    required this.autoSyncEnabled,
    required this.selectedLanguage,
    required this.selectedTheme,
    required this.cacheSize,
    this.lastUpdated,
  });

  factory ConfiguracionModel.defaultValues() {
    return ConfiguracionModel(
      notificationsEnabled: true,
      darkModeEnabled: false,
      biometricEnabled: false,
      autoSyncEnabled: true,
      selectedLanguage: 'Español',
      selectedTheme: 'Sistema',
      cacheSize: "15.2 MB",
      lastUpdated: DateTime.now(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'biometricEnabled': biometricEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'selectedLanguage': selectedLanguage,
      'selectedTheme': selectedTheme,
      'cacheSize': cacheSize,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory ConfiguracionModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ConfiguracionModel(
      id: id,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      darkModeEnabled: data['darkModeEnabled'] ?? false,
      biometricEnabled: data['biometricEnabled'] ?? false,
      autoSyncEnabled: data['autoSyncEnabled'] ?? true,
      selectedLanguage: data['selectedLanguage'] ?? 'Español',
      selectedTheme: data['selectedTheme'] ?? 'Sistema',
      cacheSize: data['cacheSize'] ?? "15.2 MB",
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  ConfiguracionModel copyWith({
    String? id,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? biometricEnabled,
    bool? autoSyncEnabled,
    String? selectedLanguage,
    String? selectedTheme,
    String? cacheSize,
    DateTime? lastUpdated,
  }) {
    return ConfiguracionModel(
      id: id ?? this.id,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      cacheSize: cacheSize ?? this.cacheSize,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
