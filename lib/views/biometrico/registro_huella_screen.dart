// views/biometrico/registro_huella_screen.dart
import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RegistroHuellaScreen extends StatefulWidget {
  final Usuario usuario;
  
  const RegistroHuellaScreen({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  @override
  _RegistroHuellaScreenState createState() => _RegistroHuellaScreenState();
}

class _RegistroHuellaScreenState extends State<RegistroHuellaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Huellas'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                'Módulo de Registro Biométrico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Esta funcionalidad estará disponible pronto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}