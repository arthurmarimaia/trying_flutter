import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/locale_controller.dart';

class ProfileLoginScreen extends StatefulWidget {
  const ProfileLoginScreen({super.key});

  @override
  State<ProfileLoginScreen> createState() => _ProfileLoginScreenState();
}

class _ProfileLoginScreenState extends State<ProfileLoginScreen> {
  List<Map<String, dynamic>> _profiles = [];
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final auth = context.read<AuthService>();
    final profiles = await auth.listProfiles();
    if (mounted) setState(() { _profiles = profiles; _loading = false; });
  }

  Future<void> _selectProfile(String username) async {
    await context.read<AuthService>().selectProfile(username);
  }

  Future<void> _deleteProfile(String username) async {
    final s = context.read<LocaleController>().s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.profileDeleteTitle),
        content: Text(s.profileDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.profileDeleteBtn),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthService>().deleteProfile(username);
      await _loadProfiles();
    }
  }

  void _showCreateDialog() {
    setState(() => _creating = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // Language toggle — top right
              Positioned(
                top: 8,
                right: 12,
                child: _LocaleToggleButton(),
              ),

              if (_creating)
                _CreateProfileView(
                  onCreated: () {
                    setState(() => _creating = false);
                    _loadProfiles();
                  },
                  onCancel: () => setState(() => _creating = false),
                )
              else
                _ProfileSelectionView(
                  profiles: _profiles,
                  loading: _loading,
                  onSelect: _selectProfile,
                  onDelete: _deleteProfile,
                  onCreate: _showCreateDialog,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile selection view ───────────────────────────────────────────────────

class _ProfileSelectionView extends StatelessWidget {
  final List<Map<String, dynamic>> profiles;
  final bool loading;
  final Future<void> Function(String) onSelect;
  final Future<void> Function(String) onDelete;
  final VoidCallback onCreate;

  const _ProfileSelectionView({
    required this.profiles,
    required this.loading,
    required this.onSelect,
    required this.onDelete,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.watch<LocaleController>().s;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
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
              s.profileSelectSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            if (loading)
              const CircularProgressIndicator()
            else ...[
              // Existing profiles
              ...profiles.map((p) {
                final username = p['username'] as String;
                final avatar = p['avatar'] as String? ?? '🐾';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelect(username),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(avatar,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                username,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: theme.colorScheme.error, size: 22),
                              onPressed: () => onDelete(username),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // New profile button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: Text(s.profileCreateBtn),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Create profile view ──────────────────────────────────────────────────────

class _CreateProfileView extends StatefulWidget {
  final VoidCallback onCreated;
  final VoidCallback onCancel;

  const _CreateProfileView({
    required this.onCreated,
    required this.onCancel,
  });

  @override
  State<_CreateProfileView> createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<_CreateProfileView> {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedAvatar = profileAvatars.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _busy = true; _error = null; });
    final auth = context.read<AuthService>();
    final err = await auth.createProfile(_nameCtrl.text, _selectedAvatar);
    if (err != null) {
      if (mounted) setState(() { _busy = false; _error = err; });
    } else {
      // Profile created and auto-selected — no need to call onCreated
      // because AuthService.notifyListeners() will trigger MyApp rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.watch<LocaleController>().s;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            Text(
              s.profileCreateTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Avatar picker
            Text(s.profileChooseAvatar,
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profileAvatars.map((avatar) {
                final selected = avatar == _selectedAvatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.primary, width: 2.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(avatar, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Name field
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: s.profileNameLabel,
                  hintText: s.profilePlayerNameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                textInputAction: TextInputAction.done,
                autocorrect: false,
                onFieldSubmitted: (_) => _create(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return s.validUserEmpty;
                  if (v.trim().length < 3) return s.validUserMin;
                  return null;
                },
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            color: theme.colorScheme.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : _create,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : Text(s.profileCreateBtn,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
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
