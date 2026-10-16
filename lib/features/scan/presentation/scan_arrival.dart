import 'dart:async';

/// Set when a scan has just been read and the visitor is about to arrive at
/// the painting's page: the page then fades in under the glide of the picture,
/// and its sheet rises from the bottom. Every other way of opening a painting
/// keeps the usual zoom, so this is a one-shot flag, not a setting.
abstract final class ScanArrival {
  static bool _pending = false;
  static Timer? _expire;

  static bool get pending => _pending;

  /// The analysis is handing over to the painting's page.
  static void mark() {
    _pending = true;
    // Never let it linger into some later, unrelated navigation.
    _expire?.cancel();
    _expire = Timer(const Duration(seconds: 5), () => _pending = false);
  }

  /// The page has taken the arrival; true once, then false.
  static bool take() {
    final was = _pending;
    _pending = false;
    _expire?.cancel();
    return was;
  }
}
