// widgets/estudiante_widget.dart
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class EstudianteCard extends StatelessWidget {
  final Map<String, dynamic> estudiante;
  final int index;
  final Color color;
  final Function(String, Map<String, dynamic>, int) onMenuAction;
  final Function(Map<String, dynamic>, int) onRegistrarHuellas;

  const EstudianteCard({
    super.key,
    required this.estudiante,
    required this.index,
    required this.color,
    required this.onMenuAction,
    required this.onRegistrarHuellas,
  });

  @override
  Widget build(BuildContext context) {
    int huellasRegistradas = estudiante['huellasRegistradas'] ?? 0;

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            estudiante['nombres'][0],
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${estudiante['apellidoPaterno']} ${estudiante['apellidoMaterno']} ${estudiante['nombres']}',
          style: AppTextStyles.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CI: ${estudiante['ci']}'),
            Text('Registro: ${estudiante['fechaRegistro']}'),
            Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: huellasRegistradas == 3 ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  'Huellas: $huellasRegistradas/3',
                  style: TextStyle(
                    color: huellasRegistradas == 3
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (huellasRegistradas < 3)
              IconButton(
                icon: Icon(Icons.fingerprint, color: Colors.blue),
                onPressed: () => onRegistrarHuellas(estudiante, index),
                tooltip: 'Registrar Huellas',
              ),
            PopupMenuButton<String>(
              onSelected: (value) => onMenuAction(value, estudiante, index),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(value: 'edit', child: Text('Modificar')),
                PopupMenuItem(
                  value: 'huellas',
                  child: Text('Gestionar Huellas'),
                ),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
