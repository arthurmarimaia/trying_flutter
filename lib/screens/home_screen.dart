import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';

import '../screens/store_screen.dart';
import '../screens/minigames_screen.dart';
import '../screens/evolution_screen.dart';
import '../screens/adventure_screen.dart';
import '../widgets/goal_card.dart';
import '../widgets/pet_sprite_widget.dart';
import '../models/adventure.dart';
import '../screens/daily_quests_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/inventory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performAction(Future<void> Function() action) async {
    _animationController.forward(from: 0.0);
    await action();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();

    if (controller.loading) {
      return const _LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamagotchi'),
        actions: [
          // Inventory button
          Builder(builder: (context) {
            final totalItems = controller.inventory.values
                .fold<int>(0, (sum, v) => sum + v);
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.backpack),
                  onPressed: () => Navigator.push(
                    context,
                    _slideRoute(const InventoryScreen()),
                  ),
                  tooltip: 'Inventário',
                ),
                if (totalItems > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$totalItems',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.transform),
            onPressed: () {
              Navigator.of(context).push(
                _slideRoute(
                  EvolutionScreen(
                    currentForm: controller.currentPetForm,
                    petLevel: controller.pet.level,
                    petStats: {
                      'health': controller.pet.health,
                      'happiness': controller.pet.happiness,
                      'energy': controller.pet.energy,
                      'hunger': controller.pet.hunger,
                      'experience': controller.pet.experience,
                      'strength': controller.pet.health,
                      'coins': controller.pet.coins,
                      'gamesPlayed': controller.miniGameStats.totalGamesPlayed,
                      'totalAdventures': controller.totalAdventuresCompleted,
                      'loginStreak': controller.loginStreak,
                    },
                    selectedAccessory: controller.selectedAccessory.isEmpty ? null : controller.selectedAccessory,
                    onEvolutionSelect: controller.evolvePet,
                  ),
                ),
              );
            },
            tooltip: 'Evoluções',
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                _slideRoute(
                  AdventureScreen(
                    currentAdventure: controller.currentAdventure,
                    onAdventureStart: controller.startAdventure,
                    onAdventureComplete: controller.completeAdventure,
                    adventureLog: controller.adventureLog,
                  ),
                ),
              );
            },
            tooltip: 'Aventuras',
          ),
          IconButton(
            icon: const Icon(Icons.sports_esports),
            onPressed: () {
              Navigator.of(context).push(
                _slideRoute(
                  MiniGamesScreen(
                    onGameComplete: controller.processGameResult,
                    stats: controller.miniGameStats,
                  ),
                ),
              );
            },
            tooltip: 'Mini-Games',
          ),
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.of(context).push(
                _slideRoute(const StoreScreen()),
              );
            },
            tooltip: 'Abrir loja',
          ),
          IconButton(
            icon: Icon(controller.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: controller.toggleTheme,
            tooltip: 'Modo claro/escuro',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_events),
                onPressed: () {
                  Navigator.push(
                    context,
                    _slideRoute(const AchievementsScreen()),
                  );
                },
                tooltip: 'Conquistas',
              ),
              if (controller.newlyUnlockedAchievements.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${controller.newlyUnlockedAchievements.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                _slideRoute(const DailyQuestsScreen()),
              );
            },
            tooltip: 'Missões Diárias',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                _slideRoute(const SettingsScreen()),
              );
            },
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: controller.isDarkMode
                ? [Colors.black87, Colors.deepPurple.shade900]
                : [Colors.purple.shade100, Colors.blue.shade200],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(255, 255, 255, 0.08),
                ),
              ),
            ),
            Positioned(
              top: 180,
              right: 20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(255, 255, 255, 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 40,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(255, 255, 255, 0.06),
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: controller.refreshState,
              child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ToyConsole(controller: controller, onAction: _performAction),
                if (controller.currentAdventure != null && controller.currentAdventure!.isActive)
                  _AdventureIndicator(adventure: controller.currentAdventure!),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        controller.pet.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_emotions, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            controller.petMood,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Última interação: ${controller.lastInteraction}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(242),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Evento do dia', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 10),
                        Text(controller.currentEventText, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _ToyExperienceBar(experience: controller.pet.experience),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Moedas', style: Theme.of(context).textTheme.labelLarge),
                      Text('${controller.pet.coins}', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const SizedBox(height: 24),
                Text('Metas diárias', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...controller.dailyGoals.map((goal) => GoalCard(goal: goal)),
                const SizedBox(height: 24),
                Text('Conquistas recentes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (controller.achievements.isEmpty)
                  const Text('Nenhuma conquista ainda. Continue cuidando!')
                else
                  Column(
                    children: controller.achievements
                        .reversed
                        .take(3)
                        .map(
                          (achievement) => ListTile(
                            leading: const Icon(Icons.star, color: Colors.amber),
                            title: Text(achievement),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: controller.resetProgress,
                  child: const Text('Reiniciar metas de hoje'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}

class _ToyExperienceBar extends StatelessWidget {
  final int experience;

  const _ToyExperienceBar({required this.experience});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxExp = 100;
    final normalizedExp = (experience % maxExp).toDouble();
    final controller = Provider.of<PetController>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.tertiary.withAlpha(200), theme.colorScheme.secondary.withAlpha(150)],
        ),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Experiência', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${experience.toString()} XP', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: normalizedExp / maxExp),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, animValue, __) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: animValue,
                minHeight: 20,
                backgroundColor: Colors.white.withAlpha(80),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(Colors.orange, Colors.purple, animValue) ?? Colors.purple,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.assignment_rounded),
                if (controller.dailyQuestsCompleted.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.dailyQuestsCompleted.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                _slideRoute(const DailyQuestsScreen()),
              );
            },
            tooltip: 'Missões Diárias',
          ),
        ],
      ),
    );
  }
}

