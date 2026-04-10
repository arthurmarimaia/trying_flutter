enum PetForm {
  baby,          // Filhote (Nível 1-2)
  young,         // Jovem (Nível 3-5)
  adult,         // Adulto (Nível 6-10)
  legendary,     // Lendário (Nível 11+)

  // Formas especiais baseadas em stats
  powerfulForm,  // Alto em fitness/saúde
  happyForm,     // Alto em felicidade
  smartForm,     // Alto em experiência

  // Formas raras por acessório (originais)
  ninjaForm,     // Acessório ninja
  robotForm,     // Acessório robô
  alienForm,     // Acessório alienígena

  // Formas por stats extremos
  shadowForm,    // Felicidade muito baixa
  athleteForm,   // Saúde + energia máximas
  hungryForm,    // Fome crítica
  ghostForm,     // Saúde crítica

  // Formas por conquistas/progressão
  gameMasterForm,  // 50+ minigames jogados
  explorerForm,    // 10+ aventuras completas
  millionaireForm, // 500+ moedas
  veteranForm,     // 30+ dias de streak

  // Formas por novos acessórios
  wizardForm,    // Chapéu de Mago
  samuraiForm,   // Katana de Samurai
  astronautForm, // Traje Astronauta
  vampireForm,   // Capa Vampiro
}

class PetEvolution {
  final PetForm currentForm;
  final int levelRequired;
  /// Requisitos mínimos de stat (sujeitos ao bônus multiplicador)
  final Map<String, int> statRequirements;
  /// Requisitos de stat máximo — o stat deve ser ≤ ao valor (sem multiplicador)
  final Map<String, int> maxStatRequirements;
  /// Requisitos mínimos fixos — sem multiplicador (usado para conquistas)
  final Map<String, int> fixedStatRequirements;
  final String? requiredAccessoryId;
  final String displayEmoji;
  final String displayName;

  PetEvolution({
    required this.currentForm,
    required this.levelRequired,
    required this.statRequirements,
    this.maxStatRequirements = const {},
    this.fixedStatRequirements = const {},
    this.requiredAccessoryId,
    required this.displayEmoji,
    required this.displayName,
  });

