import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_dialogue.dart';
import '../services/locale_controller.dart';

class PetDialogueScreen extends StatefulWidget {
  const PetDialogueScreen({super.key});

  @override
  State<PetDialogueScreen> createState() => _PetDialogueScreenState();
}

class _PetDialogueScreenState extends State<PetDialogueScreen>
    with SingleTickerProviderStateMixin {
  late DialogueNode _node;
  bool _responded = false;
  String _petResponse = '';
  DialogueChoice? _pickedChoice;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final controller = context.read<PetController>();
    _node = PetDialoguePool.pickForForm(controller.currentPetForm);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _pickChoice(DialogueChoice choice) {
    if (_responded) return;
    final controller = context.read<PetController>();
    final isEn = context.read<LocaleController>().isEn;

    controller.applyDialogueReward(choice);

    setState(() {
      _responded = true;
      _pickedChoice = choice;
      _petResponse = isEn ? choice.responseEn : choice.responsePt;
    });
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEn = context.watch<LocaleController>().isEn;
    final s = context.watch<LocaleController>().s;
    final controller = context.watch<PetController>();
    final petEmoji = controller.getFormEmoji();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.dialogueTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Pet avatar + speech bubble ─────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet emoji avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    alignment: Alignment.center,
                    child: Text(petEmoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  // Speech bubble
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: _TypewriterText(
                        text: isEn ? _node.petTextEn : _node.petTextPt,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Player choices ─────────────────────────────────
              if (!_responded)
                ..._node.choices.map((choice) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _pickChoice(choice),
                          child: Text(
                            isEn ? choice.textEn : choice.textPt,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )),

              // ── Pet response ───────────────────────────────────
              if (_responded)
                FadeTransition(
                  opacity: _fadeCtrl,
                  child: Column(
                    children: [
                      // Selected choice (dimmed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEn
                                    ? _pickedChoice!.textEn
                                    : _pickedChoice!.textPt,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pet response bubble
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primaryContainer,
                            ),
                            alignment: Alignment.center,
                            child: Text(petEmoji,
                                style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: _TypewriterText(
                                text: _petResponse,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Rewards indicator
                      if (_pickedChoice != null &&
                          _pickedChoice!.happinessDelta != 0)
                        Wrap(
                          spacing: 12,
                          children: [
                            if (_pickedChoice!.happinessDelta > 0)
                              _RewardChip(
                                  icon: '😊',
                                  label:
                                      '+${_pickedChoice!.happinessDelta} ${isEn ? "happiness" : "felicidade"}'),
                            if (_pickedChoice!.happinessDelta < 0)
                              _RewardChip(
                                  icon: '😢',
                                  label:
                                      '${_pickedChoice!.happinessDelta} ${isEn ? "happiness" : "felicidade"}'),
                          ],
                        ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: Text(s.dialogueBack),
                      ),
                    ],
                  ),
                ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Typewriter effect ────────────────────────────────────────────────────────

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _TypewriterText({required this.text, this.style});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  int _charCount = 0;
  late final int _totalChars;

  @override
  void initState() {
    super.initState();
    _totalChars = widget.text.length;
    _animate();
  }

  Future<void> _animate() async {
    for (int i = 1; i <= _totalChars; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() => _charCount = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _charCount),
      style: widget.style,
    );
  }
}

// ── Reward chip ──────────────────────────────────────────────────────────────

class _RewardChip extends StatelessWidget {
  final String icon;
  final String label;

  const _RewardChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Text(icon, style: const TextStyle(fontSize: 14)),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }
}
