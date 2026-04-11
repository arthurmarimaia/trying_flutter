import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;
    final lc = context.watch<LocaleController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile.adaptive(
            value: controller.notificationsEnabled,
            onChanged: (value) async {
              controller.notificationsEnabled = value;
            },
            title: Text(s.settingsNotifTitle),
            subtitle: Text(s.settingsNotifSubtitle),
          ),
          const Divider(height: 32),
          _SectionHeader(label: s.settingsLanguageSection),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<AppLocale>(
              groupValue: lc.locale,
              onChanged: (v) { if (v != null) lc.setLocale(v); },
              child: Column(
                children: [
                  RadioListTile<AppLocale>(
                    value: AppLocale.pt,
                    secondary: const Text('🇧🇷', style: TextStyle(fontSize: 22)),
                    title: Text(s.languagePt),
                  ),
                  const Divider(height: 1, indent: 56),
                  RadioListTile<AppLocale>(
                    value: AppLocale.en,
                    secondary: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                    title: Text(s.languageEn),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
          _SectionHeader(label: s.settingsBackupSection),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: Text(s.settingsExportTitle),
                  subtitle: Text(s.settingsExportSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _exportBackup(context, controller, s),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(s.settingsImportTitle),
                  subtitle: Text(s.settingsImportSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showImportDialog(context, controller, s),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(
      BuildContext context, PetController controller, AppStrings s) async {
    final json = controller.exportBackupJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.settingsExportDone),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showImportDialog(
      BuildContext context, PetController controller, AppStrings s) async {
    final textCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.settingsImportDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.settingsImportDialogBody,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: s.settingsImportHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.settingsImportTitle)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final input = textCtrl.text.trim();
    if (input.isEmpty) return;
    final error = await controller.importBackupJson(input);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? s.settingsImportSuccess),
        backgroundColor: error == null ? Colors.green.shade700 : Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    );
  }
}


