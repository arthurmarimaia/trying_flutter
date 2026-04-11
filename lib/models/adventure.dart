import 'dart:math';

enum AdventureStatus { idle, traveling, completed }

class Adventure {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int durationMinutes;
  final int minCoinsReward;
  final int maxCoinsReward;
  final List<String> possibleItems;
  late DateTime startedAt;
  late DateTime? completedAt;
  AdventureStatus status;
  String? treasureItem;
  int? coinsReward;

  Adventure({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.durationMinutes,
    required this.minCoinsReward,
    required this.maxCoinsReward,
    required this.possibleItems,
    this.status = AdventureStatus.idle,
  }) {
    startedAt = DateTime.now();
    completedAt = null;
  }

  bool get isActive => status == AdventureStatus.traveling;
  bool get isCompleted => status == AdventureStatus.completed;

  int get timeElapsedSeconds {
    final now = DateTime.now();
    return now.difference(startedAt).inSeconds;
  }

  int get totalDurationSeconds => durationMinutes * 60;

  double get progressPercent {
    if (status == AdventureStatus.idle) return 0.0;
    if (status == AdventureStatus.completed) return 1.0;
    return (timeElapsedSeconds / totalDurationSeconds).clamp(0.0, 1.0);
  }

  bool get shouldComplete {
    return isActive && timeElapsedSeconds >= totalDurationSeconds;
  }

  void startAdventure() {
    status = AdventureStatus.traveling;
    startedAt = DateTime.now();
  }

  void completeAdventure() {
    status = AdventureStatus.completed;
    completedAt = DateTime.now();
    coinsReward = minCoinsReward +
        Random().nextInt((maxCoinsReward - minCoinsReward).clamp(1, maxCoinsReward));
    if (possibleItems.isNotEmpty) {
      treasureItem = possibleItems[(DateTime.now().millisecondsSinceEpoch) % possibleItems.length];
    }
  }

  void reset() {
    status = AdventureStatus.idle;
    startedAt = DateTime.now();
    completedAt = null;
    treasureItem = null;
    coinsReward = null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'duration': durationMinutes,
      'minCoins': minCoinsReward,
      'maxCoins': maxCoinsReward,
      'items': possibleItems,
      'status': status.index,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'treasure': treasureItem,
      'coins': coinsReward,
    };
  }

  factory Adventure.fromMap(Map<String, dynamic> map) {
    final adventure = Adventure(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      durationMinutes: map['duration'] as int,
      minCoinsReward: map['minCoins'] as int,
      maxCoinsReward: map['maxCoins'] as int,
      possibleItems: List<String>.from(map['items'] as List),
      status: AdventureStatus.values[map['status'] as int? ?? 0],
    );
    adventure.startedAt = DateTime.parse(map['startedAt'] as String);
    if (map['completedAt'] != null) {
      adventure.completedAt = DateTime.parse(map['completedAt'] as String);
    }
    adventure.treasureItem = map['treasure'] as String?;
    adventure.coinsReward = map['coins'] as int?;
    return adventure;
  }
}

class AdventureLog {
  final List<Adventure> completedAdventures = [];

  AdventureLog();

  void addCompleted(Adventure adventure) {
    completedAdventures.add(adventure);
  }

  List<Adventure> getRecentAdventures([int limit = 5]) {
    return completedAdventures.reversed.take(limit).toList();
  }

  int getTotalCoinsFromAdventures() {
    return completedAdventures.fold<int>(0, (sum, adv) => sum + (adv.coinsReward ?? 0));
  }

  Map<String, int> getItemStatistics() {
    final stats = <String, int>{};
    for (final adv in completedAdventures) {
      if (adv.treasureItem != null) {
        stats[adv.treasureItem!] = (stats[adv.treasureItem!] ?? 0) + 1;
      }
    }
    return stats;
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAdventures': completedAdventures.map((a) => a.toMap()).toList(),
    };
  }

  factory AdventureLog.fromMap(Map<String, dynamic> map) {
    final log = AdventureLog();
    final adventures = (map['completedAdventures'] as List?)?.cast<Map<String, dynamic>>();
    if (adventures != null) {
      for (final advMap in adventures) {
        log.addCompleted(Adventure.fromMap(advMap));
      }
    }
    return log;
  }
}

// Aventuras pré-definidas
final List<Adventure> predefinedAdventures = [
  Adventure(
    id: 'forest',
    name: 'Floresta Misteriosa',
    description: 'Explore a floresta em busca de tesouro',
    emoji: '🌲',
    durationMinutes: 5,
    minCoinsReward: 12,
    maxCoinsReward: 25,
    possibleItems: ['🍎', '💎', '🪙', '🔑'],
  ),
  Adventure(
    id: 'cave',
    name: 'Caverna Escura',
    description: 'Desvende os mistérios da caverna',
    emoji: '⛰️',
    durationMinutes: 8,
    minCoinsReward: 20,
    maxCoinsReward: 45,
    possibleItems: ['💎', '🔱', '📜', '👑'],
  ),
  Adventure(
    id: 'ocean',
    name: 'Aventura no Oceano',
    description: 'Mergulhe nas profundezas do oceano',
    emoji: '🌊',
    durationMinutes: 10,
    minCoinsReward: 25,
    maxCoinsReward: 55,
    possibleItems: ['🐚', '🪶', '⚓', '🧿'],
  ),
  Adventure(
    id: 'mountain',
    name: 'Pico da Montanha',
    description: 'Escale a maior montanha do reino',
    emoji: '⛺',
    durationMinutes: 7,
    minCoinsReward: 18,
    maxCoinsReward: 38,
    possibleItems: ['❄️', '📿', '🏔️', '🪨'],
  ),
  Adventure(
    id: 'castle',
    name: 'Castelo Encantado',
    description: 'Descubra os segredos do castelo',
    emoji: '🏰',
    durationMinutes: 12,
    minCoinsReward: 35,
    maxCoinsReward: 70,
    possibleItems: ['👑', '📖', '🔮', '⚔️'],
  ),
];
