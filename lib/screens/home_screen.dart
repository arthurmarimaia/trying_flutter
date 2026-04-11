import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

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
import '../screens/onboarding_screen.dart';
import '../screens/daily_bonus_screen.dart';
import '../screens/history_screen.dart';
import '../screens/pet_profile_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Status bars shown in the AppBar bottom area.
class _PetStatusBar extends StatelessWidget {
  const _PetStatusBar({required this.controller});
  final PetController controller;

  @override
  Widget build(BuildContext context) {
    final pet = controller.pet;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final s = context.watch<LocaleController>().s;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Row(
        children: [
          _StatusBarItem(
            icon: '❤️',
            label: s.statHealth,
            value: pet.health,
            baseColor: const Color(0xFFE53935),
            labelColor: onSurface,
          ),
          const SizedBox(width: 10),
          _StatusBarItem(
            icon: '🍖',
            label: s.statHunger,
            value: 100 - pet.hunger,
            baseColor: const Color(0xFFF57C00),
            labelColor: onSurface,
          ),
          const SizedBox(width: 10),
          _StatusBarItem(
            icon: '⚡',
            label: s.statEnergy,
            value: pet.energy,
            baseColor: const Color(0xFFFBC02D),
            labelColor: onSurface,
          ),
        ],
      ),
    );
  }
}

