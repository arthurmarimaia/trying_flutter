import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../models/pet.dart';
import '../widgets/pet_sprite_widget.dart';
import '../screens/history_screen.dart';
import '../screens/titles_screen.dart';
import '../services/locale_controller.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final pet = controller.pet;
    final theme = Theme.of(context);
    final s = context.watch<LocaleController>().s;
    final isPt = context.watch<LocaleController>().isPt;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name.isEmpty ? s.profileTitle : pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: s.profileRenameTooltip,
            onPressed: () => _showRenameDialog(context, controller),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Sprite + Name card ──────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  PetSpriteWidget(
                    spriteAssets: pet.spriteAssets,
                    size: 120,
                    state: controller.isSick
                        ? PetVisualState.sick
                        : controller.isExhausted
                            ? PetVisualState.sleeping
                            : pet.happiness >= 80
                                ? PetVisualState.happy
                                : PetVisualState.normal,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pet.name.isEmpty ? s.profileNoName : pet.name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _TypeBadge(petType: pet.petType),
                  if (controller.activeTitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: controller.unlockedTitles.length > 1
                          ? () => _showTitlePicker(context, controller)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade400,
                              Colors.purple.shade400
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.title,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              controller.activeTitle,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                            if (controller.unlockedTitles.length > 1) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down,
                                  size: 16, color: Colors.white70),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Quick stats ─────────────────────────────────────────────────
          _SectionTitle(title: s.profileStatsSection, icon: Icons.bar_chart),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _InfoRow(
                      label: s.profileLevel,
                      value: '${pet.level}  •  ${s.petStage(pet.stage)}'),
                  _InfoRow(
                    label: s.profileDaysAlive,
                    value: controller.daysAlive > 0
                        ? (isPt ? '${controller.daysAlive} dias' : '${controller.daysAlive} days')
                        : '—',
                  ),
                  _InfoRow(
                      label: s.profileStreak,
                      value: '${controller.loginStreak} ${isPt ? 'dias 🔥' : 'days 🔥'}'),
                  _InfoRow(
                      label: s.profileBond,
                      value: '${pet.bond}/100  •  ${s.petBondLabel(pet.bond)}'),
                  const SizedBox(height: 8),
                  _BondBar(bond: pet.bond),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Status bars ─────────────────────────────────────────────────
          _SectionTitle(title: s.profileStatusSection, icon: Icons.favorite),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _StatBar(
                      label: s.profileStatHealth,
                      value: pet.health,
                      color: Colors.red),
                  const SizedBox(height: 8),
                  _StatBar(
                      label: s.profileStatSatiety,
                      value: 100 - pet.hunger,
                      color: Colors.orange),
                  const SizedBox(height: 8),
                  _StatBar(
                      label: s.profileStatHappiness,
                      value: pet.happiness,
                      color: Colors.yellow.shade700),
                  const SizedBox(height: 8),
                  _StatBar(
                      label: s.profileStatEnergy,
                      value: pet.energy,
                      color: Colors.amber),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Acessório equipado ─────────────────────────────────────────
          _SectionTitle(title: s.profileAccessorySection, icon: Icons.checkroom),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Text(
                controller.equippedAccessoryItem?.icon ?? '—',
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                controller.equippedAccessoryItem?.name ?? s.profileNoAccessory,
              ),
              subtitle: controller.equippedAccessoryItem != null
                  ? Text(controller.equippedAccessoryItem!.description)
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          // ── Histórico rápido ───────────────────────────────────────────
          if (pet.healthHistory.isNotEmpty) ...[
            _SectionTitle(
                title: s.profileHealthHistory, icon: Icons.show_chart),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HealthChart(history: pet.healthHistory),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: Text(s.profileViewFull),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Títulos desbloqueados ──────────────────────────────────────
          if (controller.unlockedTitles.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: _SectionTitle(
                      title: '${s.profileTitles} (${controller.unlockedTitles.length})',
                      icon: Icons.military_tech),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TitlesScreen()),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: Text(s.profileSeeAll),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.unlockedTitles.map((t) {
                    final active = t == controller.activeTitle;
                    return GestureDetector(
                      onTap: () => controller.changeActiveTitle(t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.indigo.shade600
                              : Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? Colors.indigo.shade600
                                : Colors.indigo.shade200,
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : Colors.indigo.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, PetController controller) async {
    final s = context.read<LocaleController>().s;
    final ctrl = TextEditingController(text: controller.pet.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.profileRenameTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
              hintText: s.profileNameHint, border: const OutlineInputBorder()),
          autofocus: true,
          maxLength: 20,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(s.save)),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      controller.renamePet(result);
    }
  }

  void _showTitlePicker(BuildContext context, PetController controller) {
    final s = context.read<LocaleController>().s;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(s.profileChooseTitle,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...controller.unlockedTitles.map((t) {
              final active = t == controller.activeTitle;
              return ListTile(
                leading: Icon(
                  active ? Icons.check_circle : Icons.circle_outlined,
                  color: active ? Colors.indigo : Colors.grey,
                ),
                title: Text(t,
                    style: TextStyle(
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal)),
                onTap: () {
                  controller.changeActiveTitle(t);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.petType});
  final PetType petType;

  @override
  Widget build(BuildContext context) {
    const labels = {
      PetType.canino: '🐕 Canino',
      PetType.reptil: '🦎 Réptil',
      PetType.slime: '🟢 Slime',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[petType] ?? petType.name,
        style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BondBar extends StatelessWidget {
  const _BondBar({required this.bond});
  final int bond;

  @override
  Widget build(BuildContext context) {
    final milestones = [0, 20, 40, 60, 80, 100];
    final s = context.watch<LocaleController>().s;
    final labels = [
      s.profileBondStranger,
      s.profileBondAcquaintance,
      s.profileBondFriend,
      s.profileBondClose,
      s.profileBondSoulmate,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: bond / 100.0,
            minHeight: 10,
            backgroundColor: Colors.pink.shade100,
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: milestones
              .take(5)
              .map((m) => Text(
                    labels[milestones.indexOf(m)],
                    style: TextStyle(
                      fontSize: 8,
                      color: bond >= m
                          ? Colors.pink.shade600
                          : Colors.grey.shade400,
                      fontWeight:
                          bond >= m ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  Color get _barColor {
    if (value <= 20) return Colors.red.shade600;
    if (value <= 40) return Colors.orange;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 10,
              backgroundColor: _barColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.end,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _barColor),
          ),
        ),
      ],
    );
  }
}

class _HealthChart extends StatelessWidget {
  const _HealthChart({required this.history});
  final List<Map<String, int>> history;

  @override
  Widget build(BuildContext context) {
    final keys = ['health', 'happiness', 'energy'];
    final colors = [Colors.red, Colors.yellow.shade700, Colors.amber];

    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(history.length, (i) {
          final snap = history[i];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: keys.asMap().entries.map((e) {
                  final v = (snap[e.value] ?? 0) / 100.0;
                  return Expanded(
                    child: FractionallySizedBox(
                      heightFactor: v.clamp(0.05, 1.0),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        decoration: BoxDecoration(
                          color: colors[e.key].withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ),
    );
  }
}
