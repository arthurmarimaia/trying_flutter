import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_evolution.dart';

/// Supported locales.
enum AppLocale { pt, en }

/// Global locale controller. Add to the root ChangeNotifierProvider so it is
/// available before and after login.
class LocaleController extends ChangeNotifier {
  static const _key = 'app_locale';

  AppLocale _locale = AppLocale.pt;
  AppLocale get locale => _locale;

  bool get isEn => _locale == AppLocale.en;
  bool get isPt => _locale == AppLocale.pt;

  /// Shorthand: `context.watch<LocaleController>().s.someKey`
  AppStrings get s => AppStrings(_locale);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'en') _locale = AppLocale.en;
    notifyListeners();
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale == AppLocale.en ? 'en' : 'pt');
  }

  void toggle() =>
      setLocale(_locale == AppLocale.pt ? AppLocale.en : AppLocale.pt);
}

/// All UI strings for the app in PT-BR and EN.
class AppStrings {
  final AppLocale _locale;
  const AppStrings(this._locale);
  bool get _en => _locale == AppLocale.en;

  // ── Common ──────────────────────────────────────────────────────────────────
  String get cancel  => _en ? 'Cancel'  : 'Cancelar';
  String get confirm => _en ? 'Confirm' : 'Confirmar';
  String get save    => _en ? 'Save'    : 'Salvar';
  String get close   => _en ? 'Close'   : 'Fechar';
  String get back    => _en ? 'Back'    : 'Voltar';
  String get ok      => 'OK';
  String get yes     => _en ? 'Yes'     : 'Sim';
  String get no      => _en ? 'No'      : 'Não';
  String get error   => _en ? 'Error'   : 'Erro';
  String get success => _en ? 'Success' : 'Sucesso';

  // ── Language picker ──────────────────────────────────────────────────────────
  String get languageLabel   => _en ? 'Language'            : 'Idioma';
  String get languagePt      => 'Português (BR)';
  String get languageEn      => 'English';
  String get languageCurrent => _en ? languageEn : languagePt;

  // ── Profile selection screen ───────────────────────────────────────────────
  String get profileSelectSubtitle => _en ? 'Choose a profile to play'        : 'Escolha um perfil para jogar';
  String get profileCreateBtn     => _en ? 'New profile'                      : 'Novo perfil';
  String get profileCreateTitle   => _en ? 'Create profile'                   : 'Criar perfil';
  String get profileChooseAvatar  => _en ? 'Choose an avatar'                 : 'Escolha um avatar';
  String get profileNameLabel     => _en ? 'Profile name'                     : 'Nome do perfil';
  String get profilePlayerNameHint => _en ? 'e.g. john'                        : 'ex: joao';
  String get profileDeleteTitle   => _en ? 'Delete profile?'                  : 'Excluir perfil?';
  String get profileDeleteContent => _en ? 'All progress for this profile will be permanently deleted.' : 'Todo o progresso deste perfil será excluído permanentemente.';
  String get profileDeleteBtn     => _en ? 'Delete'                           : 'Excluir';
  String get fieldUsername    => _en ? 'Username'    : 'Nome de usuário';
  String get fieldUserHint    => _en ? 'e.g. john_doe' : 'ex: joao_silva';
  String get validUserEmpty   => _en ? 'Enter a name'             : 'Informe o nome';
  String get validUserMin     => _en ? 'Minimum 3 characters'     : 'Mínimo 3 caracteres';

  // ── Settings screen ──────────────────────────────────────────────────────────
  String get settingsTitle          => _en ? 'Settings ⚙️'     : 'Configurações ⚙️';
  String get settingsNotifTitle     => _en ? 'Smart pet reminders' : 'Lembretes inteligentes do pet';
  String get settingsNotifSubtitle  => _en ? 'Get notified when your pet needs attention or quests are complete.' : 'Receba notificações quando o pet precisar de atenção ou missões estiverem completas.';
  String get settingsBackupSection  => _en ? 'Backup & Restore'  : 'Backup e Restauração';
  String get settingsExportTitle    => _en ? 'Export data'       : 'Exportar dados';
  String get settingsExportSubtitle => _en ? 'Copies a JSON with all your data to the clipboard.' : 'Copia um JSON com todos os seus dados para a área de transferência.';
  String get settingsImportTitle    => _en ? 'Import backup'     : 'Importar backup';
  String get settingsImportSubtitle => _en ? 'Paste a backup JSON to restore your data.' : 'Cole um JSON de backup para restaurar seus dados.';
  String get settingsExportDone     => _en ? 'Backup copied to clipboard!' : 'Backup copiado para a área de transferência!';
  String get settingsImportDialogTitle   => _en ? 'Import Backup' : 'Importar Backup';
  String get settingsImportDialogBody    => _en ? 'Paste the backup JSON below. Warning: all current data will be replaced.' : 'Cole o JSON do backup abaixo. Atenção: todos os dados atuais serão substituídos.';
  String get settingsImportHint          => _en ? 'Paste JSON here...' : 'Cole o JSON aqui...';
  String get settingsImportSuccess       => _en ? 'Data restored successfully! ✅' : 'Dados restaurados com sucesso! ✅';
  String get settingsLanguageSection     => _en ? 'Language'      : 'Idioma';
  String get settingsLanguageSubtitle    => _en ? 'Choose your preferred language' : 'Escolha o idioma preferido';

  // ── Onboarding screen ───────────────────────────────────────────────────────
  String get onboardingTitle       => _en ? 'Welcome!'              : 'Bem-vindo!';
  String get onboardingSubtitle    => _en ? 'Choose your virtual companion' : 'Escolha o seu companheiro virtual';
  String get onboardingNameLabel   => _en ? 'Pet name (optional)'   : 'Nome do seu pet (opcional)';
  String get onboardingNameHint    => _en ? 'E.g.: Rex, Luna, Bub...' : 'Ex: Rex, Luna, Bolha...';
  String get onboardingStartBtn    => _en ? 'Start adventure!'      : 'Começar aventura!';
  String get onboardingCanineName  => _en ? 'Canine'    : 'Canino';
  String get onboardingCaninoDesc  => _en ? 'Loyal and loving'      : 'Leal e carinhoso';
  String get onboardingReptilName  => _en ? 'Reptile'   : 'Reptil';
  String get onboardingReptilDesc  => _en ? 'Mysterious and strong' : 'Misterioso e forte';
  String get onboardingSlimeName   => _en ? 'Slime'     : 'Slime';
  String get onboardingSlimeDesc   => _en ? 'Fun and unique'        : 'Divertido e único';

