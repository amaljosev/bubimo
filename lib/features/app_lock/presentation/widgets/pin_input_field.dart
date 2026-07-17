// lib/features/app_lock/presentation/widgets/pin_input_field.dart
import 'package:flutter/material.dart';

/// Displays PIN progress as filled/empty dots. Purely presentational —
/// actual digit capture happens via a numeric keypad or TextField
/// wired up by the parent screen, which calls [onDigitsChanged].
class PinInputField extends StatelessWidget {
  final int length;
  final int enteredCount;

  const PinInputField({
    super.key,
    this.length = 4,
    required this.enteredCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < enteredCount;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        );
      }),
    );
  }
}

/// Simple numeric keypad for PIN entry (0-9, backspace).
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox.shrink();

        return InkWell(
          onTap: () {
            if (key == '⌫') {
              onBackspacePressed();
            } else {
              onDigitPressed(key);
            }
          },
          child: Center(
            child: Text(key, style: const TextStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }
}