class _StatusBarItem extends StatelessWidget {
  const _StatusBarItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.baseColor,
    required this.labelColor,
  });

  final String icon;
  final String label;
  final int value;
  final Color baseColor;
  final Color labelColor;

  Color get _barColor {
    if (value <= 20) return const Color(0xFFD32F2F);
    if (value <= 40) return const Color(0xFFF57C00);
    return baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final frac = (value / 100.0).clamp(0.0, 1.0);
    final valColor = _barColor;

    return Expanded(
      child: Tooltip(
        message: '$label: $value%',
        preferBelow: true,
        triggerMode: TooltipTriggerMode.tap,
        child: MouseRegion(
          cursor: SystemMouseCursors.help,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 11,
                    backgroundColor: baseColor.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(valColor),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 24,
                child: Text(
                  '$value',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: valColor,
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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;

    if (controller.loading) {
      return const _LoadingScreen();
    }

    if (controller.isFirstLaunch) {
      return const OnboardingScreen();
    }

    if (controller.dailyBonusPending) {
      return const DailyBonusScreen();
    }

    if (controller.isFainted) {
      return _PetFaintedScreen(controller: controller);
    }

    return Scaffold(
      body: Column(
        children: [
          // Status bar strip: hidden on Home tab (redundant), visible on all others
          if (_selectedIndex != 0)
            SafeArea(
              bottom: false,
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: _PetStatusBar(controller: controller),
              ),
            ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: _selectedIndex != 0,
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const _HomeTab(),
                  AdventureScreen(
                    currentAdventure: controller.currentAdventure,
                    onAdventureStart: controller.startAdventure,
                    onAdventureComplete: controller.completeAdventure,
                    adventureLog: controller.adventureLog,
                  ),
                  MiniGamesScreen(
                    onGameComplete: controller.processGameResult,
                    stats: controller.miniGameStats,
                  ),
                  const StoreScreen(),
                  const DailyQuestsScreen(),
                  _EvolutionTab(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pet',
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: s.navAdventures,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_esports_outlined),
            selectedIcon: const Icon(Icons.sports_esports),
            label: s.navGames,
          ),
          NavigationDestination(
            icon: const Icon(Icons.store_outlined),
            selectedIcon: const Icon(Icons.store),
            label: s.homeStore,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: controller.dailyQuestsCompleted.isNotEmpty,
              label: Text('${controller.dailyQuestsCompleted.length}'),
              child: const Icon(Icons.assignment_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: controller.dailyQuestsCompleted.isNotEmpty,
              label: Text('${controller.dailyQuestsCompleted.length}'),
              child: const Icon(Icons.assignment),
            ),
            label: s.homeMissions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: s.navEvolutions,
          ),
        ],
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  // Level-up overlay
  int? _pendingLevelDisplay;
  late AnimationController _levelUpCtrl;
  late Animation<double> _levelUpOffset;
  late Animation<double> _levelUpOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _levelUpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _levelUpOffset = Tween<double>(begin: 0, end: -90).animate(
      CurvedAnimation(parent: _levelUpCtrl, curve: Curves.easeOut),
    );
    _levelUpOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_levelUpCtrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<PetController>();
    final pending = controller.pendingLevelUp;
    if (pending != null && pending != _pendingLevelDisplay) {
      _pendingLevelDisplay = pending;
      controller.clearPendingLevelUp();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _levelUpCtrl.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _levelUpCtrl.dispose();
    super.dispose();
  }

  Future<void> _performAction(Future<void> Function() action) async {
    _animationController.forward(from: 0.0);
    await action();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;

    return Stack(
      children: [
    Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.push(
            context,
            _slideRoute(const PetProfileScreen()),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.pet.name.isEmpty ? 'Tamagotchi' : controller.pet.name),
              if (controller.activeTitle.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller.activeTitle,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 12),
            ],
          ),
        ),
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
                  tooltip: s.homeInventory,
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
          // Achievements button
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
                tooltip: s.homeAchievements,
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
          // Overflow menu: Histórico, Tema, Configurações
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'history':
                  Navigator.of(context).push(_slideRoute(const HistoryScreen()));
                case 'theme':
                  controller.toggleTheme();
                case 'settings':
                  Navigator.of(context)
                      .push(_slideRoute(const SettingsScreen()));
              }
            },
            itemBuilder: (context) {
              final ms = context.read<LocaleController>().s;
              return [
              PopupMenuItem(
                value: 'history',
                child: ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: Text(ms.homeHistoryHealth),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: ListTile(
                  leading: Icon(
                    controller.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                  ),
                  title: Text(controller.isDarkMode ? ms.homeLightModeLabel : ms.homeDarkModeLabel),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(ms.homeSettingsLabel),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ];},
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
                        s.petMessage(controller.pet.message),
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
                            s.petMoodLabel(controller.petMood),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${s.homeLastInteraction}: ${controller.lastInteraction}',
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
                        Text(s.homeDailyEvent, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 10),
                        Text(
                          controller.currentEvent == null
                              ? s.noActiveEvent
                              : '${s.eventTitle(controller.currentEvent!.id)}: ${s.eventDescription(controller.currentEvent!.id)}',
                          style: Theme.of(context).textTheme.bodyMedium),
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
                      Text(s.homeCoinsLabel, style: Theme.of(context).textTheme.labelLarge),
                      Text('${controller.pet.coins} / 999', style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Bond bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, size: 16, color: Colors.pinkAccent),
                              const SizedBox(width: 6),
                              Text(s.homeBondLabel, style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                          Text(
                            '${s.petBondLabel(controller.pet.bond)}  ${controller.pet.bond}/100',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: controller.pet.bond / 100,
                          minHeight: 8,
                          backgroundColor: Colors.pink.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                        ),
                      ),
                      if (controller.bondXpBonus > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            controller.bondBonusDescription,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.pinkAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(s.homeDailyGoalsLabel, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...controller.dailyGoals.map((goal) => GoalCard(goal: goal)),
                const SizedBox(height: 24),
                Text(s.homeRecentAchievements, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (controller.achievements.isEmpty)
                  Text(s.homeNoAchievements)
                else
                  Column(
                    children: controller.achievements
                        .reversed
                        .take(3)
                        .map(
                          (achievement) => ListTile(
                            leading: const Icon(Icons.star, color: Colors.amber),
                            title: Text(s.translateActivityEntry(achievement)),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: controller.resetProgress,
                  child: Text(s.homeResetGoalsBtn),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),
    // Level-up overlay
    if (_pendingLevelDisplay != null)
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _levelUpCtrl,
            builder: (context, child) => Opacity(
              opacity: _levelUpOpacity.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.35 +
                        _levelUpOffset.value,
                    child: child!,
                  ),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38,
                      blurRadius: 20,
                      offset: Offset(0, 8))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 32)),
                  Text(
                    '${s.homeLevelUpOverlay} $_pendingLevelDisplay!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 3))
                      ],
                    ),
                  ),
                  const Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
  ],
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
    final s = context.watch<LocaleController>().s;

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
              Text(context.watch<LocaleController>().s.homeExperienceLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${experience.toString()} XP', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: normalizedExp / maxExp),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, animValue, child) => ClipRRect(
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
            tooltip: s.homeDailyMissionsTooltip,
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
    const dots = 5;
    final filled = ((value / 100.0) * dots).round().clamp(0, dots);

    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: GoogleFonts.vt323(
              fontSize: 14,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...List.generate(dots, (i) {
          final active = i < filled;
          return Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : Colors.white.withAlpha(30),
              boxShadow: active
                  ? [BoxShadow(color: color.withAlpha(160), blurRadius: 5)]
                  : null,
            ),
          );
        }),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: GoogleFonts.vt323(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
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
    final s = context.watch<LocaleController>().s;
    // Plastic shell colours — warm purple/violet like classic Tamagotchi
    const shellLight = Color(0xFF8B5CF6);
    const shellDark  = Color(0xFF4C1D95);
    const shellEdge  = Color(0xFF2E1065);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shellLight, shellDark],
        ),
        boxShadow: const [
          // outer glow
          BoxShadow(color: Color(0x80000000), blurRadius: 28, offset: Offset(0, 12)),
          // top-left highlight (plastic shine)
          BoxShadow(color: Color(0x35FFFFFF), blurRadius: 0, offset: Offset(-2, -2)),
          // bottom-right depth
          BoxShadow(color: shellEdge, blurRadius: 0, spreadRadius: -1, offset: Offset(3, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top LED strip ──
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
            const SizedBox(height: 14),

            // ── LCD Screen ──
            _LcdScreen(controller: controller),

            const SizedBox(height: 16),

            // ── Status dots ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                spacing: 8,
                children: [
                  _ToyStatusBarItem(label: s.toyFome,    icon: Icons.restaurant,        value: controller.pet.hunger,    inverseColor: true),
                  _ToyStatusBarItem(label: s.statEnergy, icon: Icons.bolt,              value: controller.pet.energy),
                  _ToyStatusBarItem(label: s.toyHumor,   icon: Icons.favorite,          value: controller.pet.happiness),
                  _ToyStatusBarItem(label: s.toySaude,   icon: Icons.health_and_safety, value: controller.pet.health),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Action buttons ──
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _ToyActionButton(label: s.actionFeed,   icon: Icons.restaurant,        onTap: () => onAction(controller.feed),   enabled: controller.canFeed()),
                _ToyActionButton(label: s.actionSleep,  icon: Icons.bedtime,           onTap: () => onAction(controller.sleep),  enabled: controller.canSleep()),
                _ToyActionButton(label: s.actionPlay,   icon: Icons.sports_basketball, onTap: () => onAction(controller.play),   enabled: controller.canPlay()),
                _ToyActionButton(label: s.actionClean,  icon: Icons.bathtub,           onTap: () => onAction(controller.clean),  enabled: controller.canClean()),
                _ToyActionButton(label: s.actionHeal,   icon: Icons.medical_services,  onTap: () => onAction(controller.heal),   enabled: controller.canHeal()),
                _ToyActionButton(label: s.actionTrain,  icon: Icons.fitness_center,    onTap: () => onAction(controller.train),  enabled: controller.canTrain()),
                _ToyActionButton(label: s.actionCuddle, icon: Icons.favorite,          onTap: () => onAction(controller.cuddle), enabled: controller.canCuddle()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── LCD Screen Widget ─────────────────────────────────────────────────────────

class _LcdScreen extends StatelessWidget {
  final PetController controller;
  const _LcdScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    final name = controller.pet.name.isEmpty ? 'PET TOY' : controller.pet.name.toUpperCase();
    final info = 'LV.${controller.pet.level}  ${s.petStage(controller.pet.stage).toUpperCase()}';

    return Container(
      decoration: BoxDecoration(
        // Outer bezel — dark plastic ring
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1A0E2E),
        boxShadow: const [
          BoxShadow(color: Color(0xFF0D0720), blurRadius: 0, offset: Offset(3, 3)),
          BoxShadow(color: Color(0x30FFFFFF), blurRadius: 0, offset: Offset(-1, -1)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0A1A0A),   // LCD dark green background
          boxShadow: const [
            BoxShadow(color: Color(0x80000000), blurRadius: 8, spreadRadius: -2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Scanlines overlay
              Positioned.fill(
                child: CustomPaint(painter: _ScanlinesPainter()),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title bar
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 9,
                        color: const Color(0xFF86EFAC),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Pet sprite — centered
                    Center(child: _ShakingPetView(controller: controller)),
                    const SizedBox(height: 10),
                    // Info bar
                    Text(
                      info,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vt323(
                        fontSize: 18,
                        color: const Color(0xFF86EFAC),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scanlines CustomPainter ───────────────────────────────────────────────────

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x12000000)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter oldDelegate) => false;
}

/// Floating icon reaction that animates upward when [tick] changes.
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
  IconData _currentIcon = Icons.star;
  Color _currentColor = Colors.amber;

  static MapEntry<IconData, Color> _toIcon(String key) {
    return switch (key) {
      // Core actions
      'feed'          => MapEntry(Icons.restaurant,       Colors.orange),
      'sleep'         => MapEntry(Icons.bedtime,          Colors.blueAccent),
      'play'          => MapEntry(Icons.sports_basketball, Colors.deepOrange),
      'clean'         => MapEntry(Icons.auto_awesome,     Colors.lightBlue),
      'heal'          => MapEntry(Icons.medical_services, Colors.red),
      'train'         => MapEntry(Icons.fitness_center,   Colors.green),
      'cuddle'        => MapEntry(Icons.favorite,         Colors.pink),
      // Store items
      'racao_premium' => MapEntry(Icons.restaurant,       Colors.orange),
      'brinquedo'     => MapEntry(Icons.toys,             Colors.deepPurple),
      'spray_saude'   => MapEntry(Icons.healing,          Colors.green),
      'coleira_luz'   => MapEntry(Icons.auto_awesome,     Colors.lightBlue),
      'chapelinho'    => MapEntry(Icons.celebration,      Colors.pink),
      'ninja_mask'    => MapEntry(Icons.shield,           Colors.grey),
      'robot_suit'    => MapEntry(Icons.smart_toy,        Colors.blueGrey),
      'alien_helmet'  => MapEntry(Icons.public,           Colors.teal),
      'wizard_hat'    => MapEntry(Icons.auto_fix_high,    Colors.purple),
      'katana'        => MapEntry(Icons.flash_on,         Colors.red),
      'space_suit'    => MapEntry(Icons.rocket_launch,    Colors.blue),
      'cape'          => MapEntry(Icons.dark_mode,        Colors.deepPurple),
      _               => MapEntry(Icons.star,             Colors.amber),
    };
  }

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
      final entry = _toIcon(widget.emoji);
      _currentIcon = entry.key;
      _currentColor = entry.value;
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
      builder: (ctx, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _offsetY.value),
          child: child,
        ),
      ),
      child: Icon(
        _currentIcon,
        color: _currentColor,
        size: 40,
        shadows: const [Shadow(color: Colors.black38, blurRadius: 8)],
      ),
    );
  }
}

// ── Pet Status Overlay (persistent mood indicators) ─────────────────────────

class _PetStatusOverlay extends StatefulWidget {
  final bool showSleepy;   // energy <= 20
  final bool showHurt;     // health <= 20
  final bool showHappy;    // happiness >= 90

  const _PetStatusOverlay({
    required this.showSleepy,
    required this.showHurt,
    required this.showHappy,
  });

  @override
  State<_PetStatusOverlay> createState() => _PetStatusOverlayState();
}

class _PetStatusOverlayState extends State<_PetStatusOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _floatY;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.9, end: 1.15).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _floatY = Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sleepy ZZZ — bottom-left floating
        if (widget.showSleepy)
          Positioned(
            bottom: 10,
            left: 2,
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (ctx1, w1) => Transform.translate(
                offset: Offset(0, _floatY.value),
                child: Icon(
                  Icons.bedtime,
                  color: Colors.blueAccent.shade100,
                  size: 22,
                ),
              ),
            ),
          ),
        // Hurt pulse — top-left
        if (widget.showHurt)
          Positioned(
            top: 6,
            left: 6,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (ctx2, w2) => Transform.scale(
                scale: _pulseScale.value,
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
              ),
            ),
          ),
        // Happy sparkle — top-right floating
        if (widget.showHappy)
          Positioned(
            top: 4,
            right: 6,
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (ctx3, w3) => Transform.translate(
                offset: Offset(0, _floatY.value),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
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

class _ToyActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _ToyActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<_ToyActionButton> createState() => _ToyActionButtonState();
}

class _ToyActionButtonState extends State<_ToyActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    const btnColor   = Color(0xFF6D28D9);
    const btnTop     = Color(0xFF8B5CF6);
    const btnDisable = Color(0xFF4B5563);

    return GestureDetector(
      onTapDown: active ? (_) => _pressCtrl.forward() : null,
      onTapUp: active
          ? (_) {
              _pressCtrl.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 0.85,
                  colors: active
                      ? [btnTop, btnColor]
                      : [btnDisable.withAlpha(200), btnDisable],
                ),
                boxShadow: active
                    ? const [
                        // top highlight
                        BoxShadow(color: Color(0x55C4B5FD), blurRadius: 0,
                            offset: Offset(-2, -2)),
                        // bottom depth
                        BoxShadow(color: Color(0xFF3B0764), blurRadius: 0,
                            offset: Offset(2, 4)),
                        // outer glow
                        BoxShadow(color: Color(0x408B5CF6), blurRadius: 8,
                            offset: Offset(0, 4)),
                      ]
                    : const [
                        BoxShadow(color: Color(0x55000000), blurRadius: 4,
                            offset: Offset(1, 3)),
                      ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 60,
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(
                  fontSize: 13,
                  color: active ? Colors.white : Colors.white38,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdventureIndicator extends StatelessWidget {
  final Adventure adventure;

  const _AdventureIndicator({required this.adventure});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
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
            '${s.advTimeRemaining}: ${_formatTime(adventure.totalDurationSeconds - adventure.timeElapsedSeconds)}',
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

/// Thin wrapper so EvolutionScreen works as an IndexedStack tab.
class _EvolutionTab extends StatelessWidget {
  const _EvolutionTab({required this.controller});
  final PetController controller;

  @override
  Widget build(BuildContext context) {
    return EvolutionScreen(
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
      selectedAccessory: controller.selectedAccessory.isEmpty
          ? null
          : controller.selectedAccessory,
      onEvolutionSelect: controller.evolvePet,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;
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
            onChanged: (value) {
              controller.notificationsEnabled = value;
            },
            title: Text(s.settingsNotifTitle),
            subtitle: Text(s.settingsNotifSubtitle),
          ),
          SwitchListTile.adaptive(
            value: controller.soundEnabled,
            onChanged: (value) {
              controller.soundEnabled = value;
            },
            title: Text(s.settingsSoundTitle),
            subtitle: Text(s.settingsSoundSubtitle),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: Text(
              s.settingsResetTitle,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(s.settingsResetSubtitle),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  final ds = ctx.read<LocaleController>().s;
                  return AlertDialog(
                    title: Text(ds.settingsResetTitle),
                    content: Text(ds.settingsResetDialogContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(ds.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: Text(ds.settingsResetBtn),
                      ),
                    ],
                  );
                },
              );
              if (confirmed == true && context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                await context.read<PetController>().resetPet();
              }
            },
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: Text(
              s.settingsLogoutTitle,
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${s.settingsLogoutConnectedAs} ${context.read<AuthService>().activeUsername ?? ''}.',
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  final ds = ctx.read<LocaleController>().s;
                  return AlertDialog(
                    title: Text(ds.settingsLogoutDialogTitle),
                    content: Text(ds.settingsLogoutDialogContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(ds.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(ds.settingsLogoutBtn),
                      ),
                    ],
                  );
                },
              );
              if (confirmed == true && context.mounted) {
                await context.read<AuthService>().logout();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Route helper ────────────────────────────────────────────────────────────

PageRouteBuilder<T> _slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
              Text(
                context.watch<LocaleController>().s.homeLoadingText,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
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
            state: c.isFainted
                ? PetVisualState.fainted
                : c.isSick
                    ? PetVisualState.sick
                    : c.isExhausted
                        ? PetVisualState.sleeping
                        : c.pet.happiness >= 80 && c.pet.health >= 60
                            ? PetVisualState.happy
                            : PetVisualState.normal,
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
          Positioned.fill(
            child: _PetStatusOverlay(
              showSleepy: c.pet.energy <= 20 && !c.isFainted,
              showHurt: c.pet.health <= 20 && !c.isFainted,
              showHappy: c.pet.happiness >= 90 && !c.isFainted && !c.isSick,
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

// ── Pet Fainted Screen ───────────────────────────────────────────────────────

class _PetFaintedScreen extends StatelessWidget {
  final PetController controller;

  const _PetFaintedScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasCoins = controller.pet.coins >= 10;
    final s = context.watch<LocaleController>().s;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A0A), Color(0xFF2D0D0D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Grey fainted sprite
                Center(
                  child: PetSpriteWidget(
                    spriteAssets: controller.pet.spriteAssets,
                    size: 120,
                    state: PetVisualState.fainted,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  s.faintedTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  s.faintedBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),
                // Stats summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      _StatRow(s.faintedStatHealth,    controller.pet.health,   Colors.red),
                      const SizedBox(height: 8),
                      _StatRow(s.faintedStatHunger,    controller.pet.hunger,   Colors.orange, inverse: true),
                      const SizedBox(height: 8),
                      _StatRow(s.faintedStatEnergy,    controller.pet.energy,   Colors.blue),
                      const SizedBox(height: 8),
                      _StatRow(s.faintedStatHappiness, controller.pet.happiness, Colors.pink),
                    ],
                  ),
                ),
                const Spacer(),
                // Primary: paid recovery
                FilledButton.icon(
                  onPressed: hasCoins
                      ? () => controller.recoverPet(useCoins: true)
                      : null,
                  icon: const Text('💊', style: TextStyle(fontSize: 18)),
                  label: Text(
                    hasCoins ? s.faintedMedicine : s.faintedMedicineNoCoins,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                // Secondary: free recovery (heavy penalty)
                OutlinedButton.icon(
                  onPressed: () => controller.recoverPet(useCoins: false),
                  icon: const Text('🩹', style: TextStyle(fontSize: 18)),
                  label: Text(s.faintedNaturalRecovery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.faintedNaturalNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withAlpha(60), fontSize: 11),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool inverse;

  const _StatRow(this.label, this.value, this.color, {this.inverse = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                inverse
                    ? (value > 66 ? Colors.red : (value > 33 ? Colors.orange : Colors.green))
                    : (value < 33 ? Colors.red : (value < 66 ? Colors.orange : color)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

