// lib/services/test_api.dart
import 'api_service.dart';

void testConexionAPI() async {
  final api = ApiService();
  
  print('🔗 Probando conexión con API...');
  final bool conectado = await api.testConnection();
  
  if (conectado) {
    print('✅ API CONECTADA CORRECTAMENTE!');
  } else {
    print('❌ NO SE PUDO CONECTAR CON LA API');
    print('💡 Verifica que:');
    print('   1. XAMPP esté ejecutándose');
    print('   2. La carpeta incos_api esté en htdocs/');
    print('   3. La URL en api_service.dart sea correcta');
  }
}