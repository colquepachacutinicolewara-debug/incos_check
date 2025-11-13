// models/soporte_model.dart
class SoporteModel {
  final String whatsappNumber;
  final String email;
  final String phoneNumber;
  final String whatsappMessage;
  final String emailSubject;
  final String emailBody;

  SoporteModel({
    required this.whatsappNumber,
    required this.email,
    required this.phoneNumber,
    required this.whatsappMessage,
    required this.emailSubject,
    required this.emailBody,
  });

  Map<String, dynamic> toMap() {
    return {
      'whatsapp_number': whatsappNumber,
      'email': email,
      'phone_number': phoneNumber,
      'whatsapp_message': whatsappMessage,
      'email_subject': emailSubject,
      'email_body': emailBody,
    };
  }

  factory SoporteModel.fromMap(Map<String, dynamic> map) {
    return SoporteModel(
      whatsappNumber: map['whatsapp_number'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? '',
      whatsappMessage: map['whatsapp_message'] ?? '',
      emailSubject: map['email_subject'] ?? '',
      emailBody: map['email_body'] ?? '',
    );
  }

  SoporteModel copyWith({
    String? whatsappNumber,
    String? email,
    String? phoneNumber,
    String? whatsappMessage,
    String? emailSubject,
    String? emailBody,
  }) {
    return SoporteModel(
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappMessage: whatsappMessage ?? this.whatsappMessage,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
    );
  }

  String get whatsappUrl {
    final message = Uri.encodeComponent(whatsappMessage);
    return 'https://wa.me/$whatsappNumber?text=$message';
  }

  String get mailToUrl {
    final subject = Uri.encodeComponent(emailSubject);
    final body = Uri.encodeComponent(emailBody);
    return 'mailto:$email?subject=$subject&body=$body';
  }

  String get telUrl => 'tel:$phoneNumber';

  bool get tieneWhatsapp => whatsappNumber.isNotEmpty;
  bool get tieneEmail => email.isNotEmpty;
  bool get tieneTelefono => phoneNumber.isNotEmpty;

  @override
  String toString() {
    return 'SoporteModel(whatsapp: $whatsappNumber, email: $email)';
  }
}