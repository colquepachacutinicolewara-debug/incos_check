class Validators {

  /// Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Correo obligatorio';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!regex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  /// Validar contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña obligatoria';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  /// Validar campo obligatorio genérico
  static String? validateNotEmpty(String? value, {String? message}) {
    if (value == null || value.isEmpty) return message ?? 'Campo obligatorio';
    return null;
  }

  /// Validar nombre (solo letras y espacios)
  /// Devuelve el nombre convertido a mayúsculas
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nombre obligatorio';
    if (value.length < 2) return 'Nombre demasiado corto';
    final regex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$');
    if (!regex.hasMatch(value)) return 'El nombre solo puede contener letras y espacios';
    return null;
  }

  /// Convertir nombre a mayúsculas (para usar después de validar)
  static String formatName(String name) => name.toUpperCase();

  /// Validar CI (solo números, 6-10 dígitos)
  static String? validateCI(String? value) {
    if (value == null || value.isEmpty) return 'CI obligatorio';
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(value)) return 'CI inválido, solo números';
    if (value.length < 6 || value.length > 10) return 'CI debe tener entre 6 y 10 dígitos';
    return null;
  }

  /// Convertir departamento a mayúsculas
  static String formatDepartment(String dept) => dept.toUpperCase();

  /// Validar teléfono Bolivia (+591) con 8 dígitos y departamento opcional
  static String? validatePhone(String? value, {String? departamento}) {
    if (value == null || value.isEmpty) return 'Teléfono obligatorio';
    if (!value.startsWith('+591')) return 'El teléfono debe iniciar con +591';

    String numberPart = value.replaceFirst('+591', '');
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(numberPart)) return 'Teléfono inválido, solo números';
    if (numberPart.length != 8) return 'El teléfono debe tener 8 dígitos';

    if (departamento != null) {
      final validDepartments = ['LP','SCZ','CBBA','OR','PT','CH','TJA','BE','PD'];
      if (!validDepartments.contains(departamento.toUpperCase())) {
        return 'Departamento inválido';
      }
    }
    return null;
  }

  /// Validar números enteros positivos
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Número obligatorio';
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(value)) return 'Solo se permiten números';
    return null;
  }

  /// Validar fecha (YYYY-MM-DD)
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Fecha obligatoria';
    // Opcional: validar formato con DateTime.tryParse(value)
    return null;
  }

  /// Validar hora (HH:MM)
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) return 'Hora obligatoria';
    // Opcional: validar formato con RegExp o DateTime.tryParse
    return null;
  }
}