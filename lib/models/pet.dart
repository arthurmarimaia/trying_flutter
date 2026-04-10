enum PetType {
  reptil, // lagarto/dragão
  canino, // cachorro/lobo
  slime,  // slime amigável
}

class Pet {
  int hunger;
  int energy;
  int happiness;
  int health;
  int level;
  int coins;
  int experience;
  String message;
  DateTime lastUpdate;
  String accessory;
  int currentForm; // 0 = baby, 1 = young, 2 = adult, 3 = legendary, etc
  PetType petType;

  Pet({
    required this.hunger,
    required this.energy,
    required this.happiness,
    required this.health,
    required this.level,
    required this.coins,
    required this.experience,
    required this.message,
    required this.lastUpdate,
    required this.accessory,
    this.currentForm = 0,
    this.petType = PetType.canino,
  });

  factory Pet.initial() {
    return Pet(
      hunger: 50,
      energy: 50,
      happiness: 50,
      health: 50,
      level: 1,
      coins: 0,
      experience: 0,
      message: 'Estou pronto para brincar! 😊',
      lastUpdate: DateTime.now(),
      accessory: '',
      currentForm: 0,
      petType: PetType.canino,
    );
  }

  String get stage {
    if (level >= 3) return 'Adulto';
    if (level == 2) return 'Jovem';
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
      'hunger': hunger,
      'energy': energy,
      'happiness': happiness,
      'health': health,
      'level': level,
      'coins': coins,
      'experience': experience,
      'message': message,
      'lastUpdate': lastUpdate.toIso8601String(),
      'accessory': accessory,
      'currentForm': currentForm,
      'petType': petType.name,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      hunger: map['hunger'] as int,
      energy: map['energy'] as int,
      happiness: map['happiness'] as int,
      health: map['health'] as int? ?? 50,
      level: map['level'] as int? ?? 1,
      coins: map['coins'] as int? ?? 0,
      experience: map['experience'] as int? ?? 0,
      message: map['message'] as String? ?? 'Estou pronto para brincar! 😊',
      lastUpdate: DateTime.parse(map['lastUpdate'] as String),
      accessory: map['accessory'] as String? ?? '',
      currentForm: map['currentForm'] as int? ?? 0,
      petType: PetType.values.firstWhere(
        (e) => e.name == (map['petType'] as String? ?? 'canino'),
        orElse: () => PetType.canino,
      ),
    );
  }
}