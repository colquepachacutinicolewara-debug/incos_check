// views/configuracion/editar_perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../models/usuario_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  String? _fotoUrl;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    _usernameController.text = widget.usuario.username;
    _nombreController.text = widget.usuario.nombre;
    _emailController.text = widget.usuario.email;
    _telefonoController.text = widget.usuario.telefono ?? '';
    _fotoUrl = widget.usuario.fotoUrl;
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() {
        _fotoUrl = imagen.path;
      });
      
      // En una app real, aquí subirías la imagen a un servidor
      print('📸 Foto seleccionada: ${imagen.path}');
      Helpers.showSnackBar(
        context, 
        '✅ Foto seleccionada (simulación)',
        type: 'success',
      );
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      // Crear usuario actualizado
      final usuarioActualizado = widget.usuario.copyWith(
        username: _usernameController.text.trim(),
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        fotoUrl: _fotoUrl,
      );

      // Actualizar en AuthViewModel
      final resultado = await authViewModel.actualizarPerfil(usuarioActualizado);

      if (resultado) {
        Navigator.pop(context, usuarioActualizado);
        Helpers.showSnackBar(
          context,
          '✅ Perfil actualizado exitosamente',
          type: 'success',
        );
      } else {
        Helpers.showSnackBar(
          context,
          '❌ Error al actualizar perfil',
          type: 'error',
        );
      }
    } catch (e) {
      Helpers.showSnackBar(
        context,
        '❌ Error al actualizar perfil: $e',
        type: 'error',
      );
    } finally {
      setState(() {
        _guardando = false;
      });
    }
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _guardando ? null : _guardarCambios,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Foto de perfil
              GestureDetector(
                onTap: _seleccionarFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _fotoUrl != null 
                          ? NetworkImage(_fotoUrl!) 
                          : null,
                      child: _fotoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.medium),
              Text(
                'Toca la foto para cambiar',
                style: TextStyle(
                  color: _getTextColor(context).withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: AppSpacing.large),

              // Campos editables
              _buildEditableField(
                context,
                'Nombre de Usuario',
                Icons.person,
                _usernameController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de usuario es obligatorio';
                  }
                  if (value.length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.medium),

              _buildEditableField(
                context,
                'Nombre Completo',
                Icons.badge,
                _nombreController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre completo es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.medium),

              _buildEditableField(
                context,
                'Correo Electrónico',
                Icons.email,
                _emailController,
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo electrónico es obligatorio';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.medium),

              _buildEditableField(
                context,
                'Teléfono (Opcional)',
                Icons.phone,
                _telefonoController,
                (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[0-9+]{7,15}$').hasMatch(value)) {
                      return 'Ingresa un teléfono válido';
                    }
                  }
                  return null;
                },
                esOpcional: true,
              ),
              SizedBox(height: AppSpacing.large),

              // Información no editable
              Card(
                color: _getCardColor(context),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Sistema (No editable)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium),
                      _buildInfoRow('Rol:', widget.usuario.rolDisplay, context),
                      _buildInfoRow('Carnet:', widget.usuario.carnet, context),
                      _buildInfoRow('Departamento:', widget.usuario.departamento, context),
                      _buildInfoRow('Estado:', widget.usuario.estaActivo ? 'Activo' : 'Inactivo', context),
                      _buildInfoRow('ID Usuario:', widget.usuario.id, context),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.large),

              // Botones de acción
              if (_guardando)
                CircularProgressIndicator(color: AppColors.primary),
              
              SizedBox(height: AppSpacing.medium),
              
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarCambios,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text(
                  'Guardar Cambios',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.medium,
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              
              SizedBox(height: AppSpacing.small),
              
              TextButton.icon(
                onPressed: _guardando ? null : () {
                  _cargarDatosUsuario();
                  _formKey.currentState?.reset();
                },
                icon: Icon(Icons.refresh, color: AppColors.primary),
                label: Text(
                  'Restablecer Cambios',
                  style: TextStyle(color: AppColors.primary),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller,
    String? Function(String?)? validator, {
    bool esOpcional = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (esOpcional ? ' (Opcional)' : ''),
        labelStyle: TextStyle(color: _getTextColor(context)),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTextColor(context).withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}