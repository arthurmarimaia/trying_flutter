import '../models/pet_evolution.dart';

// ── Reaction tiers ───────────────────────────────────────────────────────────

enum ReactionTier {
  positive, // increases happiness
  neutral,  // no effect
  negative, // decreases happiness
}

// ── Dialogue choice ──────────────────────────────────────────────────────────

class DialogueChoice {
  final String id;
  final String textPt;
  final String textEn;
  final ReactionTier tier;
  /// Happiness delta applied on pick.
  final int happinessDelta;
  /// Pet response after the player picks this choice.
  final String responsePt;
  final String responseEn;

  const DialogueChoice({
    required this.id,
    required this.textPt,
    required this.textEn,
    required this.tier,
    required this.happinessDelta,
    required this.responsePt,
    required this.responseEn,
  });
}

// ── Dialogue node ────────────────────────────────────────────────────────────

class DialogueNode {
  final String id;
  final String petTextPt;
  final String petTextEn;
  /// Always exactly 3 choices: positive, neutral, negative.
  final List<DialogueChoice> choices;

  const DialogueNode({
    required this.id,
    required this.petTextPt,
    required this.petTextEn,
    required this.choices,
  });
}

// ── Personality grouping ─────────────────────────────────────────────────────

enum PetPersonality {
  innocent,    // baby, young
  mature,      // adult, powerfulForm, athleteForm
  wise,        // legendary, smartForm, veteranForm
  cheerful,    // happyForm, gameMasterForm
  dark,        // shadowForm, ghostForm, vampireForm, hungryForm
  adventurous, // explorerForm, astronautForm, ninjaForm, samuraiForm
  quirky,      // robotForm, alienForm, wizardForm, millionaireForm
}

PetPersonality personalityFromForm(PetForm form) {
  switch (form) {
    case PetForm.baby:
    case PetForm.young:
      return PetPersonality.innocent;

    case PetForm.adult:
    case PetForm.powerfulForm:
    case PetForm.athleteForm:
      return PetPersonality.mature;

    case PetForm.legendary:
    case PetForm.smartForm:
    case PetForm.veteranForm:
      return PetPersonality.wise;

    case PetForm.happyForm:
    case PetForm.gameMasterForm:
      return PetPersonality.cheerful;

    case PetForm.shadowForm:
    case PetForm.ghostForm:
    case PetForm.vampireForm:
    case PetForm.hungryForm:
      return PetPersonality.dark;

    case PetForm.explorerForm:
    case PetForm.astronautForm:
    case PetForm.ninjaForm:
    case PetForm.samuraiForm:
      return PetPersonality.adventurous;

    case PetForm.robotForm:
    case PetForm.alienForm:
    case PetForm.wizardForm:
    case PetForm.millionaireForm:
      return PetPersonality.quirky;
  }
}

// ── Dialogue pool per personality ────────────────────────────────────────────

class PetDialoguePool {
  static DialogueNode pickForForm(PetForm form) {
    final personality = personalityFromForm(form);
    final pool = _dialogues[personality]!;
    final index = DateTime.now().millisecondsSinceEpoch % pool.length;
    return pool[index];
  }

