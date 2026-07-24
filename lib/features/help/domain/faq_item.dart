// lib/features/help/domain/faq_item.dart
import 'package:flutter/material.dart';

/// A single FAQ entry: one question, one answer, tagged with a category.
class FaqItem {
  final String question;
  final String answer;
  final FaqCategory category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

/// Categories used to group FAQ items on the Help screen.
///
/// The `label` and `icon` are used directly by the UI so adding a new
/// category later only means adding one enum value here.
enum FaqCategory {
  diary('Diary & Entries', Icons.book_outlined),
  themes('Themes & Customization', Icons.palette_outlined),
  stickersAndMedia('Stickers, Images & Media', Icons.image_outlined),
  privacyAndLock('Privacy & App Lock', Icons.lock_outline),
  reminders('Reminders', Icons.notifications_outlined),
  backupAndData('Backup, Import & Export', Icons.cloud_outlined),
  general('General', Icons.help_outline);

  final String label;
  final IconData icon;

  const FaqCategory(this.label, this.icon);
}