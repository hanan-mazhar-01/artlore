import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../../../core/media/art_image_source.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/icons/art_icon.dart';
import '../../../../core/widgets/icons/art_icons.dart';

/// Up to three gilded picture frames hanging from nails by their wires — one
/// for each of the newest saved works — each swinging gently on its own slow
/// beat — drawn in the soft, glossy 3D style of an
/// illustration: bevelled gold, a deep mat, a drop shadow, and a touch of
/// perspective as they turn.
///
/// [pictureKeys] mark each picture, so the covers that fly out of the card can
/// start from exactly where the picture is on screen.
class HangingFrames extends StatefulWidget {
  const HangingFrames({
    super.key,
    required this.sources,
    required this.pictureKeys,
    this.wall = false,
    this.onRemove,
    this.wallKey,
  });

  /// Wall only: called with the index of a frame the visitor has lifted off
  /// and dragged out of the wall. When null the frames can't be moved.
  final ValueChanged<int>? onRemove;

  /// Marks the wall's bounds, so a dragged frame knows when it has left it.
  final GlobalKey? wallKey;

  /// The larger, more ornate frames of the "Your wall" section: corner
  /// rosettes, a fine inner fillet, and a gloss that passes over the glass now
  /// and then.
  final bool wall;

  /// One to three pictures, newest first: a frame for each, no more.
  final List<ArtImageSource> sources;
  final List<GlobalKey> pictureKeys;

  /// The height the frames hang through, nails included.
  static const height = 92.0;

  /// Frame width at scale 1, and the most a frame may be scaled up for one,
  /// two or three of them (held back by the height available in the card).
  static const _baseWidth = 48.0;
  static const _maxScale = {1: 1.14, 2: 1.12, 3: .94};
  static const _gap = {1: 0.0, 2: 10.0, 3: 7.0};
  static const _wallMaxScale = {1: 1.75, 2: 1.75, 3: 1.7};
  static const _wallGap = {1: 0.0, 2: 30.0, 3: 24.0};

  @override
  State<HangingFrames> createState() => _HangingFramesState();
}

