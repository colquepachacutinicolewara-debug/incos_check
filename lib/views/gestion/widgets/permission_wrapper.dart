// widgets/permission_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class PermissionWrapper extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;
  final bool showError;

  const PermissionWrapper({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);
    
    if (authViewModel.isLoggedIn && authViewModel.tienePermiso(permission)) {
      return child;
    }
    
    if (fallback != null) {
      return fallback!;
    }
    
    if (showError) {
      return _buildAccessDenied(context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No tienes permisos para acceder a esta función',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 WRAPPER PARA MÓDULOS COMPLETOS
class ModuleWrapper extends StatelessWidget {
  final String module;
  final Widget child;
  final Widget? loadingWidget;

  const ModuleWrapper({
    super.key,
    required this.module,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);
    
    if (authViewModel.isLoading) {
      return loadingWidget ?? Center(child: CircularProgressIndicator());
    }
    
    if (!authViewModel.puedeAccederModulo(module)) {
      return _buildModuleAccessDenied(context, module);
    }
    
    return child;
  }

  Widget _buildModuleAccessDenied(BuildContext context, String module) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceso Denegado'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Acceso Restringido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'No tienes permisos para acceder al módulo de $module',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver al Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}