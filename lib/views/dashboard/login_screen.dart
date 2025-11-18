//view/dasboar/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:incos_check/utils/constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/usuario_model.dart';
import '../dashboard/dashboard_screen.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // 🌟 NUEVO: Focus nodes para mejor manejo del teclado
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // 🌟 NUEVO: Credenciales de prueba mejoradas
  final List<Map<String, String>> _testCredentials = [
    {
      'user': 'admin', 
      'pass': 'admin123', 
      'role': 'Administrador',
      'description': 'Acceso completo al sistema'
    },
    {
      'user': 'profesor', 
      'pass': 'profesor123', 
      'role': 'Docente',
      'description': 'Gestión de cursos y asistencia'
    },
    {
      'user': 'director', 
      'pass': 'director123', 
      'role': 'Director Académico',
      'description': 'Reportes y estadísticas'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _cargarConfiguracionGuardada();
    
    // 🌟 NUEVO: Verificar sesión después de la inicialización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  // 🌟 NUEVO: Cargar configuración guardada (remember me)
  void _cargarConfiguracionGuardada() async {
    // Aquí podrías cargar si el usuario marcó "Recordarme"
    // Por ahora lo dejamos como falso
    _rememberMe = false;
  }

  Future<void> _checkExistingSession() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // 🌟 MEJORADO: Mostrar loading mientras verifica
    if (!authViewModel.sessionChecked) {
      await authViewModel.initializeSession();
      
      if (authViewModel.isLoggedIn && authViewModel.currentUser != null) {
        _navigateToDashboard(authViewModel.currentUser!);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              // 🌟 MEJORADO: Header con más animaciones
              _buildAnimatedHeader(),
              const SizedBox(height: AppSpacing.xlarge),
              
              // 🌟 MEJORADO: Login card con scale animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildLoginCard(),
              ),
              const SizedBox(height: AppSpacing.xlarge),
              
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // 🌟 MEJORADO: Header con más detalles
  Widget _buildAnimatedHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Logo con efecto de profundidad
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fingerprint_rounded, // 🌟 NUEVO: Ícono más representativo
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            
            // Título principal
            Text(
              AppStrings.appName,
              style: AppTextStyles.heading1.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            
            // Subtítulo
            Text(
              'Instituto Comercial Superior El Alto',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 🌟 NUEVO: Badge de versión
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.small),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.small,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                'v1.0 - Sistema Biométrico',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large), // 🌟 MEJORADO: Border radius más grande
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 25),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 🌟 MEJORADO: Header de la card
          _buildLoginCardHeader(),
          const SizedBox(height: AppSpacing.large),

          // Campos de formulario
          _buildUsernameField(),
          const SizedBox(height: AppSpacing.medium),
          _buildPasswordField(),
          const SizedBox(height: AppSpacing.medium),

          // 🌟 NUEVO: Opciones adicionales
          _buildLoginOptions(),
          const SizedBox(height: AppSpacing.medium),

          // 🌟 MEJORADO: Credenciales de prueba
          _buildTestCredentialsSection(),
          const SizedBox(height: AppSpacing.medium),

          // Mensaje de error
          _buildErrorWidget(),
          const SizedBox(height: AppSpacing.medium),

          // Botón de login
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildLoginCardHeader() {
    return Column(
      children: [
        Text(
          'Bienvenido/a',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          'Ingresa a tu cuenta para continuar',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        // 🌟 NUEVO: Indicador de seguridad
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.small),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.success,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'Conexión segura',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuario',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              hintText: 'Ingresa tu usuario',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: 16,
              ),
            ),
            onChanged: (_) => _clearError(),
            onSubmitted: (_) {
              _passwordFocus.requestFocus();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              hintText: 'Ingresa tu contraseña',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: 16,
              ),
            ),
            onChanged: (_) => _clearError(),
            onSubmitted: (_) => _login(),
          ),
        ),
      ],
    );
  }

  // 🌟 CORREGIDO: Opciones de login sin overflow