class _ToyStatusBarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final bool inverseColor;

  const _ToyStatusBarItem({
    required this.label,
    required this.icon,
    required this.value,
    this.inverseColor = false,
  });

  Color _getStatusColor() {
    final percent = value / 100.0;
    if (inverseColor) {
      if (percent > 0.66) return Colors.red;
      if (percent > 0.33) return Colors.orange;
      return Colors.green;
    } else {
      if (percent < 0.33) return Colors.red;
      if (percent < 0.66) return Colors.orange;
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 28,
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: AlwaysStoppedAnimation<Color>(color.withAlpha(220)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToyConsole extends StatelessWidget {
  final PetController controller;
  final Future<void> Function(Future<void> Function()) onAction;

  const _ToyConsole({required this.controller, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary.withAlpha(220), theme.colorScheme.secondary.withAlpha(180)],
        ),
        border: Border.all(color: Colors.white24, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ToyLED(color: Colors.redAccent),
              const SizedBox(width: 10),
              _ToyLED(color: Colors.orangeAccent),
              const SizedBox(width: 10),
              _ToyLED(color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(220),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'PET TOY',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 12),
                _ShakingPetView(controller: controller),
                const SizedBox(height: 14),
                Text(
                  '${controller.pet.stage} • Nível ${controller.pet.level}',
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            spacing: 12,
            children: [
              _ToyStatusBarItem(label: 'Fome', icon: Icons.restaurant, value: controller.pet.hunger, inverseColor: true),
              _ToyStatusBarItem(label: 'Energia', icon: Icons.bolt, value: controller.pet.energy),
              _ToyStatusBarItem(label: 'Felicidade', icon: Icons.favorite, value: controller.pet.happiness),
              _ToyStatusBarItem(label: 'Saúde', icon: Icons.health_and_safety, value: controller.pet.health),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _ToyActionButton(label: 'Alimentar', icon: Icons.restaurant, onTap: () => onAction(controller.feed), enabled: controller.canFeed()),
              _ToyActionButton(label: 'Dormir', icon: Icons.bedtime, onTap: () => onAction(controller.sleep), enabled: controller.canSleep()),
              _ToyActionButton(label: 'Brincar', icon: Icons.sports_basketball, onTap: () => onAction(controller.play), enabled: controller.canPlay()),
              _ToyActionButton(label: 'Limpar', icon: Icons.bathtub, onTap: () => onAction(controller.clean), enabled: controller.canClean()),
              _ToyActionButton(label: 'Medicar', icon: Icons.medical_services, onTap: () => onAction(controller.heal), enabled: controller.canHeal()),
              _ToyActionButton(label: 'Treinar', icon: Icons.fitness_center, onTap: () => onAction(controller.train), enabled: controller.canTrain()),
              _ToyActionButton(label: 'Carinho', icon: Icons.favorite, onTap: () => onAction(controller.cuddle), enabled: controller.canCuddle()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Floating emoji reaction that animates upward and fades out whenever [tick] changes.
class _PetReactionOverlay extends StatefulWidget {
  final String emoji;
  final int tick;

  const _PetReactionOverlay({required this.emoji, required this.tick});

  @override
  State<_PetReactionOverlay> createState() => _PetReactionOverlayState();
}

class _PetReactionOverlayState extends State<_PetReactionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _offsetY;
  String _currentEmoji = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _offsetY = Tween<double>(begin: 0, end: -50).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_PetReactionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tick != oldWidget.tick && widget.emoji.isNotEmpty) {
      _currentEmoji = widget.emoji;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context2, child2) => Positioned(
        top: 20 + _offsetY.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Text(_currentEmoji, style: const TextStyle(fontSize: 36)),
        ),
      ),
    );
  }
}

class _ToyLED extends StatelessWidget {
  final Color color;

  const _ToyLED({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withAlpha(180), blurRadius: 10, spreadRadius: 1),
        ],
      ),
    );
  }
}

