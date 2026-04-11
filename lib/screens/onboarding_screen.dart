import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../models/pet.dart';
import '../services/locale_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PetType? _selectedType;
  bool _loading = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleController>().s;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  s.onboardingTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  s.onboardingSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Pet name field
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: s.onboardingNameLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: s.onboardingNameHint,
                    hintStyle: const TextStyle(color: Colors.white38),
                    counterStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withAlpha(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    prefixIcon: const Icon(Icons.pets, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      _PetChoice(
                        type: PetType.canino,
                        emoji: '🐶',
                        name: s.onboardingCanineName,
                        description: s.onboardingCaninoDesc,
                        selected: _selectedType == PetType.canino,
                        onTap: () => setState(() => _selectedType = PetType.canino),
                      ),
                      const SizedBox(width: 12),
                      _PetChoice(
                        type: PetType.reptil,
                        emoji: '🦎',
                        name: s.onboardingReptilName,
                        description: s.onboardingReptilDesc,
                        selected: _selectedType == PetType.reptil,
                        onTap: () => setState(() => _selectedType = PetType.reptil),
                      ),
                      const SizedBox(width: 12),
                      _PetChoice(
                        type: PetType.slime,
                        emoji: '🟢',
                        name: s.onboardingSlimeName,
                        description: s.onboardingSlimeDesc,
                        selected: _selectedType == PetType.slime,
                        onTap: () => setState(() => _selectedType = PetType.slime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: (_selectedType == null || _loading)
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await context.read<PetController>().completeOnboarding(
                                _selectedType!,
                                name: _nameController.text,
                              );
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          s.onboardingStartBtn,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PetChoice extends StatelessWidget {
  final PetType type;
  final String emoji;
  final String name;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _PetChoice({
    required this.type,
    required this.emoji,
    required this.name,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withAlpha(40)
                : Colors.white.withAlpha(12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.white : Colors.white24,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              if (selected) ...[
                const SizedBox(height: 10),
                const Icon(Icons.check_circle,
                    color: Colors.greenAccent, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