  // ── Home screen — action buttons ────────────────────────────────────────────
  String get actionFeed    => _en ? 'Feed'    : 'Alimentar';
  String get actionSleep   => _en ? 'Sleep'   : 'Dormir';
  String get actionPlay    => _en ? 'Play'    : 'Brincar';
  String get actionClean   => _en ? 'Clean'   : 'Limpar';
  String get actionHeal    => _en ? 'Medicate': 'Medicar';
  String get actionTrain   => _en ? 'Train'   : 'Treinar';
  String get actionCuddle  => _en ? 'Cuddle'  : 'Carinho';
  String get actionTalk    => _en ? 'Talk'    : 'Conversar';

  // ── Dialogue screen ──────────────────────────────────────────────────────────
  String get dialogueTitle => _en ? 'Chat with your pet' : 'Conversar com o pet';
  String get dialogueBack  => _en ? 'Go back' : 'Voltar';

  // ── Home screen — status bars ────────────────────────────────────────────────
  String get statHealth    => _en ? 'Health'   : 'Saúde';
  String get statHunger    => _en ? 'Satiety'  : 'Saciedade';
  String get statEnergy    => _en ? 'Energy'   : 'Energia';
  String get statHappiness => _en ? 'Mood'     : 'Humor';
  String get statHygiene   => _en ? 'Hygiene'  : 'Higiene';

  // ── Home screen — toy console status labels ──────────────────────────────────
  String get toyHumor  => _en ? 'Mood'    : 'Humor';
  String get toyFome   => _en ? 'Hunger'  : 'Fome';
  String get toySaude  => _en ? 'Health'  : 'Saúde';

  // ── Home screen — nav / misc ─────────────────────────────────────────────────
  String get homeDefaultName    => _en ? 'Tamagotchi' : 'Tamagotchi';
  String get homeFaintedTitle   => _en ? 'Your pet fainted...' : 'Seu pet desmaiou...';
  String get homeFaintedBody    => _en ? 'It needs care to come back.' : 'Ele precisa de cuidados para voltar.';
  String get homeReviveBtn      => _en ? 'Revive'    : 'Reviver';
  String get homeInventoryEmpty => _en ? 'Empty inventory' : 'Inventário vazio';
  String get homeDailyBonus     => _en ? 'Daily Bonus'     : 'Bônus Diário';
  String get homeHistory        => _en ? 'History'         : 'Histórico';
  String get homeProfile        => _en ? 'Profile'         : 'Perfil';
  String get homeMissions       => _en ? 'Missions'        : 'Missões';
  String get homeStore          => _en ? 'Store'           : 'Loja';
  String get homeMinigames      => _en ? 'Minigames'       : 'Minijogos';
  String get homeEvolution      => _en ? 'Evolution'       : 'Evolução';
  String get homeAdventure      => _en ? 'Adventure'       : 'Aventura';
  String get homeAchievements   => _en ? 'Achievements'    : 'Conquistas';
  String get homeInventory      => _en ? 'Inventory'       : 'Inventário';

  // ── Store screen ─────────────────────────────────────────────────────────────
  String get storeTitle        => _en ? 'Store'     : 'Loja';
  String get storeDailyOffers  => _en ? 'Daily Offers' : 'Ofertas do Dia';
  String get storeAllItems     => _en ? 'All Items' : 'Todos os Itens';
  String get storeBuy          => _en ? 'Buy'       : 'Comprar';
  String get storeEquip        => _en ? 'Equip'     : 'Equipar';
  String get storeEquipped     => _en ? 'Equipped'  : 'Equipado';
  String get storeOwned        => _en ? 'Owned'     : 'Possui';
  String get storeNotEnough    => _en ? 'Not enough coins' : 'Moedas insuficientes';
  String get storeCoins        => _en ? 'coins'     : 'moedas';

  // ── Achievements screen ───────────────────────────────────────────────────────
  String get achievementsTitle  => _en ? 'Achievements' : 'Conquistas';
  String get achievementLocked  => _en ? 'Locked'       : 'Bloqueado';

  // ── Minigames screen ──────────────────────────────────────────────────────────
  String get minigamesTitle     => _en ? 'Minigames'    : 'Minijogos';
  String get minigamePlay       => _en ? 'Play'         : 'Jogar';
  String get minigameHighScore  => _en ? 'Best'         : 'Melhor';

  // ── Daily quests screen ───────────────────────────────────────────────────────
  String get questsTitle        => _en ? 'Daily Missions' : 'Missões Diárias';
  String get questComplete      => _en ? 'Complete'     : 'Completa';
  String get questProgress      => _en ? 'In progress'  : 'Em andamento';
  String get questClaim         => _en ? 'Claim reward' : 'Resgatar';

  // ── Evolution screen ──────────────────────────────────────────────────────────
  String get evolutionTitle     => _en ? 'Evolution'    : 'Evolução';
  String get evolutionCurrent   => _en ? 'Current stage': 'Estágio atual';
  String get evolutionNext      => _en ? 'Next stage'   : 'Próximo estágio';

  // ── Adventure screen ─────────────────────────────────────────────────────────
  String get adventureTitle     => _en ? 'Adventure'    : 'Aventura';
  String get adventureStart     => _en ? 'Start'        : 'Iniciar';
  String get adventureInProgress => _en ? 'In progress' : 'Em andamento';
  String get adventureComplete  => _en ? 'Complete!'    : 'Completa!';
  String get adventureClaim     => _en ? 'Collect reward' : 'Coletar recompensa';

  // ── Pet profile screen ────────────────────────────────────────────────────────
  String get profileTitle       => _en ? 'Profile'      : 'Perfil';
  String get profileLevel       => _en ? 'Level'        : 'Nível';
  String get profileStage       => _en ? 'Stage'        : 'Estágio';
  String get profileBond        => _en ? 'Bond'         : 'Vínculo';
  String get profileTitles      => _en ? 'Titles'       : 'Títulos';
  String get profileSeeAll      => _en ? 'See all'      : 'Ver todos';

