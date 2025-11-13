// models/configuracion_model.dart
class ConfiguracionModel {
  final String? id;
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
      id: 'config_default',
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

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 'config_default',
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'dark_mode_enabled': darkModeEnabled ? 1 : 0,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'auto_sync_enabled': autoSyncEnabled ? 1 : 0,
      'selected_language': selectedLanguage,
      'selected_theme': selectedTheme,
      'cache_size': cacheSize,
      'last_updated': lastUpdated?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory ConfiguracionModel.fromMap(Map<String, dynamic> map) {
    return ConfiguracionModel(
      id: map['id'],
      notificationsEnabled: (map['notifications_enabled'] ?? 1) == 1,
      darkModeEnabled: (map['dark_mode_enabled'] ?? 0) == 1,
      biometricEnabled: (map['biometric_enabled'] ?? 0) == 1,
      autoSyncEnabled: (map['auto_sync_enabled'] ?? 1) == 1,
      selectedLanguage: map['selected_language'] ?? 'Español',
      selectedTheme: map['selected_theme'] ?? 'Sistema',
      cacheSize: map['cache_size'] ?? "15.2 MB",
      lastUpdated: map['last_updated'] != null 
          ? DateTime.parse(map['last_updated'])
          : null,
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

  // Métodos de utilidad
  bool get isDarkMode => darkModeEnabled;
  bool get hasBiometricAccess => biometricEnabled;
  bool get shouldAutoSync => autoSyncEnabled;

  @override
  String toString() {
    return 'ConfiguracionModel($id: $selectedLanguage - $selectedTheme)';
  }
}