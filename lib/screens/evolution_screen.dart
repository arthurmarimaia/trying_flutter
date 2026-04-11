import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_evolution.dart';
import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

class EvolutionScreen extends StatelessWidget {
  final PetForm currentForm;
  final int petLevel;
  final Map<String, int> petStats;
  final String? selectedAccessory;
  final Function(PetForm) onEvolutionSelect;

  const EvolutionScreen({
    super.key,
    required this.currentForm,
    required this.petLevel,
    required this.petStats,
    required this.selectedAccessory,
    required this.onEvolutionSelect,
  });

  List<PetForm> _getAvailableForms() {
    return PetForm.values;
  }

  bool _canEvolveToForm(PetForm form) {
    final evolution = PetEvolution.fromForm(form);
    return evolution.canEvolve(
      petLevel,
      petStats,
      selectedAccessory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableForms = _getAvailableForms();
    final controller = context.watch<PetController>();
    final s = context.watch<LocaleController>().s;

    return Scaffold(
      appBar: AppBar(
        title: Text('${s.evolutionTitle} 🔄'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [Colors.black87, Colors.deepPurple.shade900]
                : [Colors.purple.shade100, Colors.blue.shade200],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Form Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withAlpha(200),
                      theme.colorScheme.secondary.withAlpha(150),
                    ],
                  ),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      s.evoCurrentForm,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      PetEvolution.fromForm(currentForm).displayEmoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                    Text(
                      s.evoFormName(currentForm),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(28),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upgrade, color: Colors.white70),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.evolutionHint(controller.evolutionHint),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats Display
              Text(
                s.evoYourStats,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withAlpha(80),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatRow('📍 ${s.evoStatLevel}', '$petLevel'),
                    const SizedBox(height: 8),
                    _StatRow('❤️ ${s.evoStatHealth}', '${petStats['health'] ?? 0}'),
                    const SizedBox(height: 8),
                    _StatRow('😊 ${s.evoStatHappiness}', '${petStats['happiness'] ?? 0}'),
                    const SizedBox(height: 8),
                    _StatRow('⚡ ${s.evoStatEnergy}', '${petStats['energy'] ?? 0}'),
                    const SizedBox(height: 8),
                    _StatRow('🍖 ${s.evoStatHunger}', '${petStats['hunger'] ?? 0}'),
                    const SizedBox(height: 8),
                    _StatRow('💪 ${s.evoStatStrength}', '${petStats['strength'] ?? 0}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Available Evolutions
              Text(
                s.evoAvailableForms,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...availableForms.map((form) {
                final evolution = PetEvolution.fromForm(form);
                final canEvolve = _canEvolveToForm(form);
                final isCurrentForm = form == currentForm;

                return _EvolutionCard(
                  evolution: evolution,
                  canEvolve: canEvolve,
                  isCurrentForm: isCurrentForm,
                  petStats: petStats,
                  petLevel: petLevel,
                  selectedAccessory: selectedAccessory,
                  onTap: canEvolve && !isCurrentForm
                      ? () async {
                          onEvolutionSelect(form);
                          if (!context.mounted) return;
                          await showGeneralDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black87,
                            transitionDuration: Duration.zero,
                            pageBuilder: (ctx, animation, secondaryAnimation) => _EvolutionCelebration(
                              emoji: evolution.displayEmoji,
                              name: s.evoFormName(evolution.currentForm),
                            ),
                          );
                          if (!context.mounted) return;
                          final sSnap = context.read<LocaleController>().s;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${sSnap.evoEvolvedTo} ${sSnap.evoFormName(evolution.currentForm)}!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      : null,
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final PetEvolution evolution;
  final bool canEvolve;
  final bool isCurrentForm;
  final Map<String, int> petStats;
  final int petLevel;
  final String? selectedAccessory;
  final VoidCallback? onTap;

  const _EvolutionCard({
    required this.evolution,
    required this.canEvolve,
    required this.isCurrentForm,
    required this.petStats,
    required this.petLevel,
    required this.selectedAccessory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = context.watch<LocaleController>().s;
    final bgColor = isCurrentForm
        ? Colors.amber.withAlpha(150)
        : canEvolve
            ? Colors.green.withAlpha(120)
            : Colors.grey.withAlpha(100);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor,
          border: Border.all(
            color: isCurrentForm
                ? Colors.amber
                : canEvolve
                    ? Colors.green
                    : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(evolution.displayEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.evoFormName(evolution.currentForm),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (!canEvolve) ...[
                    Text(
                      s.evoRequirementsNotMet,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                    ..._getMissingRequirements(s).map(
                      (req) => Text(
                        '❌ $req',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ),
                  ] else if (isCurrentForm)
                    Text(
                      s.evoCurrentFormCheck,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
                    )
                  else
                    Text(
                      s.evoReadyToEvolve,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
                    ),
                ],
              ),
            ),
            if (canEvolve && !isCurrentForm)
              Icon(Icons.arrow_forward_ios, color: Colors.green, size: 20)
            else if (isCurrentForm)
              const Icon(Icons.check_circle, color: Colors.amber, size: 28),
          ],
        ),
      ),
    );
  }

  List<String> _getMissingRequirements(AppStrings s) {
    final statLabels = {
      'health': s.evoStatHealth,
      'happiness': s.evoStatHappiness,
      'energy': s.evoStatEnergy,
      'hunger': s.evoStatHunger,
      'experience': s.evoStatExperience,
      'strength': s.evoStatStrength,
      'gamesPlayed': s.evoStatGamesPlayed,
      'totalAdventures': s.evoStatAdventures,
      'coins': s.evoStatCoins,
      'loginStreak': s.evoStatLoginStreak,
    };

    final missing = <String>[];

    if (petLevel < evolution.levelRequired) {
      missing.add('${s.evoStatLevel} ${evolution.levelRequired} (${s.evoCurrentLabel}: $petLevel)');
    }

    for (final entry in evolution.statRequirements.entries) {
      final currentVal = petStats[entry.key] ?? 0;
      if (currentVal < entry.value) {
        final label = statLabels[entry.key] ?? entry.key;
        missing.add('$label: $currentVal/${entry.value}');
      }
    }

    for (final entry in evolution.maxStatRequirements.entries) {
      final currentVal = petStats[entry.key] ?? 0;
      if (currentVal > entry.value) {
        final label = statLabels[entry.key] ?? entry.key;
        missing.add('$label ≤ ${entry.value} (${s.evoCurrentLabel}: $currentVal)');
      }
    }

    for (final entry in evolution.fixedStatRequirements.entries) {
      final currentVal = petStats[entry.key] ?? 0;
      if (currentVal < entry.value) {
        final label = statLabels[entry.key] ?? entry.key;
        missing.add('$label: $currentVal/${entry.value}');
      }
    }

    if (evolution.requiredAccessoryId != null &&
        selectedAccessory != evolution.requiredAccessoryId) {
      missing.add('${s.evoRequiredAccessory}: ${evolution.requiredAccessoryId}');
    }

    return missing;
  }
}

// ── Evolution Celebration Overlay ───────────────────────────────────────────

class _EvolutionCelebration extends StatefulWidget {
  final String emoji;
  final String name;
  const _EvolutionCelebration({required this.emoji, required this.name});

  @override
  State<_EvolutionCelebration> createState() => _EvolutionCelebrationState();
}

class _EvolutionCelebrationState extends State<_EvolutionCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.3, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
    ]).animate(_ctrl);
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _ctrl.forward().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
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
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: child,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 100)),
          const SizedBox(height: 16),
          Text(
            '✨ ${widget.name} ✨',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Builder(builder: (ctx) {
            final st = ctx.watch<LocaleController>().s;
            return Text(
              st.evoCelebrationText,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            );
          }),
        ],
      ),
    );
  }
}