class _HangingFramesState extends State<HangingFrames>
    with TickerProviderStateMixin {
  /// One long loop; each frame swings an exact whole number of times in it, so
  /// the motion never jumps when it comes round.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  /// The frame being held (index), how far it has been pulled from its nail,
  /// and whether it is now outside the wall.
  int? _drag;
  Offset _dragOffset = Offset.zero;
  bool _outside = false;

  /// The short animation that follows a release: back to the nail, or away.
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  Offset _settleFrom = Offset.zero;
  Offset _settleTo = Offset.zero;
  bool _removing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The frames fit whatever width the card gives them — a narrow phone, a
    // wide one — scaling down to share it and centred in it.
    return LayoutBuilder(
      builder: (context, box) {
        final n = widget.sources.length.clamp(1, 3);
        final wall = widget.wall;
        final gap = (wall ? HangingFrames._wallGap : HangingFrames._gap)[n]!;
        final fit =
            (box.maxWidth - (n - 1) * gap) / (n * HangingFrames._baseWidth);
        final scale = math.min(
          (wall ? HangingFrames._wallMaxScale : HangingFrames._maxScale)[n]!,
          fit,
        );
        final frameW = HangingFrames._baseWidth * scale;
        final total = n * frameW + (n - 1) * gap;
        final start = (box.maxWidth - total) / 2;
        return SizedBox(
          width: box.maxWidth,
          height: wall
              ? (_HangingFrame._wire + 3 + _HangingFrame._frameH) * scale + 20
              : HangingFrames.height,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_c, _settle]),
              builder: (context, _) {
                // The held frame is drawn last, so it passes over the others.
                final order = [for (var i = 0; i < n; i++) i]
                  ..sort((a, b) => (a == _drag ? 1 : 0) - (b == _drag ? 1 : 0));
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final i in order)
                      _swing(
                        i,
                        scale: scale,
                        left: start + i * (frameW + gap),
                        beats: const [2, 3, 4][i],
                        phase: const [.0, .37, .71][i],
                        amount: const [.062, .05, .044][i],
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _swing(
    int i, {
    required double scale,
    required double left,
    required int beats,
    required double phase,
    required double amount,
  }) {
    final t = _c.value;
    final a = 2 * math.pi * (beats * t + phase);
    // A slow pendulum with a smaller, quicker wobble on top of it.
    final swing =
        amount * (math.sin(a) + .3 * math.sin((2 * beats + 1) * a / beats));
    // The frame also turns a little about its wire, which is what makes it
    // read as a solid object in space.
    final turn = .26 * math.sin(a + math.pi / 2) * (amount / .062);
    final source = widget.sources[i];
    final held = _drag == i;
    // A held frame hangs still, straight, in the hand.
    final frame = Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, .0018)
        ..rotateY(held ? 0 : turn)
        ..rotateZ(held ? (_dragOffset.dx * .0016).clamp(-.3, .3) : swing),
      child: _HangingFrame(
        source: source,
        pictureKey: widget.pictureKeys[i],
        scale: scale,
        wall: widget.wall,
        // The gloss crosses each frame once a loop, a little apart.
        shine: ((t * 2 + phase) % 1.0),
      ),
    );
    if (!widget.wall || widget.onRemove == null) {
      return Positioned(left: left, top: 0, child: frame);
    }

    // While held: lifted a little, and — once it is off the wall — shown going.
    var offset = held ? _dragOffset : Offset.zero;
    var lift = held ? 1.08 : 1.0;
    var fade = 1.0;
    if (held && _settle.isAnimating) {
      final k = Curves.easeOutCubic.transform(_settle.value);
      offset = Offset.lerp(_settleFrom, _settleTo, k)!;
      if (_removing) {
        lift = 1.08 - .3 * k;
        fade = 1 - k;
      } else {
        lift = 1.08 - .08 * k;
      }
    }
    return Positioned(
      left: left,
      top: 0,
      child: Opacity(
        opacity: fade,
        child: Transform.translate(
          offset: offset,
          child: Transform.scale(
            scale: lift,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPressStart: (_) => _lift(i),
              onLongPressMoveUpdate: (d) => _move(i, d.offsetFromOrigin),
              onLongPressEnd: (_) => _release(i),
              onLongPressCancel: () => _release(i),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Opacity(opacity: held && _outside ? .78 : 1, child: frame),
                  if (held && _outside)
                    Positioned(
                      top: 0,
                      right: -6,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8593F),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF5EFE5),
                            width: 1.5,
                          ),
                        ),
                        child: const ArtIcon(
                          ArtIcons.trash,
                          size: 14,
                          color: Color(0xFFF5EFE5),
                          strokeWidth: 1.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _lift(int i) {
    if (_drag != null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _drag = i;
      _dragOffset = Offset.zero;
      _outside = false;
      _removing = false;
    });
  }

  void _move(int i, Offset by) {
    if (_drag != i) return;
    setState(() => _dragOffset = by);
    // Has the frame's centre left the wall?
    final wall = widget.wallKey?.currentContext?.findRenderObject();
    final pic = widget.pictureKeys[i].currentContext?.findRenderObject();
    if (wall is! RenderBox || pic is! RenderBox) return;
    if (!wall.attached || !pic.attached || !wall.hasSize) return;
    final rect = wall.localToGlobal(Offset.zero) & wall.size;
    final centre = pic.localToGlobal(pic.size.center(Offset.zero));
    final out = !rect.contains(centre);
    if (out != _outside) {
      HapticFeedback.lightImpact();
      setState(() => _outside = out);
    }
  }

  /// Let go: off the wall, the frame goes; otherwise it swings back to its nail.
  void _release(int i) {
    if (_drag != i || _settle.isAnimating) return;
    _removing = _outside;
    _settleFrom = _dragOffset;
    final away = _dragOffset.distance == 0
        ? const Offset(0, 1)
        : _dragOffset / _dragOffset.distance;
    _settleTo = _removing ? _dragOffset + away * 120 : Offset.zero;
    if (_removing) HapticFeedback.heavyImpact();
    _settle.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      final removed = _removing;
      setState(() {
        _drag = null;
        _dragOffset = Offset.zero;
        _outside = false;
        _removing = false;
      });
      _settle.value = 0;
      if (removed) widget.onRemove?.call(i);
    });
  }
}

class _HangingFrame extends StatelessWidget {
  const _HangingFrame({
    required this.source,
    required this.pictureKey,
    required this.scale,
    this.wall = false,
    this.shine = 0,
  });

  final ArtImageSource? source;
  final GlobalKey pictureKey;
  final bool wall;

  /// 0–1 position of the gloss across the glass (wall only).
  final double shine;

  /// Everything below is drawn at this fraction of the base size.
  final double scale;

  static const _w = 48.0;
  static const _wire = 15.0;
  static const _frameH = 58.0;

  @override
  Widget build(BuildContext context) {
    final w = _w * scale;
    final wire = _wire * scale;
    final frameH = _frameH * scale;
    return SizedBox(
      width: w,
      height: wire + frameH + (wall ? 20 : 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WirePainter(wire: wire, scale: scale),
            ),
          ),
          Positioned(
            left: 0,
            top: wire + 3,
            width: w,
            height: frameH,
            child: _GildedFrame(
              source: source,
              pictureKey: pictureKey,
              scale: scale,
              wall: wall,
              shine: shine,
            ),
          ),
        ],
      ),
    );
  }
}

/// The nail and the two wires running down from it to the frame's top corners.
class _WirePainter extends CustomPainter {
  const _WirePainter({required this.wire, required this.scale});

