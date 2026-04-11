import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

class TitlesScreen extends StatelessWidget {
  const TitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final allTitles = _buildTitleList(controller);
    final s = context.watch<LocaleController>().s;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.titlesScreenTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _ActiveTitleBanner(
            activeTitle: controller.activeTitle,
            unlocked: controller.unlockedTitles.length,
            total: allTitles.length,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: allTitles.length,
              itemBuilder: (ctx, i) {
                final entry = allTitles[i];
                final isUnlocked = controller.unlockedTitles.contains(entry.title);
                final isActive = controller.activeTitle == entry.title;
                return _TitleCard(
                  entry: entry,
                  isUnlocked: isUnlocked,
                  isActive: isActive,
                  onActivate: isUnlocked
                      ? () => controller.changeActiveTitle(entry.title)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_TitleEntry> _buildTitleList(PetController controller) {
    // Titles sourced from achievements — build list from achievements with titleReward
    final fromAchievements = controller.playerAchievements
        .where((a) => a.titleReward != null && a.titleReward!.isNotEmpty)
        .map((a) => _TitleEntry(
              title: a.titleReward!,
              source: a.title,
              description: a.description,
              emoji: a.emoji,
              achievementId: a.id,
            ))
        .toList();

    // Also include any titles already unlocked that aren't from listed achievements
    final fromAchievementTitles =
        fromAchievements.map((e) => e.title).toSet();
    final extra = controller.unlockedTitles
        .where((t) => !fromAchievementTitles.contains(t))
        .map((t) => _TitleEntry(
              title: t,
              source: 'unlocked',
              description: 'special',
              emoji: '🏅',
            ))
        .toList();

    return [...fromAchievements, ...extra];
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _TitleEntry {
  final String title;
  final String source;
  final String description;
  final String emoji;
  final String? achievementId;

  const _TitleEntry({
    required this.title,
    required this.source,
    required this.description,
    required this.emoji,
    this.achievementId,
  });
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ActiveTitleBanner extends StatelessWidget {
  final String activeTitle;
  final int unlocked;
  final int total;

  const _ActiveTitleBanner({
    required this.activeTitle,
    required this.unlocked,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade700,
            Colors.indigo.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.titlesActiveLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  activeTitle.isEmpty ? s.titlesNoneEquipped : activeTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$unlocked/$total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                s.titlesUnlockedLabel,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  final _TitleEntry entry;
  final bool isUnlocked;
  final bool isActive;
  final VoidCallback? onActivate;

  const _TitleCard({
    required this.entry,
    required this.isUnlocked,
    required this.isActive,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: isActive ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isActive
              ? BorderSide(color: Colors.indigo.shade400, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Emoji + lock
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isUnlocked
                        ? Colors.indigo.shade50
                        : Colors.grey.shade200,
                    child: Text(
                      isUnlocked ? entry.emoji : '🔒',
                      style: TextStyle(
                          fontSize: 22,
                          color: isUnlocked ? null : Colors.grey),
                    ),
                  ),
                  if (isActive)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.check,
                            size: 8, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked ? entry.title : '???',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? (isActive
                                    ? Colors.indigo.shade700
                                    : null)
                                : Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUnlocked
                          ? '${s.titlesEarnedVia} ${entry.source == 'unlocked' ? s.titlesUnlockedSrc : entry.source}'
                          : (entry.description == 'special' ? s.titlesSpecialDesc : entry.description),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action
              if (isUnlocked)
                isActive
                    ? Chip(
                        label: Text(s.titlesActiveChip),
                        backgroundColor: Colors.indigo.shade600,
                        labelStyle: const TextStyle(
                            color: Colors.white, fontSize: 12),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      )
                    : TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            minimumSize: const Size(60, 30)),
                        onPressed: onActivate,
                        child: Text(s.titlesUseBtn),
                      )
              else
                const Icon(Icons.lock_outline,
                    color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
