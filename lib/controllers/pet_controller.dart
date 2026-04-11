import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pet.dart';
import '../models/store_item.dart';
import '../models/pet_event.dart';
import '../models/minigame.dart';
import '../models/pet_evolution.dart';
import '../models/adventure.dart';
import '../models/daily_quest.dart';
import '../models/achievement.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';

class Goal {
  final String id;
  final String title;
  final int target;
  int progress;
  final int reward;

  Goal({
    required this.id,
    required this.title,
    required this.target,
    required this.progress,
    required this.reward,
  });

  bool get completed => progress >= target;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target': target,
      'progress': progress,
      'reward': reward,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      target: map['target'] as int,
      progress: map['progress'] as int,
      reward: map['reward'] as int,
    );
  }

  void increment() {
    if (!completed) {
      progress += 1;
    }
  }
}

// ── Daily Bonus Reward data class ─────────────────────────────────────────────

class DailyBonusReward {
  final int coins;
  final int xp;
  final int bond;
  final String? itemId;
  final String label;

  const DailyBonusReward({
    required this.coins,
    required this.xp,
    required this.bond,
    this.itemId,
    required this.label,
  });
}

class PetController extends ChangeNotifier {
  // ── Profile prefix ──────────────────────────────────────────────────────
  final String prefix;
  String _k(String key) => prefix.isEmpty ? key : '${prefix}_$key';

  PetController({this.prefix = ''}) {
    StorageService.setPrefix(prefix);
  }
        bool _notificationsEnabled = true;
        bool get notificationsEnabled => _notificationsEnabled;
        set notificationsEnabled(bool value) {
          _notificationsEnabled = value;
          if (!value) {
            cancelPetNotifications();
          } else {
            schedulePetNotifications();
          }
          notifyListeners();
        }

        bool get soundEnabled => SoundService.enabled;
        set soundEnabled(bool value) {
          SoundService.setEnabled(value);
          notifyListeners();
        }

        Future<void> schedulePetNotifications() async {
          if (!_notificationsEnabled) return;
          final petName = pet.name.isEmpty ? 'Seu pet' : pet.name;
          // Fome
          if (pet.hunger >= 70) {
            await NotificationService.scheduleNotification(
              1,
              '$petName está com fome!',
              'Alimente $petName para deixá-lo feliz.',
              DateTime.now().add(const Duration(minutes: 30)),
            );
          }
          // Energia
          if (pet.energy <= 30) {
            await NotificationService.scheduleNotification(
              2,
              '$petName está cansado!',
              '$petName precisa descansar para recuperar energia.',
              DateTime.now().add(const Duration(minutes: 45)),
            );
          }
          // Missões diárias completas
          if (dailyQuestsCompleted.isNotEmpty) {
            await NotificationService.scheduleNotification(
              3,
              'Missões diárias completas!',
              '$petName está esperando as recompensas!',
              DateTime.now().add(const Duration(minutes: 10)),
            );
          }
        }

        Future<void> cancelPetNotifications() async {
          await NotificationService.cancelNotification(1);
          await NotificationService.cancelNotification(2);
          await NotificationService.cancelNotification(3);
        }
  late Pet pet;
  List<DailyQuest> dailyQuests = [];
  DateTime lastQuestResetDay = DateTime.now();
  List<Achievement> playerAchievements = Achievement.defaultAchievements();
  List<Achievement> get newlyUnlockedAchievements =>
      playerAchievements.where((a) => a.justUnlocked).toList();
  int _totalCoinsEarned = 0;
  int _totalAdventuresCompleted = 0;
  int get totalAdventuresCompleted => _totalAdventuresCompleted;
  int _totalQuestsClaimed = 0;
  int _loginStreak = 0;
  int get loginStreak => _loginStreak;
  DateTime _lastLoginDate = DateTime.fromMillisecondsSinceEpoch(0);
  bool _dailyBonusPending = false;
  bool get dailyBonusPending => _dailyBonusPending;
  bool loading = true;
  bool isFirstLaunch = false;
  bool isDarkMode = false;
  /// Set to the new level when a level-up occurs; cleared by UI after animating.
  int? _pendingLevelUp;
  int? get pendingLevelUp => _pendingLevelUp;
  void clearPendingLevelUp() => _pendingLevelUp = null;
  /// Emoji shown as floating reaction over the pet. Changes trigger animation.
  String lastReactionEmoji = '';
  int _reactionTick = 0;
  int get reactionTick => _reactionTick;
  /// Titles unlocked through achievements. Persisted per profile.
  Set<String> unlockedTitles = {};
  /// Currently displayed title on profile. Empty = none chosen.
  String activeTitle = '';
  DateTime lastSaved = DateTime.now();
  DateTime lastGoalReset = DateTime.now();
  final List<Goal> dailyGoals = [
    Goal(id: 'feed', title: 'Alimente 3 vezes', target: 3, progress: 0, reward: 5),
    Goal(id: 'play', title: 'Brinque 2 vezes', target: 2, progress: 0, reward: 5),
    Goal(id: 'clean', title: 'Limpe 1 vez', target: 1, progress: 0, reward: 3),
    Goal(id: 'sleep', title: 'Durma 1 vez', target: 1, progress: 0, reward: 3),
  ];
  final List<String> achievements = [];
  Map<String, int> dailyActionCounts = {};
  Map<String, DateTime> lastActionTime = {};
  final List<StoreItem> storeItems = [
    StoreItem(
      id: 'racao_premium',
      name: 'Ração Premium',
      description: 'Recupera fome rapidamente e dá +10 de experiência.',
      price: 18,
      isCosmetic: false,
      icon: '🍖',
    ),
    StoreItem(
      id: 'brinquedo',
      name: 'Brinquedo',
      description: 'Aumenta felicidade e melhora o humor do pet.',
      price: 22,
      isCosmetic: false,
      icon: '🧸',
    ),
    StoreItem(
      id: 'spray_saude',
      name: 'Spray de Saúde',
      description: 'Restaura a saúde do pet quando ele estiver fraco.',
      price: 35,
      isCosmetic: false,
      icon: '🩹',
    ),
    StoreItem(
      id: 'coleira_luz',
      name: 'Coleira Brilhante',
      description: 'Acessório visual que deixa seu pet especial.',
      price: 55,
      isCosmetic: true,
      icon: '✨',
    ),
    StoreItem(
      id: 'chapelinho',
      name: 'Chapéu Festa',
      description: 'Deixa o pet mais feliz e estiloso.',
      price: 70,
      isCosmetic: true,
      icon: '🎩',
    ),
    StoreItem(
      id: 'ninja_mask',
      name: 'Máscara Ninja',
      description: 'Um acessório misterioso. Desbloqueia a Forma Ninja ao atingir nível 5.',
      price: 180,
      isCosmetic: true,
      icon: '🥷',
    ),
    StoreItem(
      id: 'robot_suit',
      name: 'Traje Robô',
      description: 'Um traje futurista. Desbloqueia a Forma Robô ao atingir nível 8.',
      price: 280,
      isCosmetic: true,
      icon: '🤖',
    ),
    StoreItem(
      id: 'alien_helmet',
      name: 'Capacete Alienígena',
      description: 'De outro mundo. Desbloqueia a Forma Alienígena ao atingir nível 12.',
      price: 380,
      isCosmetic: true,
      icon: '👽',
    ),
    StoreItem(
      id: 'wizard_hat',
      name: 'Chapéu de Mago',
      description: 'Um chapéu mágico. Desbloqueia a Forma Mago ao atingir nível 5.',
      price: 200,
      isCosmetic: true,
      icon: '🧢',
    ),
    StoreItem(
      id: 'katana',
      name: 'Katana de Samurai',
      description: 'Uma lâmina lendária. Desbloqueia a Forma Samurai ao atingir nível 7.',
      price: 320,
      isCosmetic: true,
      icon: '⚔️',
    ),
    StoreItem(
      id: 'space_suit',
      name: 'Traje Astronauta',
      description: 'É de outro mundo! Desbloqueia a Forma Astronauta ao atingir nível 6.',
      price: 240,
      isCosmetic: true,
      icon: '🚀',
    ),
    StoreItem(
      id: 'cape',
      name: 'Capa Vampiro',
      description: 'Misteriosa e sombria. Desbloqueia a Forma Vampiro ao atingir nível 6.',
      price: 190,
      isCosmetic: true,
      icon: '🦹',
    ),
  ];
  Map<String, bool> ownedItems = {};
  /// Quantity of each consumable held. key = item id, value = count.
  Map<String, int> inventory = {};
  String selectedAccessory = '';
  PetEvent? currentEvent;
  DateTime lastEventRoll = DateTime.fromMillisecondsSinceEpoch(0);
  /// IDs of today's rotating shop offers (4 random items).
  List<String> dailyShopItemIds = [];
  DateTime _lastShopRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _decayTimer;
  late MiniGameStats miniGameStats;
  late Adventure? currentAdventure;
  late AdventureLog adventureLog;

