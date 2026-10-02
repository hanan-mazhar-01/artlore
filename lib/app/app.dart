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
        return MediaQuery(
          data: media.copyWith(
            // Editorial layouts stay composed up to a generous text size.
            textScaler: media.textScaler.clamp(maxScaleFactor: 1.3),
            disableAnimations: media.disableAnimations || reduceMotion,
          ),
          child: child!,
        );
      },
    );
  }
}