  // ── Inventory screen ──────────────────────────────────────────────────────────
  String get inventoryTitle     => _en ? 'Inventory'    : 'Inventário';
  String get inventoryUse       => _en ? 'Use'          : 'Usar';
  String get inventoryEmpty     => _en ? 'Your inventory is empty.' : 'Seu inventário está vazio.';

  // ── History screen ────────────────────────────────────────────────────────────
  String get historyTitle       => _en ? 'History'      : 'Histórico';
  String get historyEmpty       => _en ? 'No records yet.' : 'Nenhum registro ainda.';
  String get historyNoDataYet   => _en ? 'No data yet.\nCome back tomorrow to see history!' : 'Nenhum dado ainda.\nVolte amanhã para ver o histórico!';
  String get historyDetails     => _en ? 'Details'      : 'Detalhes';
  String get historyToday       => _en ? 'Today'        : 'Hoje';
  String get historyYesterday   => _en ? 'Yesterday'    : 'Ontem';
  String get historyDaysAgo     => _en ? 'days ago'     : 'dias atrás';

  // ── Minigames screen ──────────────────────────────────────────────────────────
  String get mgTitle            => 'Mini-Games 🎮';
  String get mgStatsHeader      => _en ? '📊 My Stats'              : '📊 Suas Estatísticas';
  String get mgGamesLabel       => _en ? 'Games'                    : 'Jogos';
  String get mgDifficulty       => _en ? 'Difficulty Level'         : 'Nível de Dificuldade';
  String get mgEasy             => _en ? 'Easy'                     : 'Fácil';
  String get mgNormal           => 'Normal';
  String get mgHard             => _en ? 'Hard'                     : 'Difícil';
  String get mgChooseGame       => _en ? 'Choose a Game'            : 'Escolha um Jogo';
  String get mgMemoryTitle      => _en ? 'Memory Game'              : 'Jogo da Memória';
  String get mgMemoryDesc       => _en ? 'Find the card pairs!'     : 'Encontre os pares de cartas!';
  String get mgSpeedTitle       => _en ? 'Speed Game'               : 'Jogo de Velocidade';
  String get mgSpeedDesc        => _en ? 'Click the right button!'  : 'Clique no botão certo!';
  String get mgJumpTitle        => _en ? 'Jump Game'                : 'Jogo de Salto';
  String get mgJumpDesc         => _en ? 'Jump across platforms!'   : 'Pule de plataforma em plataforma!';
  String get mgReactionTitle    => _en ? 'Quick Tap'                : 'Tap Rápido';
  String get mgReactionDesc     => _en ? 'Tap targets before they vanish!' : 'Toque nos alvos antes que somam!';
  String get mgBestPrefix       => _en ? 'Best'                     : 'Melhor';
  String get mgBonusMultiplier  => _en ? 'Minigame bonus'           : 'Bônus de minigame';
  // Sub-screen results
  String get mgPlatformsJumped  => _en ? 'Platforms jumped'         : 'Plataformas puladas';
  String get mgMovesLabel       => _en ? 'Moves'                    : 'Movimentos';
  String get mgTimeLabel        => _en ? 'Time'                     : 'Tempo';
  String get mgCorrectClicks    => _en ? 'Correct clicks'           : 'Cliques corretos';
  String get mgLevelReached     => _en ? 'Level reached'            : 'Nível alcançado';
  String get mgHappinessLabel   => _en ? '😊 Happiness'             : '😊 Felicidade';
  String get mgCoinsLabel       => _en ? '💰 Coins'                  : '💰 Moedas';
  String get mgTimeUp           => _en ? '⏱️ Time\'s Up!'           : '⏱️ Tempo Esgotado!';
  String get mgGameEndTitle     => _en ? '⚡ Game Over!'             : '⚡ Fim de Jogo!';
  String get mgScoreLabel       => _en ? 'Score'                    : 'Pontuação';
  String get mgEscapedLabel     => _en ? '💨 Escaped'               : '💨 Escaparam';
  String get mgCongrats          => _en ? '🎉 Well done!'         : '🎉 Parabéns!';
  String get mgContinue          => _en ? 'Continue'                 : 'Continuar';
  String get mgReactionAppBar   => _en ? 'Quick Tap ⚡'             : 'Tap Rápido ⚡';

  // ── Evolution screen ──────────────────────────────────────────────────────────
  String get evoCurrentForm         => _en ? 'Current Form'         : 'Forma Atual';
  String get evoYourStats           => _en ? 'Your Stats'           : 'Suas Estatísticas';
  String get evoAvailableForms      => _en ? 'Available Forms'      : 'Formas Disponíveis';
  String get evoRequirementsNotMet  => _en ? 'Requirements not met:': 'Requisitos não atendidos:';
  String get evoCurrentFormCheck    => _en ? 'Current form ✓'       : 'Forma atual ✓';
  String get evoReadyToEvolve       => _en ? 'Ready to evolve!'     : 'Pronto para evoluir!';
  String get evoCelebrationText     => _en ? 'Evolution complete!'  : 'Evolução completa!';
  String get evoEvolvedTo           => _en ? 'Evolved to'           : 'Evoluiu para';
  // Stat labels used in requirements list
  String get evoStatHealth          => _en ? 'Health'               : 'Saúde';
  String get evoStatHappiness       => _en ? 'Happiness'            : 'Felicidade';
  String get evoStatEnergy          => _en ? 'Energy'               : 'Energia';
  String get evoStatHunger          => _en ? 'Hunger'               : 'Fome';
  String get evoStatExperience      => _en ? 'Experience'           : 'Experiência';
  String get evoStatStrength        => _en ? 'Strength'             : 'Força';
  String get evoStatGamesPlayed     => _en ? 'Minigames played'     : 'Minigames jogados';
  String get evoStatAdventures      => _en ? 'Adventures completed' : 'Aventuras completas';
  String get evoStatCoins           => _en ? 'Coins'                : 'Moedas';
  String get evoStatLoginStreak     => _en ? 'Login streak'         : 'Dias seguidos';
  String get evoStatLevel           => _en ? 'Level'                : 'Nível';
  String get evoCurrentLabel        => _en ? 'current'              : 'atual';

