import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../core/router/app_routes.dart';

/// Opens the Privacy Policy ([privacy] true) or the Terms of Use on the
/// website whose address is kept in Remote Config. If the page can't be
/// opened, the copy inside the app is shown instead.
Future<void> openLegal(BuildContext context, {required bool privacy}) async {
  final config = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(remoteConfigServiceProvider);
  final url = privacy ? config.privacyPolicyUrl : config.termsOfServiceUrl;
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null && uri.hasScheme) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
  if (!opened && context.mounted) {
    context.push(privacy ? AppRoutes.privacy : AppRoutes.terms);
  }
}
