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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    
    // ✅ VERIFICAR SI HAY SESIÓN GUARDADA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  Future<void> _checkExistingSession() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!authViewModel.sessionChecked) {
      await authViewModel.verificarSesionGuardada();
      
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xlarge),
                  _buildLoginCard(),
                  const SizedBox(height: AppSpacing.xlarge),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (todos tus métodos _buildHeader, _buildLoginCard, etc. se mantienen igual hasta _buildErrorWidget)

  Widget _buildErrorWidget() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.error == null) return const SizedBox();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
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
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
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
            duration: AppDurations.short,
            decoration: BoxDecoration(
              gradient: authViewModel.isLoading
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(AppRadius.small),
              boxShadow: authViewModel.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: authViewModel.isLoading ? AppColors.textSecondary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: InkWell(
                onTap: authViewModel.isLoading ? null : _login,
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (authViewModel.isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      const SizedBox(width: AppSpacing.small),
                      Text(
                        authViewModel.isLoading ? 'Ingresando...' : AppStrings.login,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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

  void _login() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final success = await authViewModel.login(username, password);
    
    if (success && authViewModel.currentUser != null) {
      _navigateToDashboard(authViewModel.currentUser!);
    }
  }

  void _navigateToDashboard(Usuario usuario) {
    // Convertir Usuario a Map para compatibilidad con tu Dashboard actual
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

  // ... (el resto de tus métodos _buildHeader, _buildUsernameField, etc. se mantienen igual)
  Widget _buildHeader() {
    return Column(
      children: [
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
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          AppStrings.appName,
          style: AppTextStyles.heading1.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          'Instituto Comercial Superior El Alto',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Bienvenido/a',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Ingresa a tu cuenta',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.large),

          // Campo de usuario
          _buildUsernameField(),
          const SizedBox(height: AppSpacing.medium),

          // Campo de contraseña
          _buildPasswordField(),
          const SizedBox(height: AppSpacing.medium),

          // Información de credenciales de prueba
          _buildTestCredentials(),
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

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usuario',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.small),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              hintText: 'Ingresa tu usuario',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
              ),
            ),
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
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.small),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
              ),
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestCredentials() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Credenciales de Prueba',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Usuario: admin / Contraseña: admin123',
            style: AppTextStyles.body.copyWith(
              color: AppColors.info,
              fontSize: 12,
            ),
          ),
          Text(
            'Usuario: profesor / Contraseña: profesor123',
            style: AppTextStyles.body.copyWith(
              color: AppColors.info,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Sistema de Gestión Académica',
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
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Sistema Seguro - Base de Datos Local',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}