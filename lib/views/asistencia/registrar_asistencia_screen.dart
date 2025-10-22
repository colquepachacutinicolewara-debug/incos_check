import 'package:flutter/material.dart';

class RegistrarAsistenciaScreen extends StatelessWidget {
  const RegistrarAsistenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Asistencia'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 60, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Escanear Código QR',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Escanear QR'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'O seleccionar manualmente:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Estudiante ${index + 1}'),
                    subtitle: const Text('Curso: Matemáticas'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}