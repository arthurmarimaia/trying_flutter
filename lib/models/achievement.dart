enum AchievementType {
  gamesPlayed,
  adventuresCompleted,
  coinsEarned,
  petLevel,
  evolutionsUnlocked,
  daysStreak,
  questsClaimed,
  happinessMaintained,
}

class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String emoji;
  final int goal;
  int currentProgress;
  bool unlocked;
  DateTime? unlockedAt;
  final int coinsReward;
  final int xpReward;

  Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.goal,
    this.currentProgress = 0,
    this.unlocked = false,
    this.unlockedAt,
    this.coinsReward = 0,
    this.xpReward = 0,
  });

  double get progressPercent => (currentProgress / goal).clamp(0.0, 1.0);
  bool get justUnlocked => unlocked && unlockedAt != null &&
      DateTime.now().difference(unlockedAt!).inSeconds < 10;

  /// Returns true if the achievement was newly unlocked.
  bool updateProgress(int value) {
    if (unlocked) return false;
    currentProgress = value;
    if (currentProgress >= goal) {
      unlocked = true;
      unlockedAt = DateTime.now();
      return true;
    }
    return false;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.index,
        'title': title,
        'description': description,
        'emoji': emoji,
        'goal': goal,
        'current': currentProgress,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'coinsReward': coinsReward,
        'xpReward': xpReward,
      };

  factory Achievement.fromMap(Map<String, dynamic> map) {
    final a = Achievement(
      id: map['id'] as String,
      type: AchievementType.values[map['type'] as int],
      title: map['title'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      goal: map['goal'] as int,
      currentProgress: map['current'] as int? ?? 0,
      unlocked: map['unlocked'] as bool? ?? false,
      coinsReward: map['coinsReward'] as int? ?? 0,
      xpReward: map['xpReward'] as int? ?? 0,
    );
    if (map['unlockedAt'] != null) {
      a.unlockedAt = DateTime.parse(map['unlockedAt'] as String);
    }
    return a;
  }

  static List<Achievement> defaultAchievements() => [
        // Games Played
        Achievement(
          id: 'games_10',
          type: AchievementType.gamesPlayed,
          title: 'Iniciante',
          description: 'Jogue 10 minigames',
          emoji: '🎮',
          goal: 10,
          coinsReward: 50,
          xpReward: 30,
        ),
        Achievement(
          id: 'games_50',
          type: AchievementType.gamesPlayed,
          title: 'Jogador',
          description: 'Jogue 50 minigames',
          emoji: '🕹️',
          goal: 50,
          coinsReward: 150,
          xpReward: 75,
        ),
        Achievement(
          id: 'games_100',
          type: AchievementType.gamesPlayed,
          title: 'Viciado',
          description: 'Jogue 100 minigames',
          emoji: '🏅',
          goal: 100,
          coinsReward: 300,
          xpReward: 150,
        ),
        // Adventures
        Achievement(
          id: 'adv_3',
          type: AchievementType.adventuresCompleted,
          title: 'Aventureiro',
          description: 'Complete 3 aventuras',
          emoji: '🌍',
          goal: 3,
          coinsReward: 80,
          xpReward: 40,
        ),
        Achievement(
          id: 'adv_10',
          type: AchievementType.adventuresCompleted,
          title: 'Explorador',
          description: 'Complete 10 aventuras',
          emoji: '🧭',
          goal: 10,
          coinsReward: 200,
          xpReward: 100,
        ),
        // Coins
        Achievement(
          id: 'coins_500',
          type: AchievementType.coinsEarned,
          title: 'Poupador',
          description: 'Acumule 500 moedas',
          emoji: '💰',
          goal: 500,
          coinsReward: 50,
          xpReward: 25,
        ),
        Achievement(
          id: 'coins_5000',
          type: AchievementType.coinsEarned,
          title: 'Milionário',
          description: 'Acumule 5.000 moedas',
          emoji: '🤑',
          goal: 5000,
          coinsReward: 500,
          xpReward: 200,
        ),
        // Level
        Achievement(
          id: 'level_5',
          type: AchievementType.petLevel,
          title: 'Em Crescimento',
          description: 'Alcance o nível 5',
          emoji: '⭐',
          goal: 5,
          coinsReward: 100,
          xpReward: 50,
        ),
        Achievement(
          id: 'level_10',
          type: AchievementType.petLevel,
          title: 'Campeão',
          description: 'Alcance o nível 10',
          emoji: '🏆',
          goal: 10,
          coinsReward: 300,
          xpReward: 100,
        ),
        // Evolutions
        Achievement(
          id: 'evo_1',
          type: AchievementType.evolutionsUnlocked,
          title: 'Evoluído',
          description: 'Evolua seu pet pela primeira vez',
          emoji: '🔄',
          goal: 1,
          coinsReward: 100,
          xpReward: 50,
        ),
        Achievement(
          id: 'evo_legendary',
          type: AchievementType.evolutionsUnlocked,
          title: 'Lendário',
          description: 'Evolua para a forma Lendária',
          emoji: '🦁',
          goal: 4,
          coinsReward: 500,
          xpReward: 250,
        ),
        // Quests
        Achievement(
          id: 'quests_10',
          type: AchievementType.questsClaimed,
          title: 'Missões Completadas',
          description: 'Complete 10 missões diárias',
          emoji: '📋',
          goal: 10,
          coinsReward: 150,
          xpReward: 75,
        ),
        // Days Streak
        Achievement(
          id: 'streak_3',
          type: AchievementType.daysStreak,
          title: 'Dedicado',
          description: 'Jogue 3 dias seguidos',
          emoji: '🔥',
          goal: 3,
          coinsReward: 100,
          xpReward: 50,
        ),
        Achievement(
          id: 'streak_7',
          type: AchievementType.daysStreak,
          title: 'Fiel',
          description: 'Jogue 7 dias seguidos',
          emoji: '💎',
          goal: 7,
          coinsReward: 300,
          xpReward: 150,
        ),
        // Happiness
        Achievement(
          id: 'happy_80',
          type: AchievementType.happinessMaintained,
          title: 'Felicidade Plena',
          description: 'Mantenha felicidade acima de 80',
          emoji: '😊',
          goal: 1,
          coinsReward: 50,
          xpReward: 25,
        ),
      ];
}