  // ── Adventure screen ─────────────────────────────────────────────────────────
  String get advChooseAdventure     => _en ? 'Choose an Adventure'  : 'Escolha uma Aventura';
  String get advHistory             => _en ? 'Adventure History'    : 'Histórico de Aventuras';
  String get advInProgress          => _en ? 'Adventure in progress!': 'Aventura em andamento!';
  String get advTimeRemaining       => _en ? 'Time remaining'       : 'Tempo restante';
  String get advPossibleRewards     => _en ? 'Possible Rewards:'    : 'Possíveis Prêmios:';
  String get advTreasure            => _en ? 'Treasure'             : 'Tesouro';
  String get advItems               => _en ? 'Items'                : 'Itens';

  // ── Pet profile screen ────────────────────────────────────────────────────────
  String get profileNoName          => _en ? '(no name)'            : '(sem nome)';
  String get profileRenameTitle     => _en ? 'Rename Pet'           : 'Renomear Pet';
  String get profileRenameTooltip   => _en ? 'Rename pet'           : 'Renomear pet';
  String get profileNameHint        => _en ? "Your pet's name"      : 'Nome do seu pet';
  String get profileChooseTitle     => _en ? 'Choose Title'         : 'Escolher Título';
  String get profileStatsSection    => _en ? 'Stats'                : 'Estatísticas';
  String get profileStatusSection   => _en ? 'Current Status'       : 'Status Atual';
  String get profileAccessorySection => _en ? 'Accessory'           : 'Acessório';
  String get profileNoAccessory     => _en ? 'None equipped'        : 'Nenhum equipado';
  String get profileViewFull        => _en ? 'View full'            : 'Ver completo';
  String get profileDaysAlive       => _en ? 'Days alive'           : 'Dias vivo';
  String get profileStreak          => _en ? 'Current streak'       : 'Sequência atual';
  String get profileHealthHistory   => _en ? 'Health History'       : 'Histórico de Saúde';
  String get profileStatHealth      => _en ? '❤️ Health'             : '❤️ Saúde';
  String get profileStatSatiety     => _en ? '🍖 Satiety'           : '🍖 Saciedade';
  String get profileStatHappiness   => _en ? '😊 Happiness'          : '😊 Felicidade';
  String get profileStatEnergy      => _en ? '⚡ Energy'             : '⚡ Energia';
  String get profileBondStranger    => _en ? 'Stranger'             : 'Estranho';
  String get profileBondAcquaintance => _en ? 'Acquaintance'        : 'Conhecido';
  String get profileBondFriend      => _en ? 'Friend'               : 'Amigo';
  String get profileBondClose       => _en ? 'Close'                : 'Íntimo';
  String get profileBondSoulmate    => _en ? 'Soul\nMate'           : 'Alma\nGêmea';

  // ── Home screen — extended labels ───────────────────────────────────────────
  String get homeLastInteraction    => _en ? 'Last interaction'              : 'Última interação';
  String get homeDailyEvent         => _en ? 'Daily event'                   : 'Evento do dia';
  String get homeCoinsLabel         => _en ? 'Coins'                         : 'Moedas';
  String get homeBondLabel          => _en ? 'Bond'                          : 'Vínculo';
  String get homeDailyGoalsLabel    => _en ? 'Daily Goals'                   : 'Metas diárias';
  String get homeRecentAchievements => _en ? 'Recent Achievements'           : 'Conquistas recentes';
  String get homeNoAchievements     => _en ? 'No achievements yet. Keep caring!' : 'Nenhuma conquista ainda. Continue cuidando!';
  String get homeResetGoalsBtn      => _en ? "Reset today's goals"           : 'Reiniciar metas de hoje';
  String get homeLevelUpOverlay     => _en ? 'Level'                         : 'Nível';
  String get homeExperienceLabel    => _en ? 'Experience'                    : 'Experiência';
  String get homeDailyMissionsTooltip => _en ? 'Daily Missions'              : 'Missões Diárias';
  String get homeLoadingText        => _en ? 'Loading your pet...'           : 'Carregando seu pet...';
  String get homeDarkModeLabel      => _en ? 'Dark mode'                     : 'Modo escuro';
  String get homeLightModeLabel     => _en ? 'Light mode'                    : 'Modo claro';
  String get homeHistoryHealth      => _en ? 'Health History'                : 'Histórico de Saúde';
  String get homeSettingsLabel      => _en ? 'Settings'                      : 'Configurações';
  String get navAdventures          => _en ? 'Adventures'                    : 'Aventuras';
  String get navGames               => _en ? 'Games'                         : 'Jogos';
  String get navEvolutions          => _en ? 'Evolutions'                    : 'Evoluções';

  // ── Settings screen — extended (embedded in home_screen) ────────────────────
  String get settingsSoundTitle     => _en ? 'Sound effects'                 : 'Sons e efeitos sonoros';
  String get settingsSoundSubtitle  => _en ? 'Enable sounds for actions, level up, achievements and pet events.' : 'Ativa sons para ações, level up, conquistas e eventos do pet.';
  String get settingsResetTitle     => _en ? 'Reset Pet'                     : 'Reiniciar Pet';
  String get settingsResetSubtitle  => _en ? 'Erases all progress and returns to the pet selection screen.' : 'Apaga todo o progresso e volta à tela de escolha do pet.';
  String get settingsResetDialogContent => _en ? 'All progress will be permanently erased.\n\nAre you sure you want to continue?' : 'Todo o progresso será apagado permanentemente.\n\nTem certeza que deseja continuar?';
  String get settingsResetBtn       => _en ? 'Reset'                         : 'Reiniciar';
  String get settingsLogoutTitle    => _en ? 'Switch profile'                : 'Trocar perfil';
  String get settingsLogoutConnectedAs => _en ? 'Playing as'                 : 'Jogando como';
  String get settingsLogoutDialogTitle => _en ? 'Switch profile?'            : 'Trocar de perfil?';
  String get settingsLogoutDialogContent => _en ? 'Your progress will be saved. You can return at any time.' : 'Seu progresso permanece salvo. Você poderá voltar a qualquer momento.';
  String get settingsLogoutBtn      => _en ? 'Switch'                        : 'Trocar';

