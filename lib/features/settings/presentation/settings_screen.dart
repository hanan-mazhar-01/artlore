import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/art_scaffold.dart';
import '../../../core/widgets/art_sheet.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/round_buttons.dart';
import '../../paywall/presentation/premium_controller.dart';
import 'settings_controller.dart';
import 'widgets/setting_rows.dart';

const _themeModes = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
const _lengths = ['Quick', 'Story', 'Deep Dive'];

/// Settings — appearance, narration, exploring, account.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final premium = ref.watch(
      premiumProvider.select((v) => v.value?.isPremium ?? false),
    );
    return ArtScaffold(
      body: ListView(
        padding: EdgeInsets.only(top: context.topInset, bottom: 60),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlineIconButton(
                onTap: () => context.backOr(AppRoutes.profile),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
            child: Semantics(
              header: true,
              child: Text('Settings', style: AppTypography.pageTitle),
            ),
          ),
          SettingsGroup(
            title: 'Appearance',
            rows: [
              SegmentedSettingRow(
                label: 'Gallery lighting',
                hint: 'Midnight, daylight, or follow your device',
                options: const ['Dark', 'Light', 'System'],
                selected: _themeModes.indexOf(s.themeMode),
                onSelected: (i) => ctl.setThemeMode(_themeModes[i]),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Narration',
            rows: [
              SettingRow.value(
                label: 'Voice',
                hint: 'How your guide sounds',
                trailing: s.voice,
                onTap: ctl.cycleVoice,
              ),
              SettingRow.value(
                label: 'Language',
                hint: 'Stories and transcripts',
                trailing: s.language,
                onTap: ctl.cycleLanguage,
              ),
              SettingRow.value(
                label: 'Default length',
                hint: 'When you tap Listen',
                trailing: _lengths[s.narrationLength.clamp(0, 2)],
                onTap: ctl.cycleNarrationLength,
              ),
            ],
          ),
          SettingsGroup(
            title: 'Exploring',
            rows: [
              SettingRow.toggle(
                label: 'Save every scan',
                hint: 'Add identified works to history',
                value: s.saveEveryScan,
                onTap: ctl.toggleSaveEveryScan,
              ),
              SettingRow.toggle(
                label: 'Show detail markers',
                hint: 'Numbered points in Look Closer',
                value: s.showMarkers,
                onTap: ctl.toggleMarkers,
              ),
              SettingRow.toggle(
                label: 'Reduce motion',
                hint: 'Calmer transitions throughout',
                value: s.reduceMotion,
                onTap: ctl.toggleReduceMotion,
              ),
              SettingRow.toggle(
                label: 'Offline museum packs',
                hint: 'Download guides before you visit',
                value: s.offlinePacks,
                onTap: ctl.toggleOfflinePacks,
              ),
            ],
          ),
          SettingsGroup(
            title: 'Account',
            rows: [
              SettingRow.toggle(
                label: 'A painting a day',
                hint: 'One quiet notification each morning',
                value: s.dailyPainting,
                onTap: ctl.toggleDailyPainting,
              ),
              SettingRow.value(
                label: 'Subscription',
                hint: 'ArtLore Premium',
                trailing: premium ? 'Active' : 'Manage',
                onTap: () => context.push(AppRoutes.paywall),
              ),
              SettingRow.value(
                label: 'Privacy',
                hint: 'Camera, data, history',
                trailing: '',
                onTap: () => showArtSheet<void>(
                  context,
                  child: const InfoSheet(
                    kicker: 'Privacy',
                    title: 'What stays with you',
                    body:
                        'The camera is used only to recognise artworks. Your '
                        'history, collection and listening stay private to '
                        'your account, and you can clear them at any time.',
                  ),
                ),
              ),
              SettingRow.value(
                label: 'About ArtLore',
                hint: 'A gallery in your hand',
                trailing: '1.0.0',
                onTap: () => showArtSheet<void>(
                  context,
                  child: const InfoSheet(
                    kicker: 'About',
                    title: 'ArtLore',
                    body:
                        'A private museum companion. Stand before any '
                        'painting and discover the story it has been waiting '
                        'to tell.',
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextAction(
                label: 'Sign out',
                color: p.danger,
                fontSize: 14,
                onTap: () {
                  ctl.signOut();
                  context.go(AppRoutes.welcome);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
