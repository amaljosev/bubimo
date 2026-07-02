// lib/features/diary_entry/presentation/widgets/mood_picker.dart

import 'package:flutter/material.dart';

import '../../domain/entities/mood.dart';

/// Row of emoji buttons for selecting a [Mood] on the Create/Update form.
///
/// Stateless and controlled entirely by [selectedMood] + [onMoodSelected] —
/// mirrors the pattern used elsewhere in this app (e.g. `MoodPicker` has no
/// bloc of its own; `DiaryFormPage` wires it to `DiaryFormBloc` the same
/// way it wires the title/content `TextField`s).
class MoodPicker extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood> onMoodSelected;

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
        return _MoodButton(
          mood: mood,
          isSelected: isSelected,
          colorScheme: colorScheme,
          onTap: () => onMoodSelected(mood),
        );
      }).toList(),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final Mood mood;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _MoodButton({
    required this.mood,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: mood.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 24)),
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
      ),
    );
  }
}