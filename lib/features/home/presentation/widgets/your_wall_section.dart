import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../artwork/domain/artwork.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../wall/wall_controller.dart';
import 'hanging_frames.dart';
import 'home_style.dart';

/// "Your wall": the newest saved works (up to three) hanging from a picture
/// rail in warm light, each in an ornate frame, swaying gently — and nothing
/// else: no titles, no captions, no buttons. Press and hold a frame and drag
/// it off the wall to take it down. The wall is chosen by the visitor (up to
/// three) and is separate from the collection.
class YourWallSection extends StatefulWidget {
  const YourWallSection({
    super.key,
    required this.works,
    required this.onTakeDown,
  });

  /// The paintings on the wall, newest hung first (at most three).
  final List<Artwork> works;

  /// A frame was dragged off the wall.
  final ValueChanged<Artwork> onTakeDown;

  @override
  State<YourWallSection> createState() => _YourWallSectionState();
}

class _YourWallSectionState extends State<YourWallSection> {
  final _keys = List<GlobalKey>.generate(3, (_) => GlobalKey());
  final _wallKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final s = HomeStyle.of(context);
    final shown = widget.works.take(maxWallWorks).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'Your wall',
                  style: AppTypography.sans(
                    21,
                    weight: FontWeight.w700,
                    tracking: -.015,
                  ).copyWith(color: s.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            key: _wallKey,
            height: 176,
            // Not clipped: a frame lifted off the wall is carried out over it.
            decoration: BoxDecoration(
              color: s.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: s.line),
              boxShadow: [
                BoxShadow(
                  color: s.shadow(.35),
                  offset: const Offset(0, 18),
                  blurRadius: 30,
                  spreadRadius: -22,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Warm light falling from above, and the picture rail — kept
                // inside the wall's rounded shape.
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(27),
                    child: const Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(0, -1.25),
                                radius: .95,
                                colors: [Color(0x38FFE2A0), Color(0x00FFE2A0)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: 2,
                          child: ColoredBox(color: Color(0x59C9A45C)),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Tappable(
                    onTap: () => showWallGuide(context),
                    semanticLabel: 'How your wall works',
                    pressedScale: .9,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: s.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: s.line),
                      ),
                      child: ArtIcon(
                        ArtIcons.info,
                        size: 17,
                        color: s.gold,
                        strokeWidth: 1.8,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 6,
                  child: shown.isEmpty
                      ? const _GhostFrames()
                      : HangingFrames(
                          wall: true,
                          sources: [for (final w in shown) w.image],
                          pictureKeys: _keys,
                          wallKey: _wallKey,
                          onRemove: (i) => widget.onTakeDown(shown[i]),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three empty outlines on the wall, where saved works will hang.
class _GhostFrames extends StatelessWidget {
  const _GhostFrames();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 22),
            Container(
              width: 70,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0x66C9A45C), width: 1.2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