  bool canEvolve(int level, Map<String, int> stats, String? currentAccessory) {
    if (level < levelRequired) return false;

    // Multiplicador baseado no estado atual do pet
    double bonusMultiplier = 1.0;
    if ((stats['happiness'] ?? 0) >= 80) bonusMultiplier -= 0.1;
    if ((stats['health'] ?? 0) >= 80) bonusMultiplier -= 0.05;
    if ((stats['energy'] ?? 0) <= 30) bonusMultiplier += 0.1;
    bonusMultiplier = bonusMultiplier.clamp(0.8, 1.2);

    for (final entry in statRequirements.entries) {
      int required = (entry.value * bonusMultiplier).round();
      if ((stats[entry.key] ?? 0) < required) return false;
    }

    // Stats máximos (o stat deve estar ABAIXO do valor)
    for (final entry in maxStatRequirements.entries) {
      if ((stats[entry.key] ?? 0) > entry.value) return false;
    }

    // Requisitos fixos (conquistas, sem multiplicador)
    for (final entry in fixedStatRequirements.entries) {
      if ((stats[entry.key] ?? 0) < entry.value) return false;
    }

    if (requiredAccessoryId != null && currentAccessory != requiredAccessoryId) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'form': currentForm.index,
      'level': levelRequired,
      'emoji': displayEmoji,
      'name': displayName,
    };
  }

  factory PetEvolution.fromForm(PetForm form) {
    switch (form) {
      case PetForm.baby:
        return PetEvolution(
          currentForm: form,
          levelRequired: 1,
          statRequirements: {},
          displayEmoji: '🐶',
          displayName: 'Filhote',
        );
      case PetForm.young:
        return PetEvolution(
          currentForm: form,
          levelRequired: 3,
          statRequirements: {'happiness': 40},
          displayEmoji: '🐕',
          displayName: 'Jovem',
        );
      case PetForm.adult:
        return PetEvolution(
          currentForm: form,
          levelRequired: 6,
          statRequirements: {'health': 60, 'happiness': 50},
          displayEmoji: '🦮',
          displayName: 'Adulto',
        );
      case PetForm.legendary:
        return PetEvolution(
          currentForm: form,
          levelRequired: 11,
          statRequirements: {'health': 80, 'happiness': 80, 'experience': 500},
          displayEmoji: '🦁',
          displayName: 'Lendário',
        );
      case PetForm.powerfulForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 8,
          statRequirements: {'health': 85},
          displayEmoji: '💪',
          displayName: 'Forma Poderosa',
        );
      case PetForm.happyForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 7,
          statRequirements: {'happiness': 90},
          displayEmoji: '😄',
          displayName: 'Forma Feliz',
        );
      case PetForm.smartForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 10,
          statRequirements: {'experience': 800},
          displayEmoji: '🧠',
          displayName: 'Forma Sábia',
        );
      case PetForm.ninjaForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 5,
          statRequirements: {},
          requiredAccessoryId: 'ninja_mask',
          displayEmoji: '🥷',
          displayName: 'Ninja',
        );
      case PetForm.robotForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 8,
          statRequirements: {},
          requiredAccessoryId: 'robot_suit',
          displayEmoji: '🤖',
          displayName: 'Robô',
        );
      case PetForm.alienForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 12,
          statRequirements: {},
          requiredAccessoryId: 'alien_helmet',
          displayEmoji: '👽',
          displayName: 'Alienígena',
        );

      // ── Formas por stats extremos ───────────────────────────────────────
      case PetForm.shadowForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 6,
          statRequirements: {},
          maxStatRequirements: {'happiness': 20},
          displayEmoji: '🌑',
          displayName: 'Forma Sombria',
        );
      case PetForm.athleteForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 9,
          statRequirements: {'health': 90, 'energy': 90},
          displayEmoji: '🏆',
          displayName: 'Forma Atleta',
        );
      case PetForm.hungryForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 4,
          statRequirements: {},
          fixedStatRequirements: {'hunger': 95},
          displayEmoji: '💀',
          displayName: 'Forma Faminta',
        );
      case PetForm.ghostForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 7,
          statRequirements: {},
          maxStatRequirements: {'health': 10},
          displayEmoji: '👻',
          displayName: 'Forma Fantasma',
        );

      // ── Formas por conquistas/progressão ──────────────────────────────
      case PetForm.gameMasterForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 9,
          statRequirements: {},
          fixedStatRequirements: {'gamesPlayed': 50},
          displayEmoji: '🎮',
          displayName: 'Mestre dos Games',
        );
      case PetForm.explorerForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 8,
          statRequirements: {},
          fixedStatRequirements: {'totalAdventures': 10},
          displayEmoji: '🧭',
          displayName: 'Explorador',
        );
      case PetForm.millionaireForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 10,
          statRequirements: {},
          fixedStatRequirements: {'coins': 500},
          displayEmoji: '💰',
          displayName: 'Milionário',
        );
      case PetForm.veteranForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 11,
          statRequirements: {},
          fixedStatRequirements: {'loginStreak': 30},
          displayEmoji: '🎖️',
          displayName: 'Veterano',
        );

      // ── Formas por novos acessórios ────────────────────────────────────
      case PetForm.wizardForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 5,
          statRequirements: {},
          requiredAccessoryId: 'wizard_hat',
          displayEmoji: '🧙',
          displayName: 'Mago',
        );
      case PetForm.samuraiForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 7,
          statRequirements: {},
          requiredAccessoryId: 'katana',
          displayEmoji: '⚔️',
          displayName: 'Samurai',
        );
      case PetForm.astronautForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 6,
          statRequirements: {},
          requiredAccessoryId: 'space_suit',
          displayEmoji: '👨‍🚀',
          displayName: 'Astronauta',
        );
      case PetForm.vampireForm:
        return PetEvolution(
          currentForm: form,
          levelRequired: 6,
          statRequirements: {},
          requiredAccessoryId: 'cape',
          displayEmoji: '🧛',
          displayName: 'Vampiro',
        );
    }
  }
}
