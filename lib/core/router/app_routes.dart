import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

export 'package:go_router/go_router.dart' show GoRouter, GoRouterHelper;

/// Every location in the app. Screens never spell out paths themselves.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';

  // Tab shell.
  static const home = '/home';
  static const collection = '/collection';
  static const profile = '/profile';

  // Scan flow.
  static const scan = '/scan';
  static const reading = '/scan/reading';

  /// Reading a photo picked from the library.
  static String readingPhoto(String photoId) => '$reading?photo=$photoId';

  // Artwork.
  static String artwork(String id) => '/artwork/$id';
  static String story(String id) => '/artwork/$id/story';
  static String lookCloser(String id) => '/artwork/$id/look-closer';
  static String listen(String id) => '/artwork/$id/listen';
  static String compare(String id) => '/artwork/$id/compare';
  static const detective = '/detective';

  // You.
  static const history = '/history';
  static const personality = '/personality';
  static const paywall = '/paywall';
  static const settings = '/settings';
}

/// Intent-level navigation helpers built on go_router.
extension ArtNavigation on BuildContext {
  void openArtwork(String id) => push(AppRoutes.artwork(id));

  /// Pops when there is somewhere to go back to, otherwise lands on [fallback].
  void backOr([String fallback = AppRoutes.home]) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}