  static const Map<PetPersonality, List<DialogueNode>> _dialogues = {
    // ═══════════════════════════════════════════════════════════════════════
    // INNOCENT (baby, young)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.innocent: [
      DialogueNode(
        id: 'inn_1',
        petTextPt: 'Oi oi oi! Você veio brincar comigo?? 🐾',
        petTextEn: 'Hi hi hi! Did you come to play with me?? 🐾',
        choices: [
          DialogueChoice(
            id: 'inn_1_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Claro! Vem cá, fofo!',
            textEn: "Of course! Come here, cutie!",
            responsePt: 'EBAAA! Você é o melhor! 🎉🎉',
            responseEn: 'YAAAY! You are the best! 🎉🎉',
          ),
          DialogueChoice(
            id: 'inn_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Só passei pra dar um oi.',
            textEn: 'Just came to say hi.',
            responsePt: 'Ah... tá bom então! Oi! 👋',
            responseEn: 'Oh... okay then! Hi! 👋',
          ),
          DialogueChoice(
            id: 'inn_1_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Agora não, tô ocupado.',
            textEn: "Not now, I'm busy.",
            responsePt: '... tá bom. 😢',
            responseEn: '... okay. 😢',
          ),
        ],
      ),
      DialogueNode(
        id: 'inn_2',
        petTextPt: 'Eu tive um sonho com borboletas! 🦋 Foi tão legal!',
        petTextEn: 'I had a dream about butterflies! 🦋 It was so cool!',
        choices: [
          DialogueChoice(
            id: 'inn_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Que lindo! Me conta mais!',
            textEn: 'How lovely! Tell me more!',
            responsePt: 'Tinham borboletas de todas as cores e a gente voava junto! ✨',
            responseEn: 'There were butterflies of every color and we flew together! ✨',
          ),
          DialogueChoice(
            id: 'inn_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Legal.',
            textEn: 'Cool.',
            responsePt: '...é, foi legal sim. 🙂',
            responseEn: '...yeah, it was cool. 🙂',
          ),
          DialogueChoice(
            id: 'inn_2_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Sonhos não são reais.',
            textEn: "Dreams aren't real.",
            responsePt: 'Mas... pareceu tão real... 🥺',
            responseEn: 'But... it felt so real... 🥺',
          ),
        ],
      ),
      DialogueNode(
        id: 'inn_3',
        petTextPt: 'Será que um dia eu vou ser grande e forte? 💭',
        petTextEn: 'Do you think one day I will be big and strong? 💭',
        choices: [
          DialogueChoice(
            id: 'inn_3_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Com certeza! Você vai ser incrível!',
            textEn: "Definitely! You're going to be amazing!",
            responsePt: 'Você acredita em mim?? Eu vou me esforçar! 💪😊',
            responseEn: 'You believe in me?? I will try my best! 💪😊',
          ),
          DialogueChoice(
            id: 'inn_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Depende de como você cuidar de si.',
            textEn: 'Depends on how you take care of yourself.',
            responsePt: 'Hmm... vou pensar nisso. 🤔',
            responseEn: 'Hmm... I will think about that. 🤔',
          ),
          DialogueChoice(
            id: 'inn_3_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Sei não, hein...',
            textEn: "I don't know about that...",
            responsePt: 'Ah... 😞',
            responseEn: 'Oh... 😞',
          ),
        ],
      ),
      DialogueNode(
        id: 'inn_4',
        petTextPt: 'Olha o que eu aprendi a fazer! *pula pra lá e pra cá* 🐰',
        petTextEn: 'Look what I learned to do! *jumps around* 🐰',
        choices: [
          DialogueChoice(
            id: 'inn_4_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Que demais! Você é super talentoso!',
            textEn: "That's awesome! You're so talented!",
            responsePt: 'Hehehe vou treinar mais! 🌟',
            responseEn: "Hehehe I'll practice more! 🌟",
          ),
          DialogueChoice(
            id: 'inn_4_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Cuidado pra não se machucar.',
            textEn: 'Be careful not to hurt yourself.',
            responsePt: 'Tá bom, vou tomar cuidado! 😅',
            responseEn: "Okay, I'll be careful! 😅",
          ),
          DialogueChoice(
            id: 'inn_4_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Para com isso, tá me irritando.',
            textEn: "Stop that, you're annoying me.",
            responsePt: '... desculpa. 😔',
            responseEn: '... sorry. 😔',
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // MATURE (adult, powerfulForm, athleteForm)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.mature: [
      DialogueNode(
        id: 'mat_1',
        petTextPt: 'Às vezes penso no que seria da minha vida sem você por perto.',
        petTextEn: 'Sometimes I think about what my life would be without you around.',
        choices: [
          DialogueChoice(
            id: 'mat_1_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Eu também não sei o que faria sem você.',
            textEn: "I don't know what I'd do without you either.",
            responsePt: 'Bom saber que a gente se importa um com o outro. 🤝',
            responseEn: "Good to know we care about each other. 🤝",
          ),
          DialogueChoice(
            id: 'mat_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'A vida segue, né.',
            textEn: 'Life goes on, right.',
            responsePt: 'É... tem razão. Mas é bom ter companhia.',
            responseEn: "Yeah... you're right. But company is nice.",
          ),
          DialogueChoice(
            id: 'mat_1_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Não pensa nisso, é bobagem.',
            textEn: "Don't think about that, it's nonsense.",
            responsePt: '... certo. Vou guardar pra mim.',
            responseEn: "... right. I'll keep it to myself.",
          ),
        ],
      ),
      DialogueNode(
        id: 'mat_2',
        petTextPt: 'Sinto que estou ficando mais forte a cada dia. 💪',
        petTextEn: 'I feel like I am getting stronger every day. 💪',
        choices: [
          DialogueChoice(
            id: 'mat_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Estou orgulhoso do seu progresso!',
            textEn: "I'm proud of your progress!",
            responsePt: 'Valeu! Eu vou continuar dando o meu melhor. 🔥',
            responseEn: "Thanks! I'll keep giving my best. 🔥",
          ),
          DialogueChoice(
            id: 'mat_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Bom pra você.',
            textEn: 'Good for you.',
            responsePt: '... obrigado, eu acho.',
            responseEn: '... thanks, I guess.',
          ),
          DialogueChoice(
            id: 'mat_2_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Ainda tem muito a melhorar.',
            textEn: 'You still have a lot to improve.',
            responsePt: '... eu sei. Não precisava lembrar.',
            responseEn: "... I know. Didn't need the reminder.",
          ),
        ],
      ),
      DialogueNode(
        id: 'mat_3',
        petTextPt: 'Treinar é importante, mas descansar também. Equilíbrio é tudo.',
        petTextEn: 'Training is important, but so is resting. Balance is everything.',
        choices: [
          DialogueChoice(
            id: 'mat_3_pos', tier: ReactionTier.positive, happinessDelta: 2,
            textPt: 'Você ficou sábio. Tem razão!',
            textEn: "You've become wise. You're right!",
            responsePt: 'Aprendi com a experiência. E com você. 😊',
            responseEn: 'I learned from experience. And from you. 😊',
          ),
          DialogueChoice(
            id: 'mat_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Faz sentido.',
            textEn: 'Makes sense.',
            responsePt: 'Né? Pois é.',
            responseEn: 'Right? Yeah.',
          ),
          DialogueChoice(
            id: 'mat_3_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Tá querendo enrolar pra não treinar?',
            textEn: 'Are you just trying to skip training?',
            responsePt: '... não. Deixa pra lá.',
            responseEn: '... no. Forget it.',
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // WISE (legendary, smartForm, veteranForm)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.wise: [
      DialogueNode(
        id: 'wis_1',
        petTextPt: 'Já percorri um longo caminho. Cada passo valeu a pena. 🌟',
        petTextEn: 'I have come a long way. Every step was worth it. 🌟',
        choices: [
          DialogueChoice(
            id: 'wis_1_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'E eu estive com você em cada um deles.',
            textEn: 'And I was with you in every one of them.',
            responsePt: 'Eu sei. E foi isso que fez toda a diferença. 💛',
            responseEn: 'I know. And that made all the difference. 💛',
          ),
          DialogueChoice(
            id: 'wis_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'É bom refletir de vez em quando.',
            textEn: "It's good to reflect once in a while.",
            responsePt: 'Com certeza. A reflexão nos fortalece.',
            responseEn: 'Indeed. Reflection makes us stronger.',
          ),
          DialogueChoice(
            id: 'wis_1_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Tá ficando nostálgico demais.',
            textEn: "You're getting too nostalgic.",
            responsePt: '... talvez. Mas memórias são preciosas.',
            responseEn: '... perhaps. But memories are precious.',
          ),
        ],
      ),
      DialogueNode(
        id: 'wis_2',
        petTextPt: 'O verdadeiro poder não está na força, mas na sabedoria de quando usá-la. 📖',
        petTextEn: 'True power is not in strength, but in the wisdom of when to use it. 📖',
        choices: [
          DialogueChoice(
            id: 'wis_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Profundo! Você me inspira.',
            textEn: 'Profound! You inspire me.',
            responsePt: 'Haha, obrigado. Aprendi com alguém especial. ✨',
            responseEn: 'Haha, thanks. I learned from someone special. ✨',
          ),
          DialogueChoice(
            id: 'wis_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Hmm, interessante.',
            textEn: 'Hmm, interesting.',
            responsePt: 'Pense nisso com calma quando puder.',
            responseEn: 'Think about it calmly when you can.',
          ),
          DialogueChoice(
            id: 'wis_2_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Lá vem você filosofando...',
            textEn: 'There you go philosophizing again...',
            responsePt: '... prefiro guardar meus pensamentos então.',
            responseEn: "... I'll keep my thoughts to myself then.",
          ),
        ],
      ),
      DialogueNode(
        id: 'wis_3',
        petTextPt: 'Sabe o que aprendi? Que cuidar e ser cuidado é a melhor recompensa. 🙏',
        petTextEn: 'You know what I learned? That caring and being cared for is the best reward. 🙏',
        choices: [
          DialogueChoice(
            id: 'wis_3_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Concordo totalmente. Você é especial pra mim.',
            textEn: "I totally agree. You're special to me.",
            responsePt: 'E você pra mim. Sempre. 💖',
            responseEn: 'And you to me. Always. 💖',
          ),
          DialogueChoice(
            id: 'wis_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Faz sentido, sim.',
            textEn: 'That makes sense.',
            responsePt: 'Fico feliz que não discorde, pelo menos. 😌',
            responseEn: "I'm glad you don't disagree, at least. 😌",
          ),
          DialogueChoice(
            id: 'wis_3_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Sei lá, moedas são melhores.',
            textEn: 'I dunno, coins are better.',
            responsePt: '... que triste ouvir isso. 😔',
            responseEn: "... that's sad to hear. 😔",
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // CHEERFUL (happyForm, gameMasterForm)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.cheerful: [
      DialogueNode(
        id: 'che_1',
        petTextPt: 'Hoje tá um dia MARAVILHOSO! Tudo é perfeito! 🌈🎶',
        petTextEn: "Today is a WONDERFUL day! Everything is perfect! 🌈🎶",
        choices: [
          DialogueChoice(
            id: 'che_1_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Sua energia é contagiante! Adoro!',
            textEn: 'Your energy is contagious! Love it!',
            responsePt: 'AAAA OBRIGADO! Vamos aproveitar juntos! 🎉💕',
            responseEn: "AAAA THANK YOU! Let's enjoy together! 🎉💕",
          ),
          DialogueChoice(
            id: 'che_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Que bom, aproveita.',
            textEn: 'Good for you, enjoy.',
            responsePt: 'Vou aproveitar sim! Hehe 😁',
            responseEn: "I sure will! Hehe 😁",
          ),
          DialogueChoice(
            id: 'che_1_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Calma, nem tá tudo isso.',
            textEn: "Chill, it's not all that.",
            responsePt: '... ah. Tá bom né. 😕',
            responseEn: '... oh. Okay then. 😕',
          ),
        ],
      ),
      DialogueNode(
        id: 'che_2',
        petTextPt: 'Bora jogar alguma coisa? Tô com vontade de me divertir! 🎮',
        petTextEn: "Let's play something? I feel like having fun! 🎮",
        choices: [
          DialogueChoice(
            id: 'che_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Bora! Vou escolher um minigame pra gente!',
            textEn: "Let's go! I'll pick a minigame for us!",
            responsePt: 'SIM! Mal posso esperar! 🕹️✨',
            responseEn: "YES! I can't wait! 🕹️✨",
          ),
          DialogueChoice(
            id: 'che_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Talvez mais tarde.',
            textEn: 'Maybe later.',
            responsePt: 'Hmm ok, vou esperar então! 😊',
            responseEn: "Hmm ok, I'll wait then! 😊",
          ),
          DialogueChoice(
            id: 'che_2_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Não, sem jogos agora.',
            textEn: 'No, no games right now.',
            responsePt: 'Ahhh... 😩',
            responseEn: 'Awww... 😩',
          ),
        ],
      ),
      DialogueNode(
        id: 'che_3',
        petTextPt: 'Sabia que você é a pessoa mais legal que eu conheço? 🥹',
        petTextEn: 'Did you know you are the coolest person I know? 🥹',
        choices: [
          DialogueChoice(
            id: 'che_3_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'E você é o pet mais incrível!',
            textEn: "And you're the most amazing pet!",
            responsePt: 'A gente é uma dupla perfeita! 🤩💖',
            responseEn: "We're the perfect duo! 🤩💖",
          ),
          DialogueChoice(
            id: 'che_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Obrigado, eu acho.',
            textEn: 'Thanks, I guess.',
            responsePt: 'Hehe, é um elogio de verdade! 😄',
            responseEn: "Hehe, it's a real compliment! 😄",
          ),
          DialogueChoice(
            id: 'che_3_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Você não conhece muita gente, né?',
            textEn: "You don't know many people, do you?",
            responsePt: '... ai. Isso doeu. 😣',
            responseEn: '... ouch. That hurt. 😣',
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // DARK (shadowForm, ghostForm, vampireForm, hungryForm)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.dark: [
      DialogueNode(
        id: 'drk_1',
        petTextPt: '... às vezes me pergunto se alguém realmente se importa. 🌑',
        petTextEn: '... sometimes I wonder if anyone truly cares. 🌑',
        choices: [
          DialogueChoice(
            id: 'drk_1_pos', tier: ReactionTier.positive, happinessDelta: 4,
            textPt: 'Eu me importo. Estou aqui por você, sempre.',
            textEn: "I care. I'm here for you, always.",
            responsePt: '... obrigado. Fazia tempo que ninguém dizia isso. 🖤',
            responseEn: "... thank you. It's been a while since someone said that. 🖤",
          ),
          DialogueChoice(
            id: 'drk_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Todo mundo tem esses pensamentos.',
            textEn: 'Everyone has those thoughts.',
            responsePt: '... talvez. Mas poucos admitem.',
            responseEn: '... maybe. But few admit it.',
          ),
          DialogueChoice(
            id: 'drk_1_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Para de drama.',
            textEn: 'Stop being dramatic.',
            responsePt: '... como eu imaginava. Ninguém se importa.',
            responseEn: '... as I expected. Nobody cares.',
          ),
        ],
      ),
      DialogueNode(
        id: 'drk_2',
        petTextPt: 'A escuridão não é ruim. É só... silenciosa. 🌘',
        petTextEn: "Darkness isn't bad. It's just... quiet. 🌘",
        choices: [
          DialogueChoice(
            id: 'drk_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Eu entendo. Posso fazer silêncio com você.',
            textEn: 'I understand. I can be quiet with you.',
            responsePt: '... isso significa mais do que você imagina. 🤍',
            responseEn: '... that means more than you imagine. 🤍',
          ),
          DialogueChoice(
            id: 'drk_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Cada um lida do seu jeito.',
            textEn: 'Everyone copes in their own way.',
            responsePt: '... sim. É exatamente isso.',
            responseEn: '... yes. Exactly.',
          ),
          DialogueChoice(
            id: 'drk_2_neg', tier: ReactionTier.negative, happinessDelta: -3,
            textPt: 'Que papo estranho.',
            textEn: 'What a weird thing to say.',
            responsePt: '... esqueça que eu falei.',
            responseEn: '... forget I said anything.',
          ),
        ],
      ),
      DialogueNode(
        id: 'drk_3',
        petTextPt: 'Você não tem medo de mim? A maioria teria. 👁️',
        petTextEn: "Aren't you afraid of me? Most would be. 👁️",
        choices: [
          DialogueChoice(
            id: 'drk_3_pos', tier: ReactionTier.positive, happinessDelta: 4,
            textPt: 'Nunca. Eu te conheço de verdade.',
            textEn: 'Never. I know the real you.',
            responsePt: '... ninguém nunca disse isso antes. 🥀💜',
            responseEn: '... nobody has ever said that before. 🥀💜',
          ),
          DialogueChoice(
            id: 'drk_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Você é diferente, mas não assustador.',
            textEn: "You're different, but not scary.",
            responsePt: '... diferente. Sim, acho que é a melhor palavra.',
            responseEn: "... different. Yes, I guess that's the right word.",
          ),
          DialogueChoice(
            id: 'drk_3_neg', tier: ReactionTier.negative, happinessDelta: -4,
            textPt: 'Um pouco, pra ser sincero.',
            textEn: 'A little, to be honest.',
            responsePt: '... eu sabia. 🖤',
            responseEn: '... I knew it. 🖤',
          ),
        ],
      ),
      DialogueNode(
        id: 'drk_4',
        petTextPt: 'Eu não preciso de luz pra brilhar. Eu sou minha própria luz. 🔮',
        petTextEn: "I don't need light to shine. I am my own light. 🔮",
        choices: [
          DialogueChoice(
            id: 'drk_4_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Isso foi poético. Você é especial.',
            textEn: "That was poetic. You're special.",
            responsePt: '... hm. Obrigado. De verdade. 💫',
            responseEn: '... hm. Thank you. Truly. 💫',
          ),
          DialogueChoice(
            id: 'drk_4_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Bonita frase.',
            textEn: 'Nice phrase.',
            responsePt: '... não é uma frase. É o que eu sinto.',
            responseEn: "... it's not a phrase. It's what I feel.",
          ),
          DialogueChoice(
            id: 'drk_4_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Tá, tanto faz.',
            textEn: 'Yeah, whatever.',
            responsePt: '...',
            responseEn: '...',
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // ADVENTUROUS (explorerForm, astronautForm, ninjaForm, samuraiForm)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.adventurous: [
      DialogueNode(
        id: 'adv_1',
        petTextPt: 'Sinto que tem algo incrível nos esperando lá fora! 🗺️',
        petTextEn: 'I feel like something amazing is waiting for us out there! 🗺️',
        choices: [
          DialogueChoice(
            id: 'adv_1_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Então vamos descobrir juntos!',
            textEn: "Then let's find out together!",
            responsePt: 'SIM! Parceiro de aventuras! Bora! 🚀',
            responseEn: "YES! Adventure partner! Let's go! 🚀",
          ),
          DialogueChoice(
            id: 'adv_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Pode ser, quem sabe.',
            textEn: 'Maybe, who knows.',
            responsePt: 'Hmm, seria legal se você quisesse ir comigo.',
            responseEn: "Hmm, it'd be cool if you wanted to come with me.",
          ),
          DialogueChoice(
            id: 'adv_1_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Melhor ficar por aqui mesmo.',
            textEn: "Better stay right here.",
            responsePt: 'Ah... tá bom. *olha pro horizonte* 😔',
            responseEn: 'Oh... okay. *looks at the horizon* 😔',
          ),
        ],
      ),
      DialogueNode(
        id: 'adv_2',
        petTextPt: 'Fui treinar de manhã cedo. O sol nascendo era lindo! 🌅',
        petTextEn: 'I trained early this morning. The sunrise was beautiful! 🌅',
        choices: [
          DialogueChoice(
            id: 'adv_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Quero ver o próximo nascer do sol com você!',
            textEn: 'I want to watch the next sunrise with you!',
            responsePt: 'Sério?? Vai ser incrível! ☀️💛',
            responseEn: "Really?? It'll be amazing! ☀️💛",
          ),
          DialogueChoice(
            id: 'adv_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Legal, continue treinando.',
            textEn: 'Cool, keep training.',
            responsePt: 'Pode deixar! 💪',
            responseEn: 'You got it! 💪',
          ),
          DialogueChoice(
            id: 'adv_2_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'De manhã cedo? Que preguiça disso.',
            textEn: 'Early morning? Sounds lazy-inducing.',
            responsePt: '... você não vê beleza em nada? 😑',
            responseEn: "... don't you see beauty in anything? 😑",
          ),
        ],
      ),
      DialogueNode(
        id: 'adv_3',
        petTextPt: 'Um verdadeiro guerreiro nunca desiste. Eu nunca vou desistir! ⚔️',
        petTextEn: 'A true warrior never gives up. I will never give up! ⚔️',
        choices: [
          DialogueChoice(
            id: 'adv_3_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Essa determinação é admirável!',
            textEn: 'That determination is admirable!',
            responsePt: 'Obrigado! Você me dá forças! 🔥',
            responseEn: 'Thank you! You give me strength! 🔥',
          ),
          DialogueChoice(
            id: 'adv_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Cuidado pra não se machucar.',
            textEn: "Don't overdo it though.",
            responsePt: 'Eu sei meus limites. Mas obrigado pela preocupação.',
            responseEn: 'I know my limits. But thanks for caring.',
          ),
          DialogueChoice(
            id: 'adv_3_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Que exagerado.',
            textEn: 'So overdramatic.',
            responsePt: '... não é exagero. É convicção. 😤',
            responseEn: "... it's not drama. It's conviction. 😤",
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════════
    // QUIRKY (robotForm, alienForm, wizardForm, millionaireForm)
    // ═══════════════════════════════════════════════════════════════════════
    PetPersonality.quirky: [
      DialogueNode(
        id: 'qrk_1',
        petTextPt: 'ANÁLISE COMPLETA: probabilidade de diversão hoje = 97.3%! 🤖',
        petTextEn: 'ANALYSIS COMPLETE: probability of fun today = 97.3%! 🤖',
        choices: [
          DialogueChoice(
            id: 'qrk_1_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Hahaha adoro quando você faz isso!',
            textEn: 'Hahaha I love when you do that!',
            responsePt: 'SATISFAÇÃO DO USUÁRIO: MÁXIMA ✅ *bip bip* 😊',
            responseEn: 'USER SATISFACTION: MAXIMUM ✅ *beep boop* 😊',
          ),
          DialogueChoice(
            id: 'qrk_1_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'De onde você tira esses números?',
            textEn: 'Where do you get those numbers?',
            responsePt: 'Fonte: confie em mim. 📊',
            responseEn: 'Source: trust me. 📊',
          ),
          DialogueChoice(
            id: 'qrk_1_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Isso é meio irritante.',
            textEn: "That's kind of annoying.",
            responsePt: 'ERRO 404: MOTIVAÇÃO NÃO ENCONTRADA. 😔',
            responseEn: 'ERROR 404: MOTIVATION NOT FOUND. 😔',
          ),
        ],
      ),
      DialogueNode(
        id: 'qrk_2',
        petTextPt: 'Eu tava pensando... e se a gente vivesse em outra dimensão? 🌀',
        petTextEn: 'I was thinking... what if we lived in another dimension? 🌀',
        choices: [
          DialogueChoice(
            id: 'qrk_2_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Ia ser muito louco! Conta mais!',
            textEn: "That'd be crazy! Tell me more!",
            responsePt: 'A gente podia voar e as cores seriam ao contrário! 🎨✨',
            responseEn: 'We could fly and colors would be reversed! 🎨✨',
          ),
          DialogueChoice(
            id: 'qrk_2_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Quem sabe, né.',
            textEn: 'Who knows, right.',
            responsePt: 'Hehe, é bom imaginar de vez em quando. 💭',
            responseEn: "Hehe, it's good to imagine sometimes. 💭",
          ),
          DialogueChoice(
            id: 'qrk_2_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Que ideia aleatória.',
            textEn: 'What a random idea.',
            responsePt: '... aleatório é o meu estilo. Mas ok. 😞',
            responseEn: "... random's my style. But ok. 😞",
          ),
        ],
      ),
      DialogueNode(
        id: 'qrk_3',
        petTextPt: 'Sabia que se eu tivesse 1 moeda pra cada vez que pensei em algo estranho, eu seria milionário? 💰',
        petTextEn: 'Did you know that if I had 1 coin for every weird thought, I would be a millionaire? 💰',
        choices: [
          DialogueChoice(
            id: 'qrk_3_pos', tier: ReactionTier.positive, happinessDelta: 3,
            textPt: 'Hahaha! Seus pensamentos estranhos são o melhor!',
            textEn: 'Hahaha! Your weird thoughts are the best!',
            responsePt: 'FINALMENTE alguém que me entende! 🤪💖',
            responseEn: 'FINALLY someone who gets me! 🤪💖',
          ),
          DialogueChoice(
            id: 'qrk_3_neu', tier: ReactionTier.neutral, happinessDelta: 0,
            textPt: 'Provavelmente, sim.',
            textEn: 'Probably, yeah.',
            responsePt: 'Né? Eu tenho muitos pensamentos! 🧠',
            responseEn: 'Right? I have so many thoughts! 🧠',
          ),
          DialogueChoice(
            id: 'qrk_3_neg', tier: ReactionTier.negative, happinessDelta: -2,
            textPt: 'Ninguém pediu pra saber disso.',
            textEn: 'Nobody asked for that info.',
            responsePt: '... eu só queria conversar. 😢',
            responseEn: '... I just wanted to chat. 😢',
          ),
        ],
      ),
    ],
  };
}
