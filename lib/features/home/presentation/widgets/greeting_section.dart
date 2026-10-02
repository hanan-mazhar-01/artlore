import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../profile/presentation/profile_providers.dart';

/// "Good evening, Hanan — What will you discover today?"
class GreetingSection extends ConsumerWidget {
  const GreetingSection({super.key});

  static String salutation(DateTime now) => switch (now.hour) {
    < 5 => 'Good evening',
    < 12 => 'Good morning',
    < 17 => 'Good afternoon',
    _ => 'Good evening',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final name = ref.watch(
      userProfileProvider.select((v) => v.value?.firstName),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorialHeading(
            lead: name == null
                ? salutation(DateTime.now())
                : '${salutation(DateTime.now())},',
            emphasis: name,
            breakLine: false,
            style: AppTypography.serif(
              34,
              weight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What will you discover today?',
            style: AppTypography.bodySmall.copyWith(color: p.muted),
          ),
        ],
      ),
    );
  }
}
