import 'package:flutter/material.dart';
import 'package:incos_check/utils/constants.dart';
import 'package:incos_check/utils/helpers.dart';
import 'package:incos_check/utils/validators.dart';

class RegistroEstudianteWidget extends StatefulWidget {
  final Map<String, dynamic>? estudianteExistente;
  final Function(Map<String, dynamic>)? onEstudianteGuardado;

  const RegistroEstudianteWidget({
    super.key,
    this.estudianteExistente,
    this.onEstudianteGuardado,
  });

  @override
  State<RegistroEstudianteWidget> createState() => _RegistroEstudianteWidgetState();
}

class _RegistroEstudianteWidgetState extends State<RegistroEstudianteWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String _selectedCurso = '3RO B - SISTEMAS';
  String _selectedEstado = Estados.activo;
  bool _huellaRegistrada = false;

  final List<String> _cursos = [
    '3RO B - SISTEMAS',
    '2DO A - ADMINISTRACIÓN',
    '4TO C - CONTADURÍA',
    '1RO B - SISTEMAS',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.estudianteExistente != null) {
      _cargarDatosExistente();
    }
  }

  void _cargarDatosExistente() {
    final estudiante = widget.estudianteExistente!;
    _paternoController.text = estudiante['apellidoPaterno'];
    _maternoController.text = estudiante['apellidoMaterno'];
    _nombresController.text = estudiante['nombres'];
    _ciController.text = estudiante['ci'];
    _emailController.text = estudiante['email'];
    _telefonoController.text = estudiante['telefono'];
    _selectedEstado = estudiante['estado'];
    _huellaRegistrada = estudiante['huellaRegistrada'];
  }

  void _registrarEstudiante() {
    if (_formKey.currentState!.validate()) {
      final estudiante = {
        'id': widget.estudianteExistente?['id'] ?? DateTime.now().millisecondsSinceEpoch,
        'apellidoPaterno': Validators.formatName(_paternoController.text),
        'apellidoMaterno': Validators.formatName(_maternoController.text),
        'nombres': Validators.formatName(_nombresController.text),
        'ci': _ciController.text,
        'email': _emailController.text,
        'telefono': _telefonoController.text,
        'curso': _selectedCurso,
        'estado': _selectedEstado,
        'huellaRegistrada': _huellaRegistrada,
      };

      if (widget.onEstudianteGuardado != null) {
        widget.onEstudianteGuardado!(estudiante);
      }

      Helpers.showSnackBar(
        context, 
        widget.estudianteExistente != null 
            ? 'Estudiante actualizado exitosamente' 
            : 'Estudiante registrado exitosamente',
        type: 'success'
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.estudianteExistente != null ? 'Editar Estudiante' : 'Registro de Estudiante',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        backgroundColor: UserThemeColors.estudiante,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Información personal
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información Personal', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                      SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _paternoController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Paterno',
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateName,
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _maternoController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Materno',
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateName,
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _nombresController,
                        decoration: InputDecoration(
                          labelText: 'Nombres',
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateName,
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _ciController,
                        decoration: InputDecoration(
                          labelText: 'Carnet de Identidad',
                          prefixIcon: Icon(Icons.badge, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateCI,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.medium),
              
              // Información de contacto
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información de Contacto', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                      SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => Validators.validatePhone(value, departamento: 'LP'),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.medium),
              
              // Información académica y biométrica
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información Académica y Biométrica', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                      SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField(
                        initialValue: _selectedCurso,
                        decoration: InputDecoration(
                          labelText: 'Curso',
                          prefixIcon: Icon(Icons.school, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        items: _cursos.map((curso) {
                          return DropdownMenuItem(value: curso, child: Text(curso));
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCurso = value!),
                      ),
                      SizedBox(height: AppSpacing.small),
                      DropdownButtonFormField(
                        initialValue: _selectedEstado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: Icon(Icons.circle, color: AppColors.primary),
                          border: OutlineInputBorder(),
                        ),
                        items: [Estados.activo, Estados.inactivo].map((estado) {
                          return DropdownMenuItem(value: estado, child: Text(estado));
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedEstado = value!),
                      ),
                      SizedBox(height: AppSpacing.small),
                      SwitchListTile(
                        title: Text('Huella Digital Registrada'),
                        subtitle: Text('¿El estudiante tiene su huella registrada en el sistema?'),
                        value: _huellaRegistrada,
                        onChanged: (value) => setState(() => _huellaRegistrada = value),
                        secondary: Icon(Icons.fingerprint, color: _huellaRegistrada ? AppColors.success : AppColors.error),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.large),
              
              // Botón de registro/actualización
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registrarEstudiante,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.medium),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                  ),
                  child: Text(
                    widget.estudianteExistente != null ? 'ACTUALIZAR ESTUDIANTE' : 'REGISTRAR ESTUDIANTE',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}