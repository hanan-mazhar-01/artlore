import '../widgets/floating_nav/art_nav_item.dart';
import '../widgets/icons/art_icons.dart';

/// The floating pill's tabs, in order. `branch` indexes match the shell
/// branches in the router. Scan isn't one of these — it sits beside the
/// pill as its own circular button (see `ScanFab`), so edit here only to
/// add, remove or reorder the three destinations.
const artNavItems = [
  ArtNavItem(icon: ArtIcons.house, label: 'Home', branch: 0),
  ArtNavItem(icon: ArtIcons.gallery, label: 'Collection', branch: 1),
  ArtNavItem(icon: ArtIcons.person, label: 'Profile', branch: 2),
];