  // ── Fainted screen ───────────────────────────────────────────────────────────
  String get faintedTitle           => _en ? 'Your pet fainted!'              : 'Seu pet desmaiou!';
  String get faintedBody            => _en ? 'Health reached zero. Neglecting feeding, hygiene or rest can be fatal for your pet.' : 'A saúde chegou a zero. Descuido com alimentação, higiene ou descanso pode ser fatal para o pet.';
  String get faintedStatHealth      => _en ? 'Health'                         : 'Saúde';
  String get faintedStatHunger      => _en ? 'Hunger'                         : 'Fome';
  String get faintedStatEnergy      => _en ? 'Energy'                         : 'Energia';
  String get faintedStatHappiness   => _en ? 'Happiness'                      : 'Felicidade';
  String get faintedMedicine        => _en ? 'Use Medicine (10 💰)'            : 'Usar Medicamento (10 💰)';
  String get faintedMedicineNoCoins => _en ? 'Medicine (insufficient coins)'   : 'Medicamento (moedas insuficientes)';
  String get faintedNaturalRecovery => _en ? 'Natural Recovery (severe penalty)' : 'Recuperação Natural (penalidade severa)';
  String get faintedNaturalNote     => _en ? 'Natural recovery: Health=10, minimum stats, -30 XP' : 'Recuperação natural: Saúde=10, stats mínimos, -30 XP';

  // ── Daily quests — extended ───────────────────────────────────────────────────
  String get questsSummary          => _en ? 'Summary'                        : 'Resumo';
  String get questsActiveLabel      => _en ? 'Active'                         : 'Ativas';
  String get questsCompletedLabel   => _en ? 'Completed'                      : 'Completas';
  String get questsActiveMissions   => _en ? 'Active Missions'                : 'Missões Ativas';
  String get questsCompletedMissions=> _en ? 'Completed Missions'             : 'Missões Completas';
  String get questsEmpty            => _en ? '📭 No missions available'        : '📭 Nenhuma missão disponível';

  // ── Evolution — extended ──────────────────────────────────────────────────────
  String get evoRequiredAccessory   => _en ? 'Required accessory'             : 'Acessório necessário';

  // ── Achievements — extended ───────────────────────────────────────────────────
  String get achievementsComplete   => _en ? 'complete'                       : 'completo';

  // ── Titles screen ─────────────────────────────────────────────────────────────
  String get titlesScreenTitle      => _en ? 'Titles & Ranks'       : 'Títulos e Ranks';
  String get titlesActiveLabel      => _en ? 'Active Title'         : 'Título Ativo';
  String get titlesNoneEquipped     => _en ? 'No title equipped'    : 'Nenhum título equipado';
  String get titlesUnlockedLabel    => _en ? 'unlocked'             : 'desbloqueados';
  String get titlesEarnedVia        => _en ? 'Earned via:'          : 'Conquistado via:';
  String get titlesUnlockedSrc      => _en ? 'Unlocked'             : 'Desbloqueado';
  String get titlesSpecialDesc      => _en ? 'Special unlocked title.' : 'Título especial desbloqueado.';
  String get titlesActiveChip       => _en ? 'Active'               : 'Ativo';
  String get titlesUseBtn           => _en ? 'Use'                  : 'Usar';

  // ── Dynamic lookup helpers ───────────────────────────────────────────────────

  /// Translate pet.stage string (PT key) to current locale.
  String petStage(String pt) => !_en ? pt : switch (pt) {
    'Filhote'  => 'Baby',
    'Jovem'    => 'Young',
    'Adulto'   => 'Adult',
    'Lendário' => 'Legendary',
    _          => pt,
  };

  /// Translate petMood string (PT key) to current locale.
  String petMoodLabel(String pt) => !_en ? pt : switch (pt) {
    'Doente'    => 'Sick',
    'Exausto'   => 'Exhausted',
    'Faminto'   => 'Starving',
    'Triste'    => 'Sad',
    'Radiante'  => 'Radiant',
    'Bem-estar' => 'Feeling good',
    _           => pt,
  };

  /// Translate bond integer value to bond label.
  String petBondLabel(int bond) {
    if (bond >= 80) return _en ? 'Soul Mate'    : 'Alma Gêmea';
    if (bond >= 60) return _en ? 'Close'        : 'Íntimo';
    if (bond >= 40) return _en ? 'Friend'       : 'Amigo';
    if (bond >= 20) return _en ? 'Acquaintance' : 'Conhecido';
    return                      _en ? 'Stranger'    : 'Estranho';
  }

  /// No active event message.
  String get noActiveEvent => _en ? 'No active event at the moment.' : 'Nenhum evento ativo no momento.';

  /// Translate daily event title by event id.
  String eventTitle(String id) => switch (id) {
    'tempestade'    => _en ? 'Overcast Day'       : 'Dia nublado',
    'amigo'         => _en ? 'Friendly Visitor'   : 'Visitante amigável',
    'novos_sabores' => _en ? 'Special Food'       : 'Comida especial',
    'cuidado_extra' => _en ? 'Extra Care Day'     : 'Dia de cuidados extras',
    'pascoa'        => _en ? '🐣 Easter!'          : '🐣 Páscoa!',
    'festa_junina'  => _en ? '🎆 Summer Festival!' : '🎆 Festa Junina!',
    'halloween'     => '🎃 Halloween!',
    'natal'         => _en ? '🎄 Christmas!'       : '🎄 Natal!',
    'ano_novo'      => _en ? '🎉 New Year!'        : '🎉 Ano Novo!',
    _               => id,
  };

  /// Translate daily event description by event id.
  String eventDescription(String id) => switch (id) {
    'tempestade'    => _en ? 'Your pet needs extra love today.'            : 'O pet precisa de mais carinho hoje.',
    'amigo'         => _en ? 'Your pet got extra energy!'                  : 'Seu pet ganhou animação extra!',
    'novos_sabores' => _en ? 'You found a delicious treat.'               : 'Você encontrou um petisco delicioso.',
    'cuidado_extra' => _en ? 'Your pet is feeling a bit weak today.'      : 'O pet está um pouco fraco hoje.',
    'pascoa'        => _en ? 'Chocolate eggs everywhere! Your pet is thrilled.' : 'Ovos de chocolate por toda parte! Seu pet está eufórico.',
    'festa_junina'  => _en ? 'Music and popcorn! Your pet dances with joy.' : 'Forró e pipoca! O pet dança de alegria.',
    'halloween'     => _en ? 'Trick or treat? Your pet is scared but happy!' : 'Doces ou travessuras? Seu pet está assustado mas feliz!',
    'natal'         => _en ? 'Santa visited your pet! Gifts for everyone.' : 'Papai Noel visitou o pet! Presentes para todos.',
    'ano_novo'      => _en ? 'Fireworks! Your pet is full of hope.'        : 'Fogos no céu! Seu pet está cheio de esperança.',
    _               => id,
  };