  Future<void> init() async {
    await NotificationService.init();
    await _loadState();
    _startDecayTimer();

    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString(_k('last_quest_reset'));
    if (lastResetStr != null) {
      lastQuestResetDay = DateTime.parse(lastResetStr);
    }
    _checkDailyQuestsReset();

    // Load achievements
    final achievementsJson = prefs.getString(_k('achievements'));
    if (achievementsJson != null) {
      final list = (jsonDecode(achievementsJson) as List)
          .map((a) => Achievement.fromMap(a as Map<String, dynamic>))
          .toList();
      // Merge saved state into defaults (preserves new achievements on update)
      for (final saved in list) {
        final idx = playerAchievements.indexWhere((a) => a.id == saved.id);
        if (idx != -1) playerAchievements[idx] = saved;
      }
    }
    _totalCoinsEarned = prefs.getInt(_k('total_coins_earned')) ?? 0;
    _totalAdventuresCompleted = prefs.getInt(_k('total_adventures')) ?? 0;
    _totalQuestsClaimed = prefs.getInt(_k('total_quests_claimed')) ?? 0;
    _loginStreak = prefs.getInt(_k('login_streak')) ?? 0;
    final lastLoginStr = prefs.getString(_k('last_login_date'));
    if (lastLoginStr != null) {
      _lastLoginDate = DateTime.parse(lastLoginStr);
    }
    _dailyBonusPending = prefs.getBool(_k('daily_bonus_pending')) ?? false;
    // Load titles
    final titlesJson = prefs.getString(_k('unlocked_titles'));
    if (titlesJson != null) {
      unlockedTitles = Set<String>.from(
          (jsonDecode(titlesJson) as List).map((e) => e as String));
    }
    activeTitle = prefs.getString(_k('active_title')) ?? '';
    // Load daily shop state
    final shopJson = prefs.getString(_k('daily_shop'));
    if (shopJson != null) {
      dailyShopItemIds = List<String>.from(jsonDecode(shopJson) as List);
    }
    final shopRefreshStr = prefs.getString(_k('last_shop_refresh'));
    if (shopRefreshStr != null) {
      _lastShopRefresh = DateTime.tryParse(shopRefreshStr) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }
    // Update streak
    final today = DateTime.now();
    if (isSameDay(today, _lastLoginDate)) {
      // Same day, no change
    } else if (today.difference(_lastLoginDate).inDays == 1) {
      _loginStreak++;
      _lastLoginDate = today;
      _dailyBonusPending = true;
    } else {
      _loginStreak = 1;
      _lastLoginDate = today;
      _dailyBonusPending = true;
    }

    final questsJson = prefs.getString(_k('daily_quests'));
    if (questsJson != null) {
      final questsList = (jsonDecode(questsJson) as List)
          .map((q) => DailyQuest.fromMap(q as Map<String, dynamic>))
          .toList();
      dailyQuests = questsList;
    }

    if (dailyQuests.isEmpty) {
      _generateDailyQuests();
      await saveState(notify: false);
    }
  }

  Future<void> _loadState() async {
    final loadedPet = await StorageService.loadPet();
    pet = loadedPet ?? Pet.initial();
    final state = await StorageService.loadDailyGoals();

    if (state != null) {
      final storedGoals = (jsonDecode(state['goals'] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Goal.fromMap)
          .toList();
      for (final goal in dailyGoals) {
        final savedGoal = storedGoals.firstWhere(
          (element) => element.id == goal.id,
          orElse: () => goal,
        );
        goal.progress = savedGoal.progress;
      }
      lastGoalReset = DateTime.parse(state['lastReset'] as String);
    }

    dailyActionCounts = await StorageService.loadActionCounts();
    lastActionTime = await StorageService.loadActionTimes();

    final storeState = await StorageService.loadStoreState();
    ownedItems = (jsonDecode(storeState['ownedItems'] as String? ?? '{}') as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as bool));
    selectedAccessory = storeState['selectedAccessory'] as String? ?? '';

    final prefs2 = await SharedPreferences.getInstance();
    inventory = (jsonDecode(prefs2.getString(_k('inventory')) ?? '{}') as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));

    final eventState = await StorageService.loadEventState();
    if (eventState.isNotEmpty) {
      final savedEvent = eventState['currentEvent'];
      if (savedEvent != null) {
        currentEvent = PetEvent.fromMap(savedEvent as Map<String, dynamic>);
      }
      lastEventRoll = DateTime.parse(eventState['lastEventRoll'] as String);
    }

    miniGameStats = MiniGameStats();
    final statsJson = prefs2.getString(_k('mini_game_stats'));
    if (statsJson != null) {
      miniGameStats = MiniGameStats.fromMap(
        jsonDecode(statsJson) as Map<String, dynamic>,
      );
    }
    final adventureLogJson = prefs2.getString(_k('adventure_log'));
    adventureLog = adventureLogJson != null
        ? AdventureLog.fromMap(jsonDecode(adventureLogJson) as Map<String, dynamic>)
        : AdventureLog();
    final currentAdventureJson = prefs2.getString(_k('current_adventure'));
    currentAdventure = (currentAdventureJson != null && currentAdventureJson.isNotEmpty)
        ? Adventure.fromMap(jsonDecode(currentAdventureJson) as Map<String, dynamic>)
        : null;

