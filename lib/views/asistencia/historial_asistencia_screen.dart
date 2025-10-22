import 'package:flutter/material.dart';

class HistorialAsistenciaScreen extends StatelessWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Asistencia'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar estudiante',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text('Estudiante ${index + 1}'),
                    subtitle: const Text('Asistencia: 85%'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navegar a detalles del historial
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}