  /// Translate daily quest title by quest id.
  String questTitleById(String id) => switch (id) {
    'quest_minigames' => _en ? 'Dedicated Player'  : 'Jogador Dedicado',
    'quest_adventure' => _en ? 'Adventurer'        : 'Aventureiro',
    'quest_happiness' => _en ? 'Happy Pet'         : 'Pet Feliz',
    'quest_coins'     => _en ? 'Financial Wizard'  : 'Aipim Financeiro',
    _                 => id,
  };

  /// Translate daily quest description by quest id.
  String questDescriptionById(String id) => switch (id) {
    'quest_minigames' => _en ? 'Play 5 minigames'          : 'Jogue 5 minigames',
    'quest_adventure' => _en ? 'Complete 1 adventure'      : 'Complete 1 aventura',
    'quest_happiness' => _en ? 'Keep happiness above 70'   : 'Mantenha felicidade acima de 70',
    'quest_coins'     => _en ? 'Earn 150 coins'            : 'Ganhe 150 moedas',
    _                 => id,
  };

  /// Translate achievement title by achievement id.
  String achievementTitleById(String id) => switch (id) {
    'games_10'      => _en ? 'Beginner'             : 'Iniciante',
    'games_50'      => _en ? 'Player'               : 'Jogador',
    'games_100'     => _en ? 'Addicted'             : 'Viciado',
    'adv_3'         => _en ? 'Adventurer'           : 'Aventureiro',
    'adv_10'        => _en ? 'Explorer'             : 'Explorador',
    'coins_500'     => _en ? 'Saver'                : 'Poupador',
    'coins_5000'    => _en ? 'Millionaire'          : 'Milionário',
    'level_5'       => _en ? 'Growing'              : 'Em Crescimento',
    'level_10'      => _en ? 'Champion'             : 'Campeão',
    'evo_1'         => _en ? 'Evolved'              : 'Evoluído',
    'evo_legendary' => _en ? 'Legendary'            : 'Lendário',
    'quests_10'     => _en ? 'Missions Completed'   : 'Missões Completadas',
    'streak_3'      => _en ? 'Dedicated'            : 'Dedicado',
    'streak_7'      => _en ? 'Loyal'               : 'Fiel',
    'happy_80'      => _en ? 'Full Happiness'       : 'Felicidade Plena',
    _               => id,
  };

  /// Translate achievement description by achievement id.
  String achievementDescriptionById(String id) => switch (id) {
    'games_10'      => _en ? 'Play 10 minigames'                   : 'Jogue 10 minigames',
    'games_50'      => _en ? 'Play 50 minigames'                   : 'Jogue 50 minigames',
    'games_100'     => _en ? 'Play 100 minigames'                  : 'Jogue 100 minigames',
    'adv_3'         => _en ? 'Complete 3 adventures'               : 'Complete 3 aventuras',
    'adv_10'        => _en ? 'Complete 10 adventures'              : 'Complete 10 aventuras',
    'coins_500'     => _en ? 'Accumulate 500 coins'                : 'Acumule 500 moedas',
    'coins_5000'    => _en ? 'Accumulate 5,000 coins'              : 'Acumule 5.000 moedas',
    'level_5'       => _en ? 'Reach level 5'                       : 'Alcance o nível 5',
    'level_10'      => _en ? 'Reach level 10'                      : 'Alcance o nível 10',
    'evo_1'         => _en ? 'Evolve your pet for the first time'  : 'Evolua seu pet pela primeira vez',
    'evo_legendary' => _en ? 'Evolve to the Legendary form'        : 'Evolua para a forma Lendária',
    'quests_10'     => _en ? 'Complete 10 daily missions'          : 'Complete 10 missões diárias',
    'streak_3'      => _en ? 'Play 3 days in a row'                : 'Jogue 3 dias seguidos',
    'streak_7'      => _en ? 'Play 7 days in a row'                : 'Jogue 7 dias seguidos',
    'happy_80'      => _en ? 'Keep happiness above 80'             : 'Mantenha felicidade acima de 80',
    _               => id,
  };

  /// Translate adventure name by adventure id.
  String adventureName(String id) => switch (id) {
    'forest'   => _en ? 'Mysterious Forest'    : 'Floresta Misteriosa',
    'cave'     => _en ? 'Dark Cave'            : 'Caverna Escura',
    'ocean'    => _en ? 'Ocean Adventure'      : 'Aventura no Oceano',
    'mountain' => _en ? 'Mountain Peak'        : 'Pico da Montanha',
    'castle'   => _en ? 'Enchanted Castle'     : 'Castelo Encantado',
    _          => id,
  };

  /// Translate adventure description by adventure id.
  String adventureDescription(String id) => switch (id) {
    'forest'   => _en ? 'Explore the forest in search of treasure'       : 'Explore a floresta em busca de tesouro',
    'cave'     => _en ? 'Unravel the mysteries of the cave'              : 'Desvende os mistérios da caverna',
    'ocean'    => _en ? 'Dive into the depths of the ocean'             : 'Mergulhe nas profundezas do oceano',
    'mountain' => _en ? 'Climb the tallest mountain in the kingdom'     : 'Escale a maior montanha do reino',
    'castle'   => _en ? 'Discover the secrets of the castle'           : 'Descubra os segredos do castelo',
    _          => id,
  };

