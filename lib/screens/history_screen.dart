import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../services/locale_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PetController>();
    final history = controller.pet.healthHistory;
    final s = context.watch<LocaleController>().s;
    final isPt = context.watch<LocaleController>().isPt;

    return Scaffold(
      appBar: AppBar(title: Text(s.historyTitle)),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    s.historyNoDataYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPt ? 'Últimos ${history.length} dia(s)' : 'Last ${history.length} day(s)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _HealthChart(history: history),
                  const SizedBox(height: 24),
                  Text(s.historyDetails, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Expanded(child: _HistoryList(history: history)),
                ],
              ),
            ),
    );
  }
}

class _HealthChart extends StatelessWidget {
  const _HealthChart({required this.history});
  final List<Map<String, int>> history;

  @override
  Widget build(BuildContext context) {
    final isPt = context.watch<LocaleController>().isPt;
    final labels = isPt
        ? ['❤️ Saúde', '🍖 Fome', '😊 Felicidade', '⚡ Energia']
        : ['❤️ Health', '🍖 Hunger', '😊 Happiness', '⚡ Energy'];
    final keys = ['health', 'hunger', 'happiness', 'energy'];
    final colors = [Colors.red, Colors.orange, Colors.yellow.shade700, Colors.amber];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(labels[i],
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 28,
                    child: _SparklineChart(
                      values: history.map((s) => s[keys[i]] ?? 0).toList(),
                      color: colors[i],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SparklineChart extends StatelessWidget {
  const _SparklineChart({required this.values, required this.color});
  final List<int> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});
  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final n = values.length;
    final xStep = n > 1 ? size.width / (n - 1) : size.width;

    List<Offset> points = [];
    for (int i = 0; i < n; i++) {
      final x = n > 1 ? i * xStep : size.width / 2;
      final y = size.height - (values[i] / 100.0) * size.height;
      points.add(Offset(x, y));
    }

    // Fill area under line
    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, bgPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});
  final List<Map<String, int>> history;

  String _dayLabel(int index, int totalDays, AppStrings s) {
    final daysAgo = totalDays - 1 - index;
    if (daysAgo == 0) return s.historyToday;
    if (daysAgo == 1) return s.historyYesterday;
    return '$daysAgo ${s.historyDaysAgo}';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, idx) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final snap = history[index];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: _overallColor(snap),
            child: Text(
              '${_overallScore(snap)}',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
          title: Text(_dayLabel(index, history.length, s),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '❤️${snap['health']}  🍖${100 - (snap['hunger'] ?? 0)}  😊${snap['happiness']}  ⚡${snap['energy']}',
            style: const TextStyle(fontSize: 11),
          ),
        );
      },
    );
  }

  int _overallScore(Map<String, int> snap) {
    final h = snap['health'] ?? 0;
    final s = 100 - (snap['hunger'] ?? 0);
    final hap = snap['happiness'] ?? 0;
    final e = snap['energy'] ?? 0;
    return ((h + s + hap + e) / 4).round();
  }

  Color _overallColor(Map<String, int> snap) {
    final score = _overallScore(snap);
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
