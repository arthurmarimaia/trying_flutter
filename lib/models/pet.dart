enum PetType {
  reptil, // lagarto/dragão
  canino, // cachorro/lobo
  slime,  // slime amigável
}

class Pet {
  String name;
  int hunger;
  int energy;
  int happiness;
  int health;
  int level;
  int coins;
  int experience;
  int bond; // 0-100: grows with consistent care
  String message;
  DateTime lastUpdate;
  String accessory;
  int currentForm;
  PetType petType;
  /// Up to 7 daily snapshots: [{hunger, energy, happiness, health, timestamp}]
  List<Map<String, int>> healthHistory;
  /// When this pet was first created (set on onboarding).
  DateTime? createdAt;

  Pet({
    this.name = '',
    required this.hunger,
    required this.energy,
    required this.happiness,
    required this.health,
    required this.level,
    required this.coins,
    required this.experience,
    this.bond = 0,
    required this.message,
    required this.lastUpdate,
    required this.accessory,
    this.currentForm = 0,
    this.petType = PetType.canino,
    List<Map<String, int>>? healthHistory,
    this.createdAt,
  }) : healthHistory = healthHistory ?? [];

  factory Pet.initial() {
    return Pet(
      name: '',
      hunger: 50,
      energy: 50,
      happiness: 50,
      health: 50,
      level: 1,
      coins: 0,
      experience: 0,
      bond: 0,
      message: 'Estou pronto para brincar! 😊',
      lastUpdate: DateTime.now(),
      accessory: '',
      currentForm: 0,
      petType: PetType.canino,
    );
  }

  String get bondLabel {
    if (bond >= 80) return 'Alma Gêmea';
    if (bond >= 60) return 'Íntimo';
    if (bond >= 40) return 'Amigo';
    if (bond >= 20) return 'Conhecido';
    return 'Estranho';
  }

  String get stage {
    if (level >= 11) return 'Lendário';
    if (level >= 6) return 'Adulto';
    if (level >= 3) return 'Jovem';
    return 'Filhote';
  }

  String get emoji {
    if (level >= 3) return '🦮';
    if (level == 2) return '🐕';
    return '🐶';
  }

  List<String> get spriteAssets {
    const int frameCount = 3;
    String base = 'sprites/';
    String typeFolder = petType.name;
    String formName = currentForm == 0
        ? 'baby'
        : currentForm == 1
            ? 'young'
            : 'adult';

    return List.generate(frameCount, (index) {
      return '$base$typeFolder/${formName}_$index.png';
    });
  }

  String get spriteAsset => spriteAssets.first;

  String get displayAccessory => accessory.isEmpty ? 'Nenhum' : accessory;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'hunger': hunger,
      'energy': energy,
      'happiness': happiness,
      'health': health,
      'level': level,
      'coins': coins,
      'experience': experience,
      'bond': bond,
      'message': message,
      'lastUpdate': lastUpdate.toIso8601String(),
      'accessory': accessory,
      'currentForm': currentForm,
      'petType': petType.name,
      'healthHistory': healthHistory,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    List<Map<String, int>> parseHistory(dynamic raw) {
      if (raw == null) return [];
      return (raw as List)
          .map((e) => Map<String, int>.from(e as Map))
          .toList();
    }

    return Pet(
      name: map['name'] as String? ?? '',
      hunger: map['hunger'] as int,
      energy: map['energy'] as int,
      happiness: map['happiness'] as int,
      health: map['health'] as int? ?? 50,
      level: map['level'] as int? ?? 1,
      coins: map['coins'] as int? ?? 0,
      experience: map['experience'] as int? ?? 0,
      bond: map['bond'] as int? ?? 0,
      message: map['message'] as String? ?? 'Estou pronto para brincar! 😊',
      lastUpdate: DateTime.parse(map['lastUpdate'] as String),
      accessory: map['accessory'] as String? ?? '',
      currentForm: map['currentForm'] as int? ?? 0,
      petType: PetType.values.firstWhere(
        (e) => e.name == (map['petType'] as String? ?? 'canino'),
        orElse: () => PetType.canino,
      ),
      healthHistory: parseHistory(map['healthHistory']),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}