  /// Translate store item name by item id.
  String storeItemName(String id) => switch (id) {
    'racao_premium' => _en ? 'Premium Food'      : 'Ração Premium',
    'brinquedo'     => _en ? 'Toy'               : 'Brinquedo',
    'spray_saude'   => _en ? 'Health Spray'      : 'Spray de Saúde',
    'coleira_luz'   => _en ? 'Glowing Collar'    : 'Coleira Brilhante',
    'chapelinho'    => _en ? 'Party Hat'         : 'Chapéu Festa',
    'ninja_mask'    => _en ? 'Ninja Mask'        : 'Máscara Ninja',
    'robot_suit'    => _en ? 'Robot Suit'        : 'Traje Robô',
    'alien_helmet'  => _en ? 'Alien Helmet'      : 'Capacete Alienígena',
    'wizard_hat'    => _en ? 'Wizard Hat'        : 'Chapéu de Mago',
    'katana'        => _en ? 'Samurai Katana'    : 'Katana de Samurai',
    'space_suit'    => _en ? 'Astronaut Suit'    : 'Traje Astronauta',
    'cape'          => _en ? 'Vampire Cape'      : 'Capa Vampiro',
    'boost_xp'      => _en ? 'XP Boost'          : 'Boost de XP',
    'cooldown_reset'=> _en ? 'Cooldown Reset'    : 'Reset de Cooldown',
    _               => id,
  };

  /// Translate store item description by item id.
  String storeItemDescription(String id) => switch (id) {
    'racao_premium' => _en ? 'Quickly restores hunger and gives +10 experience.'                         : 'Recupera fome rapidamente e dá +10 de experiência.',
    'brinquedo'     => _en ? "Increases happiness and improves the pet's mood."                          : 'Aumenta felicidade e melhora o humor do pet.',
    'spray_saude'   => _en ? 'Restores the pet\'s health when it is weak.'                               : 'Restaura a saúde do pet quando ele estiver fraco.',
    'coleira_luz'   => _en ? 'A visual accessory that makes your pet special.'                           : 'Acessório visual que deixa seu pet especial.',
    'chapelinho'    => _en ? 'Makes the pet happier and more stylish.'                                   : 'Deixa o pet mais feliz e estiloso.',
    'ninja_mask'    => _en ? 'A mysterious accessory. Unlocks the Ninja Form at level 5.'                : 'Um acessório misterioso. Desbloqueia a Forma Ninja ao atingir nível 5.',
    'robot_suit'    => _en ? 'A futuristic suit. Unlocks the Robot Form at level 8.'                     : 'Um traje futurista. Desbloqueia a Forma Robô ao atingir nível 8.',
    'alien_helmet'  => _en ? 'Out of this world. Unlocks the Alien Form at level 12.'                    : 'De outro mundo. Desbloqueia a Forma Alienígena ao atingir nível 12.',
    'wizard_hat'    => _en ? 'A magical hat. Unlocks the Wizard Form at level 5.'                        : 'Um chapéu mágico. Desbloqueia a Forma Mago ao atingir nível 5.',
    'katana'        => _en ? 'A legendary blade. Unlocks the Samurai Form at level 7.'                   : 'Uma lâmina lendária. Desbloqueia a Forma Samurai ao atingir nível 7.',
    'space_suit'    => _en ? 'Out of this world! Unlocks the Astronaut Form at level 6.'                 : 'É de outro mundo! Desbloqueia a Forma Astronauta ao atingir nível 6.',
    'cape'          => _en ? 'Mysterious and dark. Unlocks the Vampire Form at level 6.'                 : 'Misteriosa e sombria. Desbloqueia a Forma Vampiro ao atingir nível 6.',
    'boost_xp'      => _en ? 'Doubles XP gained for 30 minutes.'                                       : 'Dobra o XP ganho por 30 minutos.',
    'cooldown_reset'=> _en ? 'Instantly resets all action cooldowns.'                                  : 'Zera o tempo de espera de todas as ações imediatamente.',
    _               => id,
  };

  /// Translate evolution form display name by PetForm.
  String evoFormName(PetForm form) => switch (form) {
    PetForm.baby            => _en ? 'Baby'            : 'Filhote',
    PetForm.young           => _en ? 'Young'           : 'Jovem',
    PetForm.adult           => _en ? 'Adult'           : 'Adulto',
    PetForm.legendary       => _en ? 'Legendary'       : 'Lendário',
    PetForm.powerfulForm    => _en ? 'Powerful Form'   : 'Forma Poderosa',
    PetForm.happyForm       => _en ? 'Happy Form'      : 'Forma Feliz',
    PetForm.smartForm       => _en ? 'Wise Form'       : 'Forma Sábia',
    PetForm.ninjaForm       => _en ? 'Ninja'           : 'Ninja',
    PetForm.robotForm       => _en ? 'Robot'           : 'Robô',
    PetForm.alienForm       => _en ? 'Alien'           : 'Alienígena',
    PetForm.shadowForm      => _en ? 'Shadow Form'     : 'Forma Sombria',
    PetForm.athleteForm     => _en ? 'Athlete Form'    : 'Forma Atleta',
    PetForm.hungryForm      => _en ? 'Starving Form'   : 'Forma Faminta',
    PetForm.ghostForm       => _en ? 'Ghost Form'      : 'Forma Fantasma',
    PetForm.gameMasterForm  => _en ? 'Game Master'     : 'Mestre dos Games',
    PetForm.explorerForm    => _en ? 'Explorer'        : 'Explorador',
    PetForm.millionaireForm => _en ? 'Millionaire'     : 'Milionário',
    PetForm.veteranForm     => _en ? 'Veteran'         : 'Veterano',
    PetForm.wizardForm      => _en ? 'Wizard'          : 'Mago',
    PetForm.samuraiForm     => _en ? 'Samurai'         : 'Samurai',
    PetForm.astronautForm   => _en ? 'Astronaut'       : 'Astronauta',
    PetForm.vampireForm     => _en ? 'Vampire'         : 'Vampiro',
  };

  /// Translate daily goal title by goal id.
  String goalTitleById(String id) => switch (id) {
    'feed'  => _en ? 'Feed 3 times'  : 'Alimente 3 vezes',
    'play'  => _en ? 'Play 2 times'  : 'Brinque 2 vezes',
    'clean' => _en ? 'Clean 1 time'  : 'Limpe 1 vez',
    'sleep' => _en ? 'Sleep 1 time'  : 'Durma 1 vez',
    _       => id,
  };

  /// 'done' / 'concluído' label used in goal progress.
  String get goalDone => _en ? 'done' : 'concluído';