class _ToyActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _ToyActionButton({required this.label, required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: enabled ? theme.colorScheme.primary : Colors.grey.shade700,
          shape: const CircleBorder(),
          elevation: 6,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class _AdventureIndicator extends StatelessWidget {
  final Adventure adventure;

  const _AdventureIndicator({required this.adventure});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${adventure.emoji} ${adventure.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(adventure.progressPercent * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: adventure.progressPercent,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            'Tempo restante: ${_formatTime(adventure.totalDurationSeconds - adventure.timeElapsedSeconds)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

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
            onChanged: (value) {
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

// ── Route helper ────────────────────────────────────────────────────────────

PageRouteBuilder<T> _slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

// ── Loading Screen ───────────────────────────────────────────────────────────

class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.12)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: const Text('🐶', style: TextStyle(fontSize: 90)),
              ),
              const SizedBox(height: 28),
              const Text(
                'Tamagotchi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Carregando seu pet...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shaking Pet View ─────────────────────────────────────────────────────────

class _ShakingPetView extends StatefulWidget {
  final PetController controller;
  const _ShakingPetView({required this.controller});

  @override
  State<_ShakingPetView> createState() => _ShakingPetViewState();
}

class _ShakingPetViewState extends State<_ShakingPetView>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  Timer? _shakeTimer;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    _shakeTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (widget.controller.needsAttention || widget.controller.isSick) {
        _shakeCtrl.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const RadialGradient(
                colors: [Colors.white24, Colors.transparent],
                stops: [0.0, 1.0],
              ),
            ),
          ),
          PetSpriteWidget(
            spriteAssets: c.pet.spriteAssets,
            size: 96,
          ),
          if (c.equippedAccessoryItem != null)
            Positioned(
              top: c.equippedAccessoryItem!.id == 'chapelinho' ? 8 : null,
              right: c.equippedAccessoryItem!.id == 'chapelinho' ? 20 : null,
              bottom: c.equippedAccessoryItem!.id != 'chapelinho' ? 12 : null,
              left: c.equippedAccessoryItem!.id != 'chapelinho' ? 12 : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  c.equippedAccessoryItem!.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          _PetReactionOverlay(
            emoji: c.lastReactionEmoji,
            tick: c.reactionTick,
          ),
          if (c.needsAttention || c.isSick)
            const Positioned(
              top: 12,
              right: 12,
              child: _BlinkingDot(),
            ),
        ],
      ),
    );
  }
}

// ── Blinking Attention Dot ───────────────────────────────────────────────────

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha(180),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

