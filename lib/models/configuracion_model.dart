class ConfiguracionModel {
  bool notificationsEnabled;
  bool darkModeEnabled;
  bool biometricEnabled;
  bool autoSyncEnabled;
  String selectedLanguage;
  String selectedTheme;
  String cacheSize;

  ConfiguracionModel({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.biometricEnabled,
    required this.autoSyncEnabled,
    required this.selectedLanguage,
    required this.selectedTheme,
    required this.cacheSize,
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
    );
  }

  ConfiguracionModel copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? biometricEnabled,
    bool? autoSyncEnabled,
    String? selectedLanguage,
    String? selectedTheme,
    String? cacheSize,
  }) {
    return ConfiguracionModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }
}
