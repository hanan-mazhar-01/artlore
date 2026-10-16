import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/art_scaffold.dart';
import '../features/settings/presentation/settings_controller.dart';
import 'router.dart';

class ArtLoreApp extends ConsumerWidget {
  const ArtLoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    return MaterialApp.router(
      title: 'ArtLore',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: Curves.easeOut,
      scrollBehavior: const ArtScrollBehavior(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Layouts are drawn for a ~390pt-wide iPhone: narrower phones (SE,
        // mini) scale type down a touch, and Dynamic Type is kept within a
        // range the layouts hold at.
        final widthFactor = (media.size.width / 390).clamp(.9, 1.0);
        final system =
            media.textScaler
                .clamp(minScaleFactor: .9, maxScaleFactor: 1.15)
                .scale(100) /
            100;
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(system * widthFactor),
            disableAnimations: media.disableAnimations || reduceMotion,
          ),
          child: child!,
        );
      },
    );
  }
}
