import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../models/achievement.dart';
import '../services/locale_controller.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PetController>(context);
    final achievements = controller.playerAchievements;
    final unlocked = achievements.where((a) => a.unlocked).length;
    final s = context.watch<LocaleController>().s;

    return Scaffold(
      appBar: AppBar(
        title: Text('🏅 ${s.achievementsTitle}'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _SummaryHeader(total: achievements.length, unlocked: unlocked),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: achievements.length,
              itemBuilder: (context, i) =>
                  _AchievementCard(achievement: achievements[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int total;
  final int unlocked;

  const _SummaryHeader({required this.total, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? unlocked / total : 0.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$unlocked / $total ${context.watch<LocaleController>().s.achievementsTitle.toLowerCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(percent * 100).toStringAsFixed(0)}% ${context.watch<LocaleController>().s.achievementsComplete}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final isNew = a.justUnlocked;
    final s = context.watch<LocaleController>().s;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: a.unlocked
          ? (isNew ? Colors.amber.shade100 : Colors.green.shade50)
          : Colors.grey.shade100,
      elevation: a.unlocked ? 2 : 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: a.unlocked ? Colors.amber.shade300 : Colors.grey.shade300,
              ),
              child: Center(
                child: Text(
                  a.unlocked ? a.emoji : '🔒',
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.achievementTitleById(a.id),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: a.unlocked
                                ? Colors.green.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NOVO!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.achievementDescriptionById(a.id),
                    style: TextStyle(
                        fontSize: 12,
                        color: a.unlocked
                            ? Colors.green.shade700
                            : Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: a.progressPercent,
                      minHeight: 8,
                      backgroundColor:
                          a.unlocked ? Colors.green.shade200 : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        a.unlocked ? Colors.green.shade600 : Colors.blue.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${a.currentProgress.clamp(0, a.goal)} / ${a.goal}',
                        style: TextStyle(
                            fontSize: 11,
                            color: a.unlocked
                                ? Colors.green.shade600
                                : Colors.grey.shade500),
                      ),
                      Text(
                        '+${a.coinsReward} 💰  +${a.xpReward} ⭐',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: a.unlocked
                                ? Colors.amber.shade700
                                : Colors.grey.shade400),
                      ),
                    ],
                  ),
                  // Item / title rewards preview
                  if (a.itemReward != null || a.titleReward != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        children: [
                          if (a.itemReward != null)
                            _RewardChip(
                              label: a.itemReward!,
                              icon: Icons.checkroom,
                              unlocked: a.unlocked,
                              color: Colors.purple,
                            ),
                          if (a.titleReward != null)
                            _RewardChip(
                              label: '"${a.titleReward!}"',
                              icon: Icons.title,
                              unlocked: a.unlocked,
                              color: Colors.indigo,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.label,
    required this.icon,
    required this.unlocked,
    required this.color,
  });
  final String label;
  final IconData icon;
  final bool unlocked;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = unlocked ? color : Colors.grey.shade400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: c),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: c, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
