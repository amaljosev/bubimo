// lib/features/diary_entry/presentation/widgets/overlay/sticker_picker_sheet.dart

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../bloc/sticker_picker/sticker_picker_bloc.dart';

/// Opens the sticker picker bottom sheet and returns the URL of the
/// sticker the user tapped, or `null` if they dismissed it without
/// choosing one.
///
/// Mirrors `showBackgroundPickerSheet`'s calling convention: the caller
/// (diary_form_page) owns what happens next (downloading + placing the
/// sticker as an overlay) — this function's only job is presenting the
/// picker UI and returning a selection.
Future<String?> showStickerPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider(
      create: (_) => getIt<StickerPickerBloc>()
        ..add(const StickerPickerRequested()),
      child: const _StickerPickerSheet(),
    ),
  );
}

class _StickerPickerSheet extends StatelessWidget {
  const _StickerPickerSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: BlocBuilder<StickerPickerBloc, StickerPickerState>(
          buildWhen: (prev, current) =>
              prev.isLoadingCategories != current.isLoadingCategories ||
              prev.categoriesError != current.categoriesError ||
              prev.stickersByCategory != current.stickersByCategory,
          builder: (context, state) {
            if (state.isLoadingCategories) {
              return const Center(child: CircularProgressIndicator());
            }


            if (state.categoriesError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please check your internet connection, or try again',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () => context
                          .read<StickerPickerBloc>()
                          .add(const StickerPickerRetried()),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }
            

            final categories = state.stickersByCategory.keys.toList();
            log(categories.toString());

            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No stickers yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DefaultTabController(
              length: categories.length,
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: categories.map((cat) => Tab(text: cat)).toList(),
                      labelStyle: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: categories.map((category) {
                        final urls = state.stickersByCategory[category] ?? [];

                        if (urls.isEmpty) {
                          return Center(
                            child: Text(
                              'Nothing in this category',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: urls.length,
                          itemBuilder: (context, index) {
                            final url = urls[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context, url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.contain,
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  placeholder: (_, _) =>
                                      const SizedBox.shrink(),
                                  errorWidget: (_, _, _) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}