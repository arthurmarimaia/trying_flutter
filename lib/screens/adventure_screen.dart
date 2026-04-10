import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/adventure.dart';
import '../controllers/pet_controller.dart';

class AdventureScreen extends StatefulWidget {
  final Adventure? currentAdventure;
  final Function(Adventure) onAdventureStart;
  final Function() onAdventureComplete;
  final AdventureLog adventureLog;

  const AdventureScreen({
    super.key,
    required this.currentAdventure,
    required this.onAdventureStart,
    required this.onAdventureComplete,
    required this.adventureLog,
  });

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  Timer? progressTimer;

  @override
  void initState() {
    super.initState();
    if (widget.currentAdventure?.isActive ?? false) {
      progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (widget.currentAdventure?.shouldComplete ?? false) {
          widget.onAdventureComplete();
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    super.dispose();
  }

  void _startAdventure(Adventure adventure) {
    adventure.startAdventure();
    widget.onAdventureStart(adventure);
    setState(() {
      progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (adventure.shouldComplete) {
          widget.onAdventureComplete();
        }
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveAdventure = widget.currentAdventure?.isActive ?? false;
    final controller = context.watch<PetController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aventuras 🌍'),
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
              if (hasActiveAdventure)
                _ActiveAdventureCard(
                  adventure: widget.currentAdventure!,
                )
              else ...[
                Text(
                  'Escolha uma Aventura',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      const Icon(Icons.explore, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.adventureHint,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ...predefinedAdventures
                  .map((adv) => _AdventureSelector(
                        adventure: adv,
                        isActive: hasActiveAdventure && widget.currentAdventure?.id == adv.id,
                        onTap: hasActiveAdventure ? null : () => _startAdventure(adv),
                      ))
                  ,
              const SizedBox(height: 24),
              if (widget.adventureLog.completedAdventures.isNotEmpty) ...[
                Text(
                  'Histórico de Aventuras',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._buildAdventureHistory(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAdventureHistory() {
    final recent = widget.adventureLog.getRecentAdventures(5);
    return recent
        .map((adv) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${adv.emoji} ${adv.name}'),
                      if (adv.treasureItem != null)
                        Text(
                          'Tesouro: ${adv.treasureItem}',
                          style: const TextStyle(fontSize: 12, color: Colors.amber),
                        ),
                    ],
                  ),
                  Text(
                    '+${adv.coinsReward} 💰',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _ActiveAdventureCard extends StatelessWidget {
  final Adventure adventure;

  const _ActiveAdventureCard({required this.adventure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = adventure.progressPercent;
    final timeRemaining = adventure.totalDurationSeconds - adventure.timeElapsedSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withAlpha(220),
            theme.colorScheme.secondary.withAlpha(180),
          ],
        ),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Aventura em andamento!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 120,
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withAlpha(100),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(Colors.green, Colors.red, 1 - progress) ?? Colors.amber,
                      ),
                    ),
                    Text(
                      adventure.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            adventure.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tempo restante: ${(timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('Possíveis Prêmios:', style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  '💰 ${adventure.minCoinsReward} - ${adventure.maxCoinsReward} moedas',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                if (adventure.possibleItems.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Itens: ${adventure.possibleItems.join(' ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdventureSelector extends StatelessWidget {
  final Adventure adventure;
  final bool isActive;
  final VoidCallback? onTap;

  const _AdventureSelector({
    required this.adventure,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Colors.orange.withAlpha(200), Colors.amber.withAlpha(150)]
                : [
                    theme.colorScheme.primary.withAlpha(160),
                    theme.colorScheme.secondary.withAlpha(100),
                  ],
          ),
          border: Border.all(
            color: isActive ? Colors.orange : Colors.white24,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(adventure.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adventure.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    adventure.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '⏱️ ${adventure.durationMinutes} min',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '💰 ${adventure.minCoinsReward}-${adventure.maxCoinsReward}',
                        style: const TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isActive)
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20)
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
