import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/pet_controller.dart';
import 'screens/home_screen.dart';
import 'screens/profile_login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/locale_controller.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundService.init();
  final localeCtrl = LocaleController();
  await localeCtrl.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeCtrl),
        ChangeNotifierProvider(create: (_) => AuthService()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Guarantee the splash is visible for at least 2.5 s so animations play.
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Always show splash for the minimum duration.
    if (!_splashDone || !auth.initialized) {
      return const SplashScreen();
    }

    // Not logged in — show login/register screen
    if (!auth.isLoggedIn) {
      return MaterialApp(
        title: 'Tamagotchi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const ProfileLoginScreen(),
      );
    }

    // Logged in — scope PetController to this user; ValueKey ensures
    // it is fully recreated whenever the active user changes.
    return ChangeNotifierProvider(
      key: ValueKey(auth.activeUsername),
      create: (_) => PetController(prefix: auth.storagePrefix)..init(),
      child: Consumer<PetController>(
        builder: (context, controller, _) {
          // ── Accessibility: high contrast theme ──────────────────────────
          final seedColor = controller.isHighContrast
              ? Colors.yellow
              : Colors.deepPurple;
          final lightScheme = controller.isHighContrast
              ? const ColorScheme.highContrastLight()
              : ColorScheme.fromSeed(seedColor: seedColor);
          final darkScheme = controller.isHighContrast
              ? const ColorScheme.highContrastDark()
              : ColorScheme.fromSeed(
                  seedColor: seedColor, brightness: Brightness.dark);

          return MaterialApp(
            title: 'Tamagotchi',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.from(
              colorScheme: lightScheme,
              useMaterial3: true,
            ),
            darkTheme: ThemeData.from(
              colorScheme: darkScheme,
              useMaterial3: true,
            ),
            themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // ── Accessibility: font scale ──────────────────────────────────
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(controller.fontScale),
                ),
                child: child!,
              );
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}