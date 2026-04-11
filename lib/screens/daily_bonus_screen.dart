import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

class DailyBonusScreen extends StatefulWidget {
  const DailyBonusScreen({super.key});

  @override
  State<DailyBonusScreen> createState() => _DailyBonusScreenState();
}

class _DailyBonusScreenState extends State<DailyBonusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _claiming = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _claim(PetController controller) async {
    if (_claiming) return;
    setState(() => _claiming = true);
    await controller.claimDailyBonus();
    // DailyBonusScreen is returned inline by HomeScreen.build(), not pushed as
    // a route. claimDailyBonus() calls notifyListeners() which causes HomeScreen
    // to rebuild and stop showing this widget — no Navigator.pop() needed.
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final streak  = controller.loginStreak;
    final reward  = controller.getDailyBonusReward(streak);
    final theme   = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final isPt    = context.watch<LocaleController>().isPt;

    final fireColor = streak >= 7 ? Colors.deepOrange : Colors.orange;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLight
                ? [Colors.orange.shade50, Colors.white]
                : [Colors.orange.shade900.withValues(alpha: 0.3), theme.colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Fire / streak icon
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 96, color: fireColor),
                      const SizedBox(height: 8),
                      Text(
                        isPt ? 'Dia $streak' : 'Day $streak',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: fireColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        streak == 1
                            ? (isPt ? 'Primeiro login do dia!' : 'First login of the day!')
                            : (isPt ? '$streak dias consecutivos!' : '$streak days in a row!'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Reward card
              FadeTransition(
                opacity: _fade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            reward.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _RewardRow(icon: '🪙', label: '+${reward.coins} ${isPt ? 'moedas' : 'coins'}'),
                          const SizedBox(height: 8),
                          _RewardRow(icon: '✨', label: '+${reward.xp} XP'),
                          const SizedBox(height: 8),
                          _RewardRow(icon: '❤️', label: '+${reward.bond} ${isPt ? 'vínculo' : 'bond'}'),
                          if (reward.itemId != null) ...[
                            const SizedBox(height: 8),
                            _RewardRow(icon: '🎁', label: '1x ${reward.itemId}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Streak mini-calendar (last 7 days dots)
              _StreakDots(streak: streak),
              const Spacer(flex: 2),
              // Claim button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _claiming ? null : () => _claim(controller),
                    style: FilledButton.styleFrom(
                      backgroundColor: fireColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _claiming
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isPt ? 'Coletar! 🎉' : 'Collect! 🎉',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String icon;
  final String label;
  const _RewardRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _StreakDots extends StatelessWidget {
  final int streak;
  const _StreakDots({required this.streak});

  @override
  Widget build(BuildContext context) {
    final int show = 7;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(show, (i) {
        final active = i < streak.clamp(0, show);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? Colors.orange
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
