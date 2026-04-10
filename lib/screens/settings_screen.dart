import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações ⚙️'),
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
            title: const Text('Lembretes inteligentes do pet'),
            subtitle: const Text('Receba notificações quando o pet precisar de atenção ou missões estiverem completas.'),
          ),
        ],
      ),
    );
  }
}
