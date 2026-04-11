import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/locale_controller.dart';

class ProfileLoginScreen extends StatefulWidget {
  const ProfileLoginScreen({super.key});

  @override
  State<ProfileLoginScreen> createState() => _ProfileLoginScreenState();
}

class _ProfileLoginScreenState extends State<ProfileLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _loginForm     = GlobalKey<FormState>();
  final _registerForm  = GlobalKey<FormState>();

  final _loginUser  = TextEditingController();
  final _loginPass  = TextEditingController();
  final _regUser    = TextEditingController();
  final _regPass    = TextEditingController();
  final _regConfirm = TextEditingController();

  bool _loginObscure  = true;
  bool _regObscure    = true;
  bool _confObscure   = true;
  bool _busy          = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginUser.dispose();
    _loginPass.dispose();
    _regUser.dispose();
    _regPass.dispose();
    _regConfirm.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!(_loginForm.currentState?.validate() ?? false)) return;
    setState(() { _busy = true; _error = null; });
    final auth = context.read<AuthService>();
    final err = await auth.login(_loginUser.text, _loginPass.text);
    if (mounted) setState(() { _busy = false; _error = err; });
  }

  Future<void> _doRegister() async {
    if (!(_registerForm.currentState?.validate() ?? false)) return;
    setState(() { _busy = true; _error = null; });
    final auth = context.read<AuthService>();
    final err = await auth.register(_regUser.text, _regPass.text);
    if (mounted) setState(() { _busy = false; _error = err; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.watch<LocaleController>().s;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Globe language button — top-right
              Positioned(
                top: 8,
                right: 12,
                child: _LocaleToggleButton(),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    children: [
                      // Logo / title
                      const Text('🐾', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        'Tamagotchi',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tab bar
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TabBar(
                                controller: _tabCtrl,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorScheme.primaryContainer,
                                ),
                                labelColor: theme.colorScheme.onPrimaryContainer,
                                unselectedLabelColor:
                                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                dividerColor: Colors.transparent,
                                tabs: [
                                  Tab(text: s.tabLogin),
                                  Tab(text: s.tabRegister),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                height: _tabCtrl.index == 0 ? 180 : 260,
                                child: TabBarView(
                                  controller: _tabCtrl,
                                  children: [
                                    _LoginForm(
                                      formKey: _loginForm,
                                      userCtrl: _loginUser,
                                      passCtrl: _loginPass,
                                      obscure: _loginObscure,
                                      onToggleObscure: () =>
                                          setState(() => _loginObscure = !_loginObscure),
                                      onSubmit: _doLogin,
                                    ),
                                    _RegisterForm(
                                      formKey: _registerForm,
                                      userCtrl: _regUser,
                                      passCtrl: _regPass,
                                      confirmCtrl: _regConfirm,
                                      obscure: _regObscure,
                                      confObscure: _confObscure,
                                      onToggleObscure: () =>
                                          setState(() => _regObscure = !_regObscure),
                                      onToggleConfObscure: () =>
                                          setState(() => _confObscure = !_confObscure),
                                      onSubmit: _doRegister,
                                    ),
                                  ],
                                ),
                              ),

                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: theme.colorScheme.error, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: TextStyle(
                                              color: theme.colorScheme.error,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : (_tabCtrl.index == 0
                                          ? _doLogin
                                          : _doRegister),
                                  style: FilledButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: _busy
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(
                                          _tabCtrl.index == 0
                                              ? s.btnLogin
                                              : s.btnRegister,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

// ── Locale toggle button (globe icon) ───────────────────────────────────────

class _LocaleToggleButton extends StatelessWidget {
  const _LocaleToggleButton();

  @override
  Widget build(BuildContext context) {
    final lc = context.watch<LocaleController>();
    return Tooltip(
      message: lc.isEn ? 'Português (BR)' : 'English',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: lc.toggle,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 22),
              const SizedBox(width: 4),
              Text(
                lc.isEn ? 'EN' : 'PT',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Login form ───────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _UserField(ctrl: userCtrl),
          const SizedBox(height: 12),
          _PassField(
            ctrl: passCtrl,
            obscure: obscure,
            onToggle: onToggleObscure,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

// ── Register form ────────────────────────────────────────────────────────────

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool obscure;
  final bool confObscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleConfObscure;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.obscure,
    required this.confObscure,
    required this.onToggleObscure,
    required this.onToggleConfObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return Form(
      key: formKey,
      child: Column(
        children: [
          _UserField(ctrl: userCtrl, isRegister: true),
          const SizedBox(height: 12),
          _PassField(
            ctrl: passCtrl,
            label: s.fieldPasswordMin,
            obscure: obscure,
            onToggle: onToggleObscure,
          ),
          const SizedBox(height: 12),
          _PassField(
            ctrl: confirmCtrl,
            label: s.fieldConfirm,
            obscure: confObscure,
            onToggle: onToggleConfObscure,
            validator: (v) {
              if (v != passCtrl.text) return s.validPassMatch;
              return null;
            },
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

// ── Shared form fields ───────────────────────────────────────────────────────

class _UserField extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isRegister;
  const _UserField({required this.ctrl, this.isRegister = false});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: s.fieldUsername,
        prefixIcon: const Icon(Icons.person_outline),
        hintText: isRegister ? s.fieldUserHint : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textInputAction: TextInputAction.next,
      autocorrect: false,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return s.validUserEmpty;
        if (v.trim().length < 3) return s.validUserMin;
        return null;
      },
    );
  }
}

class _PassField extends StatelessWidget {
  final TextEditingController ctrl;
  final String? label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmit;

  const _PassField({
    required this.ctrl,
    this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label ?? s.fieldPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textInputAction:
          onSubmit != null ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: onSubmit != null ? (_) => onSubmit!() : null,
      validator: validator ??
          (v) {
            if (v == null || v.isEmpty) return s.validPassEmpty;
            if (v.length < 4) return s.validPassMin;
            return null;
          },
    );
  }
}