Widget _buildLoginOptions() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isSmallScreen = constraints.maxWidth < 400;
      
      return Column(
        children: [
          // Remember me siempre visible
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                'Recordar usuario',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Botón de olvidé contraseña - adaptativo
          SizedBox(
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showForgotPasswordDialog();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildTestCredentialsSection() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      collapsedBackgroundColor: AppColors.info.withOpacity(0.05),
      backgroundColor: AppColors.info.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      leading: Icon(Icons.info_outline_rounded, color: AppColors.info),
      title: Text(
        'Credenciales de Prueba',
        style: AppTextStyles.body.copyWith(
          color: AppColors.info,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: _testCredentials.map((cred) {
        return ListTile(
          dense: true,
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getRoleIcon(cred['role']!),
              size: 16,
              color: AppColors.info,
            ),
          ),
          title: Text(
            '${cred['user']} • ${cred['role']}',
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Contraseña: ${cred['pass']}',
            style: AppTextStyles.body.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: AppColors.info,
          ),
          onTap: () {
            _usernameController.text = cred['user']!;
            _passwordController.text = cred['pass']!;
            _clearError();
          },
        );
      }).toList(),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings_rounded;
      case 'docente':
        return Icons.school_rounded;
      case 'director académico':
        return Icons.manage_accounts_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Widget _buildErrorWidget() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.error == null) return const SizedBox();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Text(
                  authViewModel.error!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: AppColors.error),
                onPressed: () => authViewModel.limpiarError(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return SizedBox(
          width: double.infinity,
          child: AnimatedContainer(
            duration: AppDurations.medium,
            decoration: BoxDecoration(
              gradient: authViewModel.isLoading
                  ? LinearGradient(
                      colors: [
                        AppColors.textSecondary.withOpacity(0.6),
                        AppColors.textSecondary.withOpacity(0.4),
                      ],
                    )
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: authViewModel.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: InkWell(
                onTap: authViewModel.isLoading ? null : _login,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (authViewModel.isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      const SizedBox(width: AppSpacing.small),
                      AnimatedOpacity(
                        duration: AppDurations.short,
                        opacity: authViewModel.isLoading ? 0.7 : 1.0,
                        child: Text(
                          authViewModel.isLoading ? 'Verificando...' : 'Ingresar al Sistema',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Sistema de Gestión Académica Biométrica',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Base de Datos Local • Conexión Segura',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 🌟 NUEVO: Información de desarrolladores
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.large),
            padding: const EdgeInsets.all(AppSpacing.small),
            child: Text(
              'Desarrollado para INCOS El Alto © 2024',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearError() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.error != null) {
      authViewModel.limpiarError();
    }
  }

  // 🌟 CORREGIDO: Método _login completamente funcional
  void _login() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 🌟 CORREGIDO: Validaciones mejoradas
    final validationError = _validateInputs(username, password);
    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    final success = await authViewModel.login(username, password);
    
    if (success && authViewModel.currentUser != null) {
      _navigateToDashboard(authViewModel.currentUser!);
    }
  }

  // 🌟 NUEVO: Método de validación separado
  String? _validateInputs(String username, String password) {
    if (username.isEmpty || password.isEmpty) {
      return 'Por favor, completa todos los campos';
    }

    if (username.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null; // No hay errores
  }

  // 🌟 NUEVO: Método para mostrar errores de validación
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
    );
  }

  void _navigateToDashboard(Usuario usuario) {
    final userData = {
      'id': usuario.id,
      'username': usuario.username,
      'email': usuario.email,
      'nombre': usuario.nombre,
      'password': usuario.password,
      'role': usuario.role,
      'carnet': usuario.carnet,
      'departamento': usuario.departamento,
      'esta_activo': usuario.estaActivo,
      'fecha_registro': usuario.fechaRegistro.toIso8601String(),
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => DashboardViewModel(userData: userData),
          child: DashboardScreen(userData: userData),
        ),
      ),
    );
  }

  // 🌟 NUEVO: Diálogo para olvidó contraseña (placeholder)
  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.small),
            Text(
              'Recuperar Contraseña',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        content: Text(
          'Esta funcionalidad estará disponible pronto. '
          'Por favor, contacta al administrador del sistema.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}