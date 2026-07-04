// lib/features/diary_entry/presentation/widgets/mood_picker.dart

import 'package:flutter/material.dart';

import '../../domain/entities/mood.dart';

/// A row of emoji buttons representing each [Mood], highlighting the
/// currently selected one. Tapping the already-selected mood deselects
/// it (calls [onMoodSelected] with null).
class MoodPicker extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood?> onMoodSelected;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Mood.values.map((mood) {
        final isSelected = mood == selectedMood;

        return GestureDetector(
          onTap: () => onMoodSelected(isSelected ? null : mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 2),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}