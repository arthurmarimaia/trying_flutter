enum QuestType {
  playMinigames,      // Play N minigames
  completeAdventure,  // Complete N adventures
  maintainHappiness,  // Keep happiness above N for duration
  earnCoins,          // Earn N coins
  reachLevel,         // Reach level N
  playSpecificGame,   // Play specific minigame type
}

enum QuestStatus { active, completed, claimed, expired }

class DailyQuest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final String emoji;
  final int goalProgress;
  int currentProgress = 0;
  QuestStatus status = QuestStatus.active;
  final int coinsReward;
  final int xpReward;
  late DateTime createdAt;
  late DateTime expiresAt;

  DailyQuest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.goalProgress,
    required this.coinsReward,
    required this.xpReward,
  }) {
    createdAt = DateTime.now();
    expiresAt = DateTime.now().add(const Duration(days: 1));
  }

  bool get isCompleted => currentProgress >= goalProgress;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  double get progressPercent => (currentProgress / goalProgress).clamp(0.0, 1.0);

  void updateProgress(int amount) {
    if (status != QuestStatus.active) return;
    currentProgress += amount;
    if (isCompleted) {
      status = QuestStatus.completed;
    }
  }

  void resetProgress() {
    currentProgress = 0;
    status = QuestStatus.active;
    createdAt = DateTime.now();
    expiresAt = DateTime.now().add(const Duration(days: 1));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'description': description,
      'emoji': emoji,
      'goal': goalProgress,
      'current': currentProgress,
      'status': status.index,
      'coins': coinsReward,
      'xp': xpReward,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory DailyQuest.fromMap(Map<String, dynamic> map) {
    final quest = DailyQuest(
      id: map['id'] as String,
      type: QuestType.values[map['type'] as int],
      title: map['title'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      goalProgress: map['goal'] as int,
      coinsReward: map['coins'] as int,
      xpReward: map['xp'] as int,
    );
    quest.currentProgress = map['current'] as int;
    quest.status = QuestStatus.values[map['status'] as int];
    quest.createdAt = DateTime.parse(map['createdAt'] as String);
    quest.expiresAt = DateTime.parse(map['expiresAt'] as String);
    return quest;
  }

  static List<DailyQuest> generateDailyQuests() {
    return [
      DailyQuest(
        id: 'quest_minigames',
        type: QuestType.playMinigames,
        title: 'Jogador Dedicado',
        description: 'Jogue 5 minigames',
        emoji: '🎮',
        goalProgress: 5,
        coinsReward: 100,
        xpReward: 50,
      ),
      DailyQuest(
        id: 'quest_adventure',
        type: QuestType.completeAdventure,
        title: 'Aventureiro',
        description: 'Complete 1 aventura',
        emoji: '🌍',
        goalProgress: 1,
        coinsReward: 150,
        xpReward: 75,
      ),
      DailyQuest(
        id: 'quest_happiness',
        type: QuestType.maintainHappiness,
        title: 'Pet Feliz',
        description: 'Mantenha felicidade acima de 70',
        emoji: '😊',
        goalProgress: 1,
        coinsReward: 80,
        xpReward: 40,
      ),
      DailyQuest(
        id: 'quest_coins',
        type: QuestType.earnCoins,
        title: 'Aipim Financeiro',
        description: 'Ganhe 500 moedas',
        emoji: '💰',
        goalProgress: 500,
        coinsReward: 50,
        xpReward: 25,
      ),
    ];
  }
}
