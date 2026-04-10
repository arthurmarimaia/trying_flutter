class PetEvent {
  final String id;
  final String title;
  final String description;
  final int hungerDelta;
  final int energyDelta;
  final int happinessDelta;
  final int healthDelta;
  final int coinsDelta;

  PetEvent({
    required this.id,
    required this.title,
    required this.description,
    this.hungerDelta = 0,
    this.energyDelta = 0,
    this.happinessDelta = 0,
    this.healthDelta = 0,
    this.coinsDelta = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hungerDelta': hungerDelta,
      'energyDelta': energyDelta,
      'happinessDelta': happinessDelta,
      'healthDelta': healthDelta,
      'coinsDelta': coinsDelta,
    };
  }

  factory PetEvent.fromMap(Map<String, dynamic> map) {
    return PetEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      hungerDelta: map['hungerDelta'] as int? ?? 0,
      energyDelta: map['energyDelta'] as int? ?? 0,
      happinessDelta: map['happinessDelta'] as int? ?? 0,
      healthDelta: map['healthDelta'] as int? ?? 0,
      coinsDelta: map['coinsDelta'] as int? ?? 0,
    );
  }
}