  String get boostXpActive => _en ? 'XP Boost active' : 'Boost de XP ativo';

  // ── Pet message (best status) ─────────────────────────────────────────────

  String petMessage(String pt) => !_en ? pt : switch (pt) {
    'Preciso de socorro urgente! 🆘'              => 'I need urgent help! 🆘',
    'Estou passando mal de fome! 😩'              => 'I\'m starving! 😩',
    'Estou com muita fome! 🍖'                    => 'I\'m very hungry! 🍖',
    'Mal consigo ficar de pé... 😵'               => 'I can barely stand... 😵',
    'Estou com muito sono... 😴'                  => 'I\'m so sleepy... 😴',
    'Estou muito triste... 😢'                    => 'I\'m very sad... 😢',
    'Quero brincar! 🎾'                           => 'I want to play! 🎾',
    'Preciso de cuidados. 🩺'                     => 'I need some care. 🩺',
    'Você é o melhor! ❤️'                         => 'You\'re the best! ❤️',
    'Me sinto invencível! 💪'                     => 'I feel invincible! 💪',
    'Estou muito feliz! 😄'                       => 'I\'m so happy! 😄',
    'Estou me sentindo bem! 😊'                   => 'I\'m feeling great! 😊',
    _                                             => pt,
  };

  // ── Minigame / Adventure / Evolution hints ────────────────────────────────

  String minigameHint(String pt) => !_en ? pt : switch (pt) {
    'Seu pet está bem! Ganhe recompensas maiores nos minigames.'          => 'Your pet is doing great! Earn bigger rewards in minigames.',
    'Seu pet precisa de atenção. Minigames terão menos recompensa.'       => 'Your pet needs attention. Minigames will give less reward.',
    'Estado do pet neutro. Jogue para melhorar as recompensas.'           => 'Neutral pet state. Play to improve rewards.',
    _                                                                     => pt,
  };

  String adventureHint(String pt) => !_en ? pt : switch (pt) {
    'Seu pet não está bem. Aventura pode falhar ou dar menos recompensa.' => 'Your pet is not doing well. Adventure may fail or give less reward.',
    'Seu pet está ótimo! Maior chance de sucesso e recompensas melhores.' => 'Your pet is great! Higher chance of success and better rewards.',
    'Estado do pet normal para aventuras.'                                => 'Normal pet state for adventures.',
    _                                                                     => pt,
  };

  String evolutionHint(String pt) => !_en ? pt : switch (pt) {
    'Seu pet está bem! Evoluções ficam mais fáceis.'                      => 'Your pet is doing great! Evolutions become easier.',
    'Seu pet precisa de mais energia para evoluir facilmente.'            => 'Your pet needs more energy to evolve easily.',
    'Estado do pet normal para evoluções.'                                => 'Normal pet state for evolutions.',
    _                                                                     => pt,
  };

  // ── Activity log entries (home Recent Achievements list) ─────────────────

  String translateActivityEntry(String entry) {
    if (!_en) return entry;
    // Simple fixed strings
    if (entry == 'Saúde máxima alcançada') return 'Maximum health reached';
    if (entry == 'Fome controlada') return 'Hunger under control';
    // 'Subiu para o nível X!' → 'Leveled up to X!'
    final levelMatch = RegExp(r'^Subiu para o nível (\d+)!$').firstMatch(entry);
    if (levelMatch != null) return 'Leveled up to ${levelMatch.group(1)}!';
    // '🏅 Conquista: <PT title> (+N 💰)' → '🏅 Achievement: <EN title> (+N 💰)'
    final achMatch = RegExp(r'^🏅 Conquista: (.+) \(\+(\d+) 💰\)$').firstMatch(entry);
    if (achMatch != null) {
      final ptTitle = achMatch.group(1)!;
      final coins = achMatch.group(2)!;
      final enTitle = _achievementTitleFromPt(ptTitle);
      return '🏅 Achievement: $enTitle (+$coins 💰)';
    }
    // '✨ Evoluiu para <PT name>!' → '✨ Evolved to <EN name>!'
    final evoMatch = RegExp(r'^✨ Evoluiu para (.+)!$').firstMatch(entry);
    if (evoMatch != null) {
      final ptName = evoMatch.group(1)!;
      final enName = _evoNameFromPt(ptName);
      return '✨ Evolved to $enName!';
    }
    return entry;
  }

  String _achievementTitleFromPt(String pt) => switch (pt) {
    'Iniciante'            => 'Beginner',
    'Jogador'              => 'Player',
    'Viciado'              => 'Addicted',
    'Aventureiro'          => 'Adventurer',
    'Explorador'           => 'Explorer',
    'Poupador'             => 'Saver',
    'Milionário'           => 'Millionaire',
    'Em Crescimento'       => 'Growing',
    'Campeão'              => 'Champion',
    'Evoluído'             => 'Evolved',
    'Lendário'             => 'Legendary',
    'Missões Completadas'  => 'Missions Completed',
    'Dedicado'             => 'Dedicated',
    'Fiel'                 => 'Loyal',
    'Felicidade Plena'     => 'Full Happiness',
    _                      => pt,
  };

  String _evoNameFromPt(String pt) => switch (pt) {
    'Filhote'          => 'Baby',
    'Jovem'            => 'Young',
    'Adulto'           => 'Adult',
    'Lendário'         => 'Legendary',
    'Forma Poderosa'   => 'Powerful Form',
    'Forma Feliz'      => 'Happy Form',
    'Forma Sábia'      => 'Wise Form',
    'Ninja'            => 'Ninja',
    'Robô'             => 'Robot',
    'Alienígena'       => 'Alien',
    'Forma Sombria'    => 'Shadow Form',
    'Forma Atleta'     => 'Athlete Form',
    'Forma Faminta'    => 'Starving Form',
    'Forma Fantasma'   => 'Ghost Form',
    'Mestre dos Games' => 'Game Master',
    'Explorador'       => 'Explorer',
    'Milionário'       => 'Millionaire',
    'Veterano'         => 'Veteran',
    'Mago'             => 'Wizard',
    'Samurai'          => 'Samurai',
    'Astronauta'       => 'Astronaut',
    'Vampiro'          => 'Vampire',
    _                  => pt,
  };
}