    isFirstLaunch = prefs2.getBool(_k('onboarding_done')) != true;

    _resetGoalsIfNeeded();
    _generateDailyEvent();
    _refreshDailyShopIfNeeded();
    applyTimeDecay();
    _evaluateAchievements();
    await saveState(notify: false);
    loading = false;
    notifyListeners();
  }

  void _resetGoalsIfNeeded() {
    final now = DateTime.now();
    if (!isSameDay(now, lastGoalReset)) {
      for (final goal in dailyGoals) {
        goal.progress = 0;
      }
      lastGoalReset = now;
    }
  }

  void _startDecayTimer() {
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      applyTimeDecay();
      await saveState(notify: false);
      _checkHappinessQuest();
      await schedulePetNotifications();
      notifyListeners();
    });
  }

  String get petMood {
    if (isSick) return 'Doente';
    if (isExhausted) return 'Exausto';
    if (pet.hunger >= 80) return 'Faminto';
    if (pet.happiness <= 20) return 'Triste';
    if (pet.energy >= 80 && pet.happiness >= 80) return 'Radiante';
    return 'Bem-estar';
  }

  bool get needsAttention {
    return pet.hunger >= 70 || pet.energy <= 30 || pet.happiness <= 30 || pet.health <= 30;
  }

  double get minigameRewardMultiplier {
    double multiplier = 1.0;
    if (pet.happiness >= 80) multiplier += 0.15;
    if (pet.energy <= 30) multiplier -= 0.15;
    if (pet.hunger >= 70) multiplier -= 0.10;
    if (pet.health <= 30) multiplier -= 0.10;
    return multiplier.clamp(0.7, 1.25);
  }

  int get minigameDurationAdjustment {
    if (pet.energy >= 80 && pet.happiness >= 80) return 4;
    if (pet.energy <= 30 || pet.happiness <= 30) return -4;
    return 0;
  }

  String get minigameHint {
    if (minigameRewardMultiplier > 1.0) {
      return 'Seu pet está bem! Ganhe recompensas maiores nos minigames.';
    }
    if (needsAttention) {
      return 'Seu pet precisa de atenção. Minigames terão menos recompensa.';
    }
    return 'Estado do pet neutro. Jogue para melhorar as recompensas.';
  }

  String get adventureHint {
    double successChance = 0.9;
    if (pet.happiness >= 80) successChance += 0.05;
    if (pet.energy >= 80) successChance += 0.05;
    if (pet.health <= 30) successChance -= 0.2;
    if (pet.hunger >= 70) successChance -= 0.1;
    successChance = successChance.clamp(0.3, 1.0);
    
    double rewardMultiplier = 1.0;
    if (pet.happiness >= 80) rewardMultiplier += 0.2;
    if (pet.energy >= 80) rewardMultiplier += 0.1;
    if (pet.health <= 30) rewardMultiplier -= 0.2;
    rewardMultiplier = rewardMultiplier.clamp(0.5, 1.5);
    
    if (successChance < 0.8) {
      return 'Seu pet não está bem. Aventura pode falhar ou dar menos recompensa.';
    }
    if (rewardMultiplier > 1.0) {
      return 'Seu pet está ótimo! Maior chance de sucesso e recompensas melhores.';
    }
    return 'Estado do pet normal para aventuras.';
  }

  String get evolutionHint {
    double bonusMultiplier = 1.0;
    if (pet.happiness >= 80) bonusMultiplier -= 0.1;
    if (pet.health >= 80) bonusMultiplier -= 0.05;
    if (pet.energy <= 30) bonusMultiplier += 0.1;
    bonusMultiplier = bonusMultiplier.clamp(0.8, 1.2);
    
    if (bonusMultiplier < 1.0) {
      return 'Seu pet está bem! Evoluções ficam mais fáceis.';
    }
    if (bonusMultiplier > 1.0) {
      return 'Seu pet precisa de mais energia para evoluir facilmente.';
    }
    return 'Estado do pet normal para evoluções.';
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void applyTimeDecay() {
    final now = DateTime.now();
    final difference = now.difference(pet.lastUpdate);
    final minutes = difference.inMinutes;
    if (minutes <= 0) return;

    final hungerDelta = minutes;
    final energyDelta = minutes;
    final happinessDelta = (minutes / 2).round();
    final healthDelta = (minutes / 3).round();

    pet.hunger = (pet.hunger + hungerDelta).clamp(0, 100);
    pet.energy = (pet.energy - energyDelta).clamp(0, 100);
    pet.happiness = (pet.happiness - happinessDelta).clamp(0, 100);
    final prevHealth = pet.health;
    pet.health = (pet.health - healthDelta).clamp(0, 100);
    if (prevHealth > 0 && pet.health == 0) {
      SoundService.play(SoundEffect.fainted);
    } else if (pet.health <= 20 && pet.health > 0 && prevHealth > 20) {
      SoundService.play(SoundEffect.critical);
    }
    // Bond decays slightly for each half-day without care
    final halfDaysMissed = (minutes / 720).floor();
    if (halfDaysMissed > 0) {
      pet.bond = (pet.bond - halfDaysMissed).clamp(0, 100);
    }
    // Record daily health snapshot when at least one full day has passed
    if (difference.inDays >= 1) {
      final snapshot = {
        'hunger': pet.hunger,
        'energy': pet.energy,
        'happiness': pet.happiness,
        'health': pet.health,
        'timestamp': now.millisecondsSinceEpoch ~/ 1000,
      };
      pet.healthHistory.add(snapshot);
      if (pet.healthHistory.length > 7) {
        pet.healthHistory.removeRange(0, pet.healthHistory.length - 7);
      }
    }
    pet.message = _bestStatusMessage();
    _updateLevel();
    pet.lastUpdate = now;
  }

  Future<void> refreshState() async {
    await _loadState();
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  Future<void> completeOnboarding(PetType type, {String name = ''}) async {
    pet.petType = type;
    pet.name = name.trim();
    pet.createdAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_k('onboarding_done'), true);
    isFirstLaunch = false;
    // New pet setup: skip daily bonus so it doesn't appear immediately.
    _dailyBonusPending = false;
    await saveState();
    notifyListeners();
  }

  String get lastInteraction {
    final diff = DateTime.now().difference(pet.lastUpdate);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inHours < 1) return '${diff.inMinutes} min atrás';
    if (diff.inDays < 1) return '${diff.inHours} h atrás';
    return '${diff.inDays} d atrás';
  }

  int get daysAlive => pet.createdAt != null
      ? DateTime.now().difference(pet.createdAt!).inDays + 1
      : 0;

  void changeActiveTitle(String title) {
    activeTitle = title;
    notifyListeners();
    saveState(notify: false);
  }

  void _refreshDailyShopIfNeeded() {
    final now = DateTime.now();
    if (isSameDay(now, _lastShopRefresh)) return;
    _lastShopRefresh = now;
    // Pick 4 distinct random items (prefer unowned cosmetics + consumables mix)
    final pool = storeItems.toList()..shuffle(Random(now.day + now.month * 31));
    dailyShopItemIds = pool.take(4).map((i) => i.id).toList();
  }

  Future<void> renamePet(String name) async {
    pet.name = name.trim();
    await saveState();
  }

  String get stage => pet.stage;

  bool get isSick => pet.health <= 20 && pet.health > 0;
  bool get isExhausted => pet.energy <= 10;
  bool get isFainted => pet.health == 0;

  // ── Bond passive effects ────────────────────────────────────────────────

  /// Extra XP earned per action based on bond level.
  int get bondXpBonus {
    if (pet.bond >= 80) return 5;
    if (pet.bond >= 60) return 3;
    if (pet.bond >= 40) return 2;
    if (pet.bond >= 20) return 1;
    return 0;
  }

  /// Extra coin multiplier from bond (up to +20%).
  double get bondCoinMultiplier {
    if (pet.bond >= 80) return 1.20;
    if (pet.bond >= 60) return 1.12;
    if (pet.bond >= 40) return 1.06;
    return 1.0;
  }

  /// Human-readable description of current bond bonus.
  String get bondBonusDescription {
    if (pet.bond >= 80) return '+5 XP e +20% moedas em todas as ações';
    if (pet.bond >= 60) return '+3 XP e +12% moedas em todas as ações';
    if (pet.bond >= 40) return '+2 XP e +6% moedas em todas as ações';
    if (pet.bond >= 20) return '+1 XP em todas as ações';
    return 'Sem bônus ainda. Interaja mais!';
  }

  void _increaseBond(int amount) {
    pet.bond = (pet.bond + amount).clamp(0, 100);
  }

  // ── Daily Bonus ─────────────────────────────────────────────────────────

  /// Returns the reward for the given streak day index (1-based).
  /// The caller decides what to grant; this just describes what's available.
  DailyBonusReward getDailyBonusReward(int streak) {
    if (streak >= 30) return DailyBonusReward(coins: 50, xp: 80, bond: 10, itemId: null, label: 'Recompensa máxima! 🏆');
    if (streak >= 14) return DailyBonusReward(coins: 30, xp: 50, bond: 8,  itemId: null, label: '2 semanas seguidas! 🔥');
    if (streak >= 7)  return DailyBonusReward(coins: 20, xp: 35, bond: 6,  itemId: null, label: '1 semana seguida! ⭐');
    if (streak >= 5)  return DailyBonusReward(coins: 12, xp: 25, bond: 4,  itemId: 'brinquedo', label: '5 dias seguidos! 🎉');
    if (streak >= 3)  return DailyBonusReward(coins: 8,  xp: 15, bond: 3,  itemId: null, label: '3 dias seguidos!');
    return             DailyBonusReward(coins: 5,  xp: 10, bond: 2,  itemId: null, label: 'Login diário');
  }

  Future<void> claimDailyBonus() async {
    if (!_dailyBonusPending) return;
    _dailyBonusPending = false;
    final reward = getDailyBonusReward(_loginStreak);
    _addCoins(reward.coins);
    pet.experience += reward.xp;
    _increaseBond(reward.bond);
    if (reward.itemId != null) {
      inventory[reward.itemId!] = (inventory[reward.itemId!] ?? 0) + 1;
    }
    pet.message = '🎁 Bônus diário recolhido!';
    _updateLevel();
    await saveState();
    notifyListeners();
  }
  /// [useCoins]: if true, spend 10 coins for a better recovery.
  Future<void> recoverPet({bool useCoins = false}) async {
    SoundService.play(SoundEffect.fainted);
    if (useCoins && pet.coins >= 10) {
      pet.coins -= 10;
      pet.health = 45;
      pet.hunger = 60;
      pet.energy = 35;
      pet.happiness = 35;
      pet.message = 'Me sinto um pouco melhor... 😌';
    } else {
      // Free recovery with heavy penalties
      pet.health = 10;
      pet.hunger = 90;
      pet.energy = 10;
      pet.happiness = 10;
      // XP penalty
      pet.experience = (pet.experience - 30).clamp(0, 9999);
      pet.message = 'Que susto... preciso de cuidados urgentes! 😰';
    }
    await saveState();
    notifyListeners();
  }

  bool canFeed() => pet.hunger > 20 && !isSick;
  bool canSleep() => pet.energy < 80 && !isExhausted;
  bool canPlay() => pet.energy > 20 && !isSick && !isExhausted;
  bool canClean() => pet.health < 90;
  bool canHeal() => pet.health < 50 && pet.coins >= 5;
  bool canTrain() => pet.energy > 30 && pet.health > 40 && !isSick;
  bool canCuddle() => true; // Sempre disponível

  String? getActionRestriction(String action) {
    final now = DateTime.now();
    final lastAction = lastActionTime[action] ?? DateTime.fromMillisecondsSinceEpoch(0);
    final timeSinceLastAction = now.difference(lastAction).inMinutes;
    final dailyCount = dailyActionCounts[action] ?? 0;

    // Cooldown de 5 minutos para ações similares
    if (timeSinceLastAction < 5) {
      return 'Aguarde ${5 - timeSinceLastAction} minutos antes de repetir esta ação.';
    }

    // Limites diários
    switch (action) {
      case 'feed':
        if (dailyCount >= 10) return 'Limite diário de alimentação atingido (10x).';
        if (isSick) return 'Pet está doente, cuide da saúde primeiro!';
        if (pet.hunger <= 20) return 'Pet não está com fome.';
        break;
      case 'sleep':
        if (dailyCount >= 5) return 'Limite diário de sono atingido (5x).';
        if (isExhausted) return 'Pet está exausto, descanse mais tarde.';
        if (pet.energy >= 80) return 'Pet não está cansado.';
        break;
      case 'play':
        if (dailyCount >= 8) return 'Limite diário de brincadeiras atingido (8x).';
        if (isSick) return 'Pet está doente, não pode brincar.';
        if (isExhausted) return 'Pet está exausto, precisa descansar.';
        if (pet.energy <= 20) return 'Pet está sem energia para brincar.';
        break;
      case 'clean':
        if (dailyCount >= 3) return 'Limite diário de limpeza atingido (3x).';
        if (pet.health >= 90) return 'Pet já está limpo e saudável.';
        break;
      case 'heal':
        if (dailyCount >= 2) return 'Limite diário de medicações atingido (2x).';
        if (pet.health >= 50) return 'Pet não precisa de medicação.';
        if (pet.coins < 5) return 'Moedas insuficientes (5 necessárias).';
        break;
      case 'train':
        if (dailyCount >= 4) return 'Limite diário de treinamentos atingido (4x).';
        if (isSick) return 'Pet está doente, não pode treinar.';
        if (pet.energy <= 30) return 'Pet está sem energia para treinar.';
        if (pet.health <= 40) return 'Pet não está saudável o suficiente.';
        break;
      case 'cuddle':
        if (dailyCount >= 15) return 'Limite diário de carinhos atingido (15x).';
        // Sempre disponível, sem outras restrições
        break;
    }
    return null;
  }

  Future<void> _updateState(String message, void Function() update, [String? actionId]) async {
    SoundService.play(SoundEffect.action);
    update();
    // Bond passive: extra XP per action
    pet.experience += bondXpBonus;
    pet.message = message;
    pet.lastUpdate = DateTime.now();
    if (actionId != null) {
      lastActionTime[actionId] = DateTime.now();
      dailyActionCounts[actionId] = (dailyActionCounts[actionId] ?? 0) + 1;
    }
    // Small bond gain for every interaction
    _increaseBond(1);
    _updateLevel();
    _evaluateAchievements();
    await saveState();
    HapticFeedback.lightImpact();
  }

  void _updateLevel() {
    while (pet.experience >= 100) {
      pet.experience -= 100;
      if (pet.level < 12) {
        pet.level++;
        _pendingLevelUp = pet.level;
        achievements.add('Subiu para o nível ${pet.level}!');
        SoundService.play(SoundEffect.levelUp);
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _evaluateAchievements() {
    if (pet.health >= 90 && !achievements.contains('Saúde máxima alcançada')) {
      achievements.add('Saúde máxima alcançada');
    }
    if (pet.hunger <= 10 && !achievements.contains('Fome controlada')) {
      achievements.add('Fome controlada');
    }
    _checkPlayerAchievements();
  }

  void _checkPlayerAchievements() {
    bool anyNew = false;
    for (final a in playerAchievements) {
      if (a.unlocked) continue;
      bool newlyUnlocked = false;
      switch (a.type) {
        case AchievementType.gamesPlayed:
          newlyUnlocked = a.updateProgress(miniGameStats.totalGamesPlayed);
        case AchievementType.adventuresCompleted:
          newlyUnlocked = a.updateProgress(_totalAdventuresCompleted);
        case AchievementType.coinsEarned:
          newlyUnlocked = a.updateProgress(_totalCoinsEarned);
        case AchievementType.petLevel:
          newlyUnlocked = a.updateProgress(pet.level);
        case AchievementType.evolutionsUnlocked:
          newlyUnlocked = a.updateProgress(pet.currentForm);
        case AchievementType.daysStreak:
          newlyUnlocked = a.updateProgress(_loginStreak);
        case AchievementType.questsClaimed:
          newlyUnlocked = a.updateProgress(_totalQuestsClaimed);
        case AchievementType.happinessMaintained:
          newlyUnlocked = a.updateProgress(pet.happiness >= 80 ? 1 : 0);
      }
      if (newlyUnlocked) {
        anyNew = true;
        SoundService.play(SoundEffect.achievement);
        _addCoins(a.coinsReward);
        pet.experience += a.xpReward;
        // Grant item reward (cosmetic — add to ownedItems)
        if (a.itemReward != null) {
          ownedItems[a.itemReward!] = true;
        }
        // Grant title reward
        if (a.titleReward != null) {
          unlockedTitles.add(a.titleReward!);
          if (activeTitle.isEmpty) activeTitle = a.titleReward!;
        }
        achievements.add('🏅 Conquista: ${a.title} (+${a.coinsReward} 💰)');
        NotificationService.showNotification(
          '🏅 Conquista Desbloqueada!',
          '${a.emoji} ${a.title}',
        );
      }
    }
    if (anyNew) notifyListeners();
  }

  String _bestStatusMessage() {
    if (pet.health <= 10) return 'Preciso de socorro urgente! 🆘';
    if (pet.hunger >= 90) return 'Estou passando mal de fome! 😩';
    if (pet.hunger >= 80) return 'Estou com muita fome! 🍖';
    if (pet.energy <= 10) return 'Mal consigo ficar de pé... 😵';
    if (pet.energy <= 20) return 'Estou com muito sono... 😴';
    if (pet.happiness <= 10) return 'Estou muito triste... 😢';
    if (pet.happiness <= 20) return 'Quero brincar! 🎾';
    if (pet.health <= 30) return 'Preciso de cuidados. 🩺';
    if (pet.bond >= 80 && pet.happiness >= 70) return 'Você é o melhor! ❤️';
    if (pet.health >= 90 && pet.happiness >= 80 && pet.energy >= 80) return 'Me sinto invencível! 💪';
    if (pet.happiness >= 80) return 'Estou muito feliz! 😄';
    return 'Estou me sentindo bem! 😊';
  }

  String get currentEventText {
    if (currentEvent == null) {
      return 'Nenhum evento ativo no momento.';
    }
    return '${currentEvent!.title}: ${currentEvent!.description}';
  }

  /// Returns the currently equipped cosmetic [StoreItem], or null if none.
  StoreItem? get equippedAccessoryItem => selectedAccessory.isEmpty
      ? null
      : storeItems.where((i) => i.id == selectedAccessory).firstOrNull;

  /// Returns null if purchasable, or error reason string.
  String? getStoreRestriction(String id) {
    final item = storeItems.firstWhere((item) => item.id == id);
    if (item.isCosmetic && (ownedItems[item.id] ?? false)) return null;
    if (pet.coins < item.price) return 'Moedas insuficientes.';
    if (!item.isCosmetic && item.maxStack > 0) {
      final held = inventory[item.id] ?? 0;
      if (held >= item.maxStack) return 'Inventário cheio (max ${item.maxStack}).';
    }
    return null;
  }

  bool isOwned(String id) => ownedItems[id] ?? false;

  int inventoryCount(String id) => inventory[id] ?? 0;

  Future<void> buyItem(String id) async {
    final item = storeItems.firstWhere((item) => item.id == id);
    if (item.isCosmetic && (ownedItems[item.id] ?? false)) {
      await equipAccessory(id);
      return;
    }
    final restriction = getStoreRestriction(id);
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }

    pet.coins -= item.price;
    if (item.isCosmetic) {
      ownedItems[item.id] = true;
      selectedAccessory = item.id;
      pet.accessory = item.name;
      pet.message = 'Você comprou e equipou ${item.icon} ${item.name}!';
    } else {
      inventory[item.id] = (inventory[item.id] ?? 0) + 1;
      pet.message = '${item.icon} ${item.name} adicionado ao inventário!';
    }

    await saveState();
    await NotificationService.showNotification('Loja', 'Você comprou ${item.name}.');
    notifyListeners();
  }

  /// Use one consumable from inventory, applying its effect.
  Future<void> useItem(String id) async {
    final count = inventory[id] ?? 0;
    if (count <= 0) {
      pet.message = 'Sem itens para usar!';
      notifyListeners();
      return;
    }
    final item = storeItems.firstWhere((i) => i.id == id);
    inventory[id] = count - 1;
    if (inventory[id] == 0) inventory.remove(id);
    _triggerReaction(item.id);
    _applyItemEffect(item);
    await saveState();
    notifyListeners();
  }

  Future<void> equipAccessory(String id) async {
    if (!(ownedItems[id] ?? false)) return;
    final item = storeItems.firstWhere((i) => i.id == id);
    selectedAccessory = id;
    pet.accessory = item.name;
    pet.message = 'Equipou ${item.icon} ${item.name}!';
    await saveState();
    notifyListeners();
  }

  void _applyItemEffect(StoreItem item) {
    switch (item.id) {
      case 'racao_premium':
        pet.hunger = (pet.hunger - 30).clamp(0, 100);
        pet.energy = (pet.energy + 10).clamp(0, 100);
        pet.experience += 12;
        pet.message = 'Ração premium servida! 😋';
        break;
      case 'brinquedo':
        pet.happiness = (pet.happiness + 20).clamp(0, 100);
        pet.energy = (pet.energy - 5).clamp(0, 100);
        pet.message = 'O pet está feliz com o brinquedo! 🎉';
        break;
      case 'spray_saude':
        pet.health = (pet.health + 25).clamp(0, 100);
        pet.message = 'Spray de saúde aplicado! 🩺';
        break;
      default:
        pet.message = 'Compra realizada com sucesso!';
    }
  }

  void _generateDailyEvent() {
    final now = DateTime.now();
    if (isSameDay(now, lastEventRoll) && currentEvent != null) return;

    // Check for seasonal event first
    final seasonal = _getSeasonalEvent(now);

    final possibleEvents = [
      PetEvent(
        id: 'tempestade',
        title: 'Dia nublado',
        description: 'O pet precisa de mais carinho hoje.',
        happinessDelta: -5,
        energyDelta: -5,
      ),
      PetEvent(
        id: 'amigo',
        title: 'Visitante amigável',
        description: 'Seu pet ganhou animação extra!',
        happinessDelta: 10,
      ),
      PetEvent(
        id: 'novos_sabores',
        title: 'Comida especial',
        description: 'Você encontrou um petisco delicioso.',
        hungerDelta: -10,
        coinsDelta: 3,
      ),
      PetEvent(
        id: 'cuidado_extra',
        title: 'Dia de cuidados extras',
        description: 'O pet está um pouco fraco hoje.',
        healthDelta: -10,
      ),
    ];

    final random = Random();
    // 30% chance to use seasonal event (when available)
    if (seasonal != null && random.nextDouble() < 0.30) {
      currentEvent = seasonal;
    } else {
      currentEvent = possibleEvents[random.nextInt(possibleEvents.length)];
    }
    lastEventRoll = now;
    _applyEvent(currentEvent!);
    NotificationService.showNotification('Evento diário', currentEvent!.title);
  }

  /// Returns a themed seasonal [PetEvent] if today falls within a notable period,
  /// or null otherwise.
  PetEvent? _getSeasonalEvent(DateTime now) {
    final month = now.month;
    final day = now.day;

    // Páscoa — April
    if (month == 4) {
      return PetEvent(
        id: 'pascoa',
        title: '🐣 Páscoa!',
        description: 'Ovos de chocolate por toda parte! Seu pet está eufórico.',
        happinessDelta: 15,
        hungerDelta: -8,
        coinsDelta: 5,
      );
    }
    // Festa Junina — June
    if (month == 6) {
      return PetEvent(
        id: 'festa_junina',
        title: '🎆 Festa Junina!',
        description: 'Forró e pipoca! O pet dança de alegria.',
        happinessDelta: 10,
        energyDelta: 5,
        coinsDelta: 3,
      );
    }
    // Halloween — October
    if (month == 10) {
      return PetEvent(
        id: 'halloween',
        title: '🎃 Halloween!',
        description: 'Doces ou travessuras? Seu pet está assustado mas feliz!',
        happinessDelta: 8,
        healthDelta: -5,
        coinsDelta: 8,
      );
    }
    // Natal — December
    if (month == 12) {
      return PetEvent(
        id: 'natal',
        title: '🎄 Natal!',
        description: 'Papai Noel visitou o pet! Presentes para todos.',
        happinessDelta: 20,
        healthDelta: 5,
        coinsDelta: 10,
      );
    }
    // Ano Novo — January 1
    if (month == 1 && day == 1) {
      return PetEvent(
        id: 'ano_novo',
        title: '🎉 Ano Novo!',
        description: 'Fogos no céu! Seu pet está cheio de esperança.',
        happinessDelta: 20,
        energyDelta: 10,
        coinsDelta: 5,
      );
    }
    return null;
  }

  void _applyEvent(PetEvent event) {
    pet.hunger = (pet.hunger + event.hungerDelta).clamp(0, 100);
    pet.energy = (pet.energy + event.energyDelta).clamp(0, 100);
    pet.happiness = (pet.happiness + event.happinessDelta).clamp(0, 100);
    pet.health = (pet.health + event.healthDelta).clamp(0, 100);
    pet.coins = (pet.coins + event.coinsDelta).clamp(0, 999);
    pet.message = event.description;
  }

  Future<void> feed() async {
    final restriction = getActionRestriction('feed');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    final h = pet.hunger;
    final feedMsg = h <= 10
        ? 'Não estava com fome, mas obrigado pelo petisco! 😊'
        : h >= 80
            ? 'Estava morrendo de fome! Que alívio! 😤'
            : 'Fome saciada! 😋';
    await _updateState(
      feedMsg,
      () {
        _triggerReaction('feed');
        pet.hunger = (pet.hunger - 20).clamp(0, 100);
        _addCoins(1);
        pet.experience += 8;
        _incrementGoal('feed');
      },
      'feed',
    );
  }

  Future<void> sleep() async {
    final restriction = getActionRestriction('sleep');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    final e = pet.energy;
    final sleepMsg = e >= 90
        ? 'Não estava com sono, mas uma soneca não faz mal! 😴'
        : e <= 10
            ? 'FINALMENTE! Estava exausto mesmo... 😵'
            : 'Hora de descansar. 💤';
    await _updateState(
      sleepMsg,
      () {
        _triggerReaction('sleep');
        pet.energy = (pet.energy + 25).clamp(0, 100);
        pet.health = (pet.health + 10).clamp(0, 100);
        pet.hunger = (pet.hunger + 5).clamp(0, 100);
        pet.experience += 5;
        _incrementGoal('sleep');
      },
      'sleep',
    );
  }

  Future<void> play() async {
    final restriction = getActionRestriction('play');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    final p = pet.energy;
    final playMsg = p <= 10
        ? 'Estou cansado... mas uma brincadeirinha tá bom! 😅'
        : pet.happiness >= 90
            ? 'Já estou feliz, mas brincar é sempre melhor! 🎉'
            : 'Vamos brincar! 🎾';
    await _updateState(
      playMsg,
      () {
        _triggerReaction('play');
        pet.happiness = (pet.happiness + 20).clamp(0, 100);
        pet.energy = (pet.energy - 15).clamp(0, 100);
        pet.experience += 10;
        _addCoins(2);
        _incrementGoal('play');
      },
      'play',
    );
  }

  Future<void> clean() async {
    final restriction = getActionRestriction('clean');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    await _updateState(
      'Tudo limpinho! 🛁',
      () {
        _triggerReaction('clean');
        pet.health = (pet.health + 20).clamp(0, 100);
        pet.happiness = (pet.happiness - 5).clamp(0, 100);
        pet.experience += 6;
        _incrementGoal('clean');
      },
      'clean',
    );
  }

  Future<void> heal() async {
    final restriction = getActionRestriction('heal');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    await _updateState(
      'Medicação aplicada. ❤️',
      () {
        _triggerReaction('heal');
        pet.health = (pet.health + 25).clamp(0, 100);
        pet.energy = (pet.energy - 10).clamp(0, 100);
        pet.coins = (pet.coins - 5).clamp(0, 999);
        pet.experience += 5;
      },
      'heal',
    );
  }

  Future<void> train() async {
    final restriction = getActionRestriction('train');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    await _updateState(
      'Treino concluído! 💪',
      () {
        _triggerReaction('train');
        pet.experience += 15;
        pet.energy = (pet.energy - 20).clamp(0, 100);
        pet.happiness = (pet.happiness - 5).clamp(0, 100);
      },
      'train',
    );
  }

  Future<void> cuddle() async {
    final restriction = getActionRestriction('cuddle');
    if (restriction != null) {
      pet.message = restriction;
      notifyListeners();
      return;
    }
    final cuddleMsg = pet.bond >= 80
        ? 'Somos almas gêmeas! Esse carinho é tudo! 💖'
        : pet.bond >= 60
            ? 'Que carinho maravilhoso! Te adoro! 🥰'
            : 'Amo esse carinho! 🤗';
    await _updateState(
      cuddleMsg,
      () {
        _triggerReaction('cuddle');
        pet.happiness = (pet.happiness + 15).clamp(0, 100);
        pet.health = (pet.health + 5).clamp(0, 100);
        pet.experience += 4;
        _increaseBond(3); // Cuddle gives extra bond
      },
      'cuddle',
    );
  }

  void _triggerReaction(String emoji) {
    lastReactionEmoji = emoji;
    _reactionTick++;
    // notifyListeners will be called by the action that follows
  }

  void _addCoins(int amount) {
    if (amount > 0) {
      SoundService.play(SoundEffect.coin);
      final bonusAmount = (amount * bondCoinMultiplier).round();
      pet.coins = (pet.coins + bonusAmount).clamp(0, 999);
    }
  }

  void _incrementGoal(String goalId) {
    final goal = dailyGoals.firstWhere((goal) => goal.id == goalId);
    goal.increment();
    if (goal.completed) {
      _addCoins(goal.reward);
    }
  }

  Future<void> saveState({bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final questsJson = jsonEncode(dailyQuests.map((q) => q.toMap()).toList());
    prefs.setString(_k('daily_quests'), questsJson);
    prefs.setString(_k('last_quest_reset'), lastQuestResetDay.toIso8601String());
    final achievementsJson = jsonEncode(playerAchievements.map((a) => a.toMap()).toList());
    prefs.setString(_k('achievements'), achievementsJson);
    prefs.setInt(_k('total_coins_earned'), _totalCoinsEarned);
    prefs.setInt(_k('total_adventures'), _totalAdventuresCompleted);
    prefs.setInt(_k('total_quests_claimed'), _totalQuestsClaimed);
    prefs.setInt(_k('login_streak'), _loginStreak);
    prefs.setString(_k('last_login_date'), _lastLoginDate.toIso8601String());
    prefs.setBool(_k('daily_bonus_pending'), _dailyBonusPending);
    prefs.setString(_k('inventory'), jsonEncode(inventory));
    prefs.setString(_k('unlocked_titles'), jsonEncode(unlockedTitles.toList()));
    prefs.setString(_k('active_title'), activeTitle);
    prefs.setString(_k('daily_shop'), jsonEncode(dailyShopItemIds));
    prefs.setString(_k('last_shop_refresh'), _lastShopRefresh.toIso8601String());
    prefs.setString(_k('mini_game_stats'), jsonEncode(miniGameStats.toMap()));
    prefs.setString(_k('adventure_log'), jsonEncode(adventureLog.toMap()));
    prefs.setString(_k('current_adventure'),
        currentAdventure != null ? jsonEncode(currentAdventure!.toMap()) : '');

    await StorageService.savePet(pet);
    await StorageService.saveDailyGoals(
      dailyGoals.map((goal) => goal.toMap()).toList(),
      lastGoalReset,
    );
    await StorageService.saveActionCounts(dailyActionCounts);
    await StorageService.saveActionTimes(lastActionTime);
    await StorageService.saveStoreState(ownedItems, selectedAccessory);
    await StorageService.saveEventState({
      'currentEvent': currentEvent?.toMap(),
      'lastEventRoll': lastEventRoll.toIso8601String(),
    });
    lastSaved = DateTime.now();
    if (notify) notifyListeners();
  }

  Future<void> resetProgress() async {
    for (final goal in dailyGoals) {
      goal.progress = 0;
    }
    dailyActionCounts.clear();
    lastGoalReset = DateTime.now();
    await saveState();
  }

  /// Full reset: wipes this profile's saved data and returns player to onboarding.
  Future<void> resetPet() async {
    final prefs = await SharedPreferences.getInstance();
    // Only remove keys belonging to this profile (safe for multi-user)
    final keysToRemove = prefs.getKeys()
        .where((k) => prefix.isEmpty || k.startsWith('${prefix}_'))
        .toList();
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
    pet = Pet.initial();
    achievements.clear();
    playerAchievements = Achievement.defaultAchievements();
    for (final g in dailyGoals) {
      g.progress = 0;
    }
    dailyActionCounts.clear();
    lastActionTime.clear();
    inventory.clear();
    ownedItems.clear();
    selectedAccessory = '';
    currentAdventure = null;
    adventureLog = AdventureLog();
    miniGameStats = MiniGameStats();
    _totalCoinsEarned = 0;
    _totalAdventuresCompleted = 0;
    _totalQuestsClaimed = 0;
    _loginStreak = 0;
    _dailyBonusPending = false;
    isFirstLaunch = true;
    notifyListeners();
  }

  Future<void> processGameResult(GameResult result) async {
    _addCoins(result.coinsReward);
    pet.experience += result.xpReward;
    pet.happiness = min(100, pet.happiness + result.happinessReward);
    _totalCoinsEarned += result.coinsReward;

    _updateLevel();
    
  _updateQuestProgress(QuestType.playMinigames, 1);
  _updateQuestProgress(QuestType.earnCoins, result.coinsReward);
    
  miniGameStats.totalGamesPlayed++;
    miniGameStats.totalCoinsEarned += result.coinsReward;
    miniGameStats.totalXpEarned += result.xpReward;

    final bestScore = miniGameStats.bestScores[result.type] ?? 0;
    if (result.score > bestScore) {
      miniGameStats.bestScores[result.type] = result.score;
      _addAchievement('🏆 Novo recorde em ${result.type.toString().split('.').last}!');
    }

    await saveState();
    _checkPlayerAchievements();
  }

  // ── Backup / Restore ────────────────────────────────────────────────────────

  /// Serialises all relevant game state into a JSON string for export.
  String exportBackupJson() {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'pet': pet.toMap(),
      'inventory': inventory,
      'ownedItems': ownedItems,
      'selectedAccessory': selectedAccessory,
      'unlockedTitles': unlockedTitles.toList(),
      'activeTitle': activeTitle,
      'loginStreak': _loginStreak,
      'dailyShop': dailyShopItemIds,
      'lastShopRefresh': _lastShopRefresh.toIso8601String(),
      'miniGameStats': miniGameStats.toMap(),
      'adventureLog': adventureLog.toMap(),
      'totalCoinsEarned': _totalCoinsEarned,
      'totalAdventures': _totalAdventuresCompleted,
      'totalQuestsClaimed': _totalQuestsClaimed,
      'achievements': playerAchievements.map((a) => a.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Restores game state from a previously exported JSON string.
  /// Returns null on success, or an error message string on failure.
  Future<String?> importBackupJson(String jsonStr) async {
    try {
      final raw = jsonDecode(jsonStr);
      if (raw is! Map<String, dynamic>) return 'JSON inválido.';

      final version = raw['version'] as int? ?? 0;
      if (version < 1) return 'Formato de backup desconhecido.';

      // Restore pet
      if (raw['pet'] != null) {
        pet = Pet.fromMap(Map<String, dynamic>.from(raw['pet'] as Map));
      }

      // Restore inventory
      if (raw['inventory'] != null) {
        inventory = Map<String, int>.from(
            (raw['inventory'] as Map).map((k, v) => MapEntry(k as String, v as int)));
      }

      // Restore owned items
      if (raw['ownedItems'] != null) {
        ownedItems = Map<String, bool>.from(
            (raw['ownedItems'] as Map).map((k, v) => MapEntry(k as String, v as bool)));
      }

      selectedAccessory = raw['selectedAccessory'] as String? ?? '';

      if (raw['unlockedTitles'] != null) {
        unlockedTitles = Set<String>.from(raw['unlockedTitles'] as List);
      }
      activeTitle = raw['activeTitle'] as String? ?? '';

      _loginStreak = raw['loginStreak'] as int? ?? 0;

      if (raw['achievements'] != null) {
        final list = (raw['achievements'] as List)
            .map((e) => Achievement.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        playerAchievements = list;
      }

      await saveState();
      return null; // success
    } catch (e) {
      return 'Erro ao importar: $e';
    }
  }

  void _addAchievement(String achievement) {
    if (!achievements.contains(achievement)) {
      achievements.add(achievement);
    }
  }

  // Evolution Methods
  Future<void> evolvePet(PetForm newForm) async {
    pet.currentForm = newForm.index;
    _addAchievement('✨ Evoluiu para ${PetEvolution.fromForm(newForm).displayName}!');
    pet.happiness = min(100, pet.happiness + 10);
    SoundService.play(SoundEffect.evolution);
    HapticFeedback.heavyImpact();
    await saveState();
    _checkPlayerAchievements();
    notifyListeners();
  }

  PetForm get currentPetForm => PetForm.values[pet.currentForm];

  String getFormEmoji() {
    return PetEvolution.fromForm(currentPetForm).displayEmoji;
  }

  // Adventure Methods
  void startAdventure(Adventure adventure) {
    currentAdventure = adventure;
    adventure.startAdventure();
    notifyListeners();
  }

  Future<void> completeAdventure() async {
    if (currentAdventure != null && currentAdventure!.isActive) {
      // Calculate success chance based on pet state
      double successChance = 0.9; // Base 90% success
      if (pet.happiness >= 80) successChance += 0.05;
      if (pet.energy >= 80) successChance += 0.05;
      if (pet.health <= 30) successChance -= 0.2;
      if (pet.hunger >= 70) successChance -= 0.1;
      successChance = successChance.clamp(0.3, 1.0);

      bool success = Random().nextDouble() < successChance;

      if (success) {
        currentAdventure!.completeAdventure();
        
        // Apply reward multiplier based on pet state
        _updateQuestProgress(QuestType.completeAdventure, 1);
        
        double rewardMultiplier = 1.0;
        if (pet.happiness >= 80) rewardMultiplier += 0.2;
        if (pet.energy >= 80) rewardMultiplier += 0.1;
        if (pet.health <= 30) rewardMultiplier -= 0.2;
        rewardMultiplier = rewardMultiplier.clamp(0.5, 1.5);
        
        int adjustedCoins = ((currentAdventure!.coinsReward ?? 0) * rewardMultiplier).round();
        _addCoins(adjustedCoins);
        pet.happiness = min(100, pet.happiness + 5);
        
        adventureLog.addCompleted(currentAdventure!);
        _addAchievement('🌍 Completou aventura: ${currentAdventure!.name} (+$adjustedCoins 💰)');
        _totalAdventuresCompleted++;
        _totalCoinsEarned += adjustedCoins;
      } else {
        // Adventure failed
        pet.happiness = max(0, pet.happiness - 10);
        _addAchievement('❌ Aventura falhou: ${currentAdventure!.name}');
      }
      
      currentAdventure = null;
      await saveState();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }

  Future<void> cancelAdventure() async {
    currentAdventure = null;
    await saveState();
    notifyListeners();
  }

  Adventure getRandomAdventure() {
    return predefinedAdventures[Random().nextInt(predefinedAdventures.length)];
  }

  void _generateDailyQuests() {
    dailyQuests = DailyQuest.generateDailyQuests();
    lastQuestResetDay = DateTime.now();
    notifyListeners();
  }

  void _checkDailyQuestsReset() {
    final now = DateTime.now();
    if (!isSameDay(now, lastQuestResetDay)) {
      // New day, reset or expire old quests
      for (final quest in dailyQuests) {
        if (quest.status == QuestStatus.active) {
          quest.status = QuestStatus.expired;
        }
      }
      _generateDailyQuests();
    }
  }

  void _updateQuestProgress(QuestType type, int amount) {
    _checkDailyQuestsReset();
    for (final quest in dailyQuests) {
      if (quest.type == type && quest.status == QuestStatus.active) {
        quest.updateProgress(amount);
      }
    }
    notifyListeners();
  }

  void _checkHappinessQuest() {
    _checkDailyQuestsReset();
    for (final quest in dailyQuests) {
      if (quest.type == QuestType.maintainHappiness && 
          quest.status == QuestStatus.active && 
          pet.happiness > 70) {
        quest.status = QuestStatus.completed;
      }
    }
  }

  Future<void> claimQuestReward(String questId) async {
    final quest = dailyQuests.firstWhere(
      (q) => q.id == questId && q.status == QuestStatus.completed,
      orElse: () => DailyQuest(
        id: '', type: QuestType.playMinigames, title: '',
        description: '', emoji: '', goalProgress: 0,
        coinsReward: 0, xpReward: 0,
      ),
    );

    if (quest.id.isEmpty) return;

    _addCoins(quest.coinsReward);
    pet.experience += quest.xpReward;
    quest.status = QuestStatus.claimed;
    _totalQuestsClaimed++;
    _addAchievement('✅ Missão completa: ${quest.title} (+${quest.coinsReward} 💰 +${quest.xpReward} ⭐)');
    await schedulePetNotifications();
    await saveState();
    _checkPlayerAchievements();
    notifyListeners();
  }

  List<DailyQuest> get dailyQuestsActive => dailyQuests.where((q) => q.status != QuestStatus.expired).toList();
  List<DailyQuest> get dailyQuestsCompleted => dailyQuests.where((q) => q.status == QuestStatus.completed).toList();
}

