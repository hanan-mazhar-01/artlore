import '../widgets/floating_nav/art_nav_item.dart';
import '../widgets/icons/art_icons.dart';
import 'app_routes.dart';

/// The floating navigation, in order. Edit here to add, remove or reorder
/// destinations; `branch` indexes match the shell branches in the router.
const artNavItems = [
  ArtNavItem.tab(icon: ArtIcons.house, label: 'Home', branch: 0),
  ArtNavItem.action(
    icon: ArtIcons.scanTab,
    label: 'Scan an artwork',
    route: AppRoutes.scan,
  ),
  ArtNavItem.tab(icon: ArtIcons.gallery, label: 'Collection', branch: 1),
  ArtNavItem.tab(icon: ArtIcons.person, label: 'Profile', branch: 2),
];
