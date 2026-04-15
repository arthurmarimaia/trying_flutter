import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/pet_controller.dart';
import 'screens/home_screen.dart';
import 'screens/profile_login_screen.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Wait for AuthService to read SharedPreferences
    if (!auth.initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
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