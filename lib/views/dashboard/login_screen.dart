// views/login_screen.dart - MEJORADO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), 
      end: Offset.zero
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

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
                  _buildLoginCard(authViewModel),
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
          'Sistema de Gestión Académica',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(AuthViewModel authViewModel) {
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
            'Inicio de Sesión',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Ingresa con tus credenciales',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.large),

          _buildEmailField(),
          const SizedBox(height: AppSpacing.medium),

          _buildPasswordField(),
          const SizedBox(height: AppSpacing.medium),

          if (authViewModel.error != null) _buildErrorWidget(authViewModel.error!),
          const SizedBox(height: AppSpacing.medium),

          _buildLoginButton(authViewModel),
          const SizedBox(height: AppSpacing.medium),

          _buildForgotPassword(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo Institucional',
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
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_rounded, color: AppColors.primary),
              hintText: 'usuario@incos.edu.bo',
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
              prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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

  Widget _buildErrorWidget(String error) {
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
              error,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthViewModel authViewModel) {
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
            onTap: authViewModel.isLoading ? null : () => _login(authViewModel),
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
                    const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    authViewModel.isLoading ? 'Verificando...' : 'Iniciar Sesión',
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
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        _showForgotPasswordDialog();
      },
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Sistema Seguro - INCOS El Alto',
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
              'Conexión Segura',
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

  void _login(AuthViewModel authViewModel) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Messages.campoRequerido),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await authViewModel.signIn(email, password);
    
    if (success && context.mounted) {
      // La navegación se maneja automáticamente por AuthWrapper
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenido/a ${authViewModel.currentUser?.nombre}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingresa tu correo electrónico para restablecer tu contraseña:'),
            SizedBox(height: AppSpacing.medium),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(context);
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                await authViewModel.resetPassword(email);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Se ha enviado un enlace de recuperación a $email'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }
}