  final double wire;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final nail = Offset(size.width / 2, 4);
    final top = wire + 3;
    final left = Offset(8 * scale, top);
    final right = Offset(size.width - 8 * scale, top);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF1D894), Color(0xFFB88C3E)],
      ).createShader(Offset.zero & size);
    // A faint shadow under each wire, then the wire itself.
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final end in [left, right]) {
      canvas.drawLine(
        nail + const Offset(0, 1.5),
        end + const Offset(0, 1.5),
        shadow,
      );
      canvas.drawLine(nail, end, line);
    }
    // The small rings the wires pass through on the frame.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFD9B46E);
    canvas.drawCircle(left, 2 * scale.clamp(.8, 1.1), ring);
    canvas.drawCircle(right, 2 * scale.clamp(.8, 1.1), ring);
    // The nail: a small domed head, lit from the top left.
    canvas.drawCircle(
      nail + const Offset(.6, 1.4),
      3.6,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );
    canvas.drawCircle(
      nail,
      3.4,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.4, -.5),
          colors: [Color(0xFFFFF0C4), Color(0xFFD9B46E), Color(0xFF7A5A22)],
          stops: [0, .5, 1],
        ).createShader(Rect.fromCircle(center: nail, radius: 3.4)),
    );
  }

  @override
  bool shouldRepaint(_WirePainter old) =>
      old.wire != wire || old.scale != scale;
}

class _GildedFrame extends StatelessWidget {
  const _GildedFrame({
    required this.source,
    required this.pictureKey,
    required this.scale,
    this.wall = false,
    this.shine = 0,
  });

  final ArtImageSource? source;
  final GlobalKey pictureKey;
  final double scale;
  final bool wall;
  final double shine;

  @override
  Widget build(BuildContext context) {
    final frame = _frame();
    if (!wall) return frame;
    // Corner rosettes: small domed studs at the four corners of the frame.
    final r = 2.1 * scale;
    Widget stud(Alignment a) => Align(
      alignment: a,
      child: Padding(
        padding: EdgeInsets.all(1.6 * scale),
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(-.4, -.5),
              colors: [Color(0xFFFFF3CF), Color(0xFFE2BC6A), Color(0xFF8A6A2C)],
              stops: [0, .5, 1],
            ),
            boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 1.5)],
          ),
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        frame,
        stud(Alignment.topLeft),
        stud(Alignment.topRight),
        stud(Alignment.bottomLeft),
        stud(Alignment.bottomRight),
      ],
    );
  }

  Widget _frame() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8E3A6),
            Color(0xFFD2A94F),
            Color(0xFF8E6A26),
            Color(0xFFE8C77C),
          ],
          stops: [0, .38, .7, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 8),
            blurRadius: 10,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      // The bevel: a darker channel inside the bright outer rim.
      padding: EdgeInsets.all(4 * scale.clamp(.8, 1.1)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.5),
          gradient: const LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [Color(0xFFF1D58C), Color(0xFF9A7430), Color(0xFF6B4D1C)],
            stops: [0, .5, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.8),
          child: ClipRRect(
            key: pictureKey,
            borderRadius: BorderRadius.circular(1.6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (source != null)
                  Image(
                    image: ResizeImage.resizeIfNeeded(
                      260,
                      null,
                      source!.provider(),
                    ),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  )
                else
                  const ColoredBox(
                    color: Color(0xFF2B2219),
                    child: Center(
                      child: ArtIcon(
                        ArtIcons.gallery,
                        size: 14,
                        color: Color(0xFFD9B46E),
                      ),
                    ),
                  ),
                // Depth: the picture sits back in the frame, shaded along the
                // top and left where the frame casts onto it, with a faint
                // gloss at the corner.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x66000000),
                        Color(0x00000000),
                        Color(0x1FFFFFFF),
                      ],
                      stops: [0, .45, 1],
                    ),
                  ),
                ),
                if (wall) ...[
                  // A fine fillet around the picture, like a slip of gilt.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0x55F1D894),
                        width: .8,
                      ),
                    ),
                  ),
                  // The gloss: a soft diagonal band that crosses the glass
                  // now and then.
                  LayoutBuilder(
                    builder: (context, c) {
                      final u = ((shine - .1) / .35).clamp(0.0, 1.0);
                      if (u <= 0 || u >= 1) return const SizedBox.shrink();
                      final fade = math.sin(u * math.pi);
                      return Transform.translate(
                        offset: Offset(
                          -c.maxWidth * .8 + c.maxWidth * 2.2 * u,
                          0,
                        ),
                        child: Transform.rotate(
                          angle: -.5,
                          child: SizedBox(
                            width: c.maxWidth * .34,
                            height: c.maxHeight * 1.8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0x00FFFFFF),
                                    Color.fromRGBO(255, 255, 255, .34 * fade),
                                    const Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
