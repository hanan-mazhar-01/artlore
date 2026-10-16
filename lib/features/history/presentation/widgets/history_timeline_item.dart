import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_labels.dart';
import '../../../../core/widgets/art_image.dart';
import '../../../../core/widgets/editorial_text.dart';
import '../../../../core/widgets/tappable.dart';
import '../../../artwork/presentation/artwork_providers.dart';
import '../../domain/history_entry.dart';

const _shapes = [ArtShape.arch, ArtShape.soft, ArtShape.round, ArtShape.leaf];

/// One stop on the timeline with progressive editorial animation:
/// 1. Connecting line arrives at the node dot.
/// 2. Dot blossoms and artwork image unveils.
/// 3. Information is written out line-by-line (title, where, activity).
/// 4. Connecting line moves forward to the next stop.
class HistoryTimelineItem extends ConsumerStatefulWidget {
  const HistoryTimelineItem({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.shapeIndex,
  });

  final HistoryEntry entry;
  final bool isFirst;
  final bool isLast;
  final int shapeIndex;

  @override
  ConsumerState<HistoryTimelineItem> createState() =>
      _HistoryTimelineItemState();
}

class _HistoryTimelineItemState extends ConsumerState<HistoryTimelineItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  Animation<double>? _incomingAnim;
  late final Animation<double> _dotAnim;
  late final Animation<double> _dateAnim;
  late final Animation<double> _imageAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _whereAnim;
  late final Animation<double> _activityAnim;
  Animation<double>? _outgoingAnim;

  late final int _totalMs;

  @override
  void initState() {
    super.initState();
    _totalMs = _calcTotalMs();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
    _setupIntervals();
  }

  int _calcTotalMs() {
    if (widget.isFirst && widget.isLast) return 650;
    if (widget.isFirst) return 810;
    if (widget.isLast) return 750;
    return 960;
  }

  Animation<double> _anim(
    int startMs,
    int endMs, [
    Curve curve = Curves.easeOutCubic,
  ]) {
    final begin = (startMs / _totalMs).clamp(0.0, 1.0);
    final end = (endMs / _totalMs).clamp(begin, 1.0);
    return CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end, curve: curve),
    );
  }

  void _setupIntervals() {
    if (widget.isFirst) {
      _dotAnim = _anim(0, 110, Curves.easeOutBack);
      _dateAnim = _anim(60, 190);
      _imageAnim = _anim(120, 300);
      _titleAnim = _anim(280, 420);
      _whereAnim = _anim(390, 520);
      _activityAnim = _anim(490, 620);
      if (!widget.isLast) {
        _outgoingAnim = _anim(640, 810, Curves.easeInOutCubic);
      }
    } else {
      _incomingAnim = _anim(0, 160, Curves.easeInCubic);
      _dotAnim = _anim(150, 250, Curves.easeOutBack);
      _dateAnim = _anim(210, 340);
      _imageAnim = _anim(250, 430);
      _titleAnim = _anim(410, 550);
      _whereAnim = _anim(520, 650);
      _activityAnim = _anim(620, 750);
      if (!widget.isLast) {
        _outgoingAnim = _anim(780, 960, Curves.easeInOutCubic);
      }
    }
  }

  // Each item is lazily built by SliverList as it nears the viewport, so
  // starting the animation immediately on build already reveals items in
  // step with scrolling — no artificial per-item delay needed. (A fixed
  // index-based delay here previously meant an item's reveal was scheduled
  // against a global clock from screen-load, not against when it actually
  // scrolled into view — so scrolling ahead of that schedule just showed a
  // stalled item until its turn came up.)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status != AnimationStatus.dismissed) return;
    if (AppMotion.reduced(context)) {
      _c.value = 1.0;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final artwork = ref.watch(artworkProvider(widget.entry.artworkId)).value;
    final ring = widget.isFirst ? p.accent : p.muted;
    final activeLine = widget.isFirst
        ? p.accent.withValues(alpha: .65)
        : p.line(.28);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final inVal = _incomingAnim?.value ?? 1.0;
        final dotVal = _dotAnim.value;
        final dateVal = _dateAnim.value;
        final imageVal = _imageAnim.value;
        final titleVal = _titleAnim.value;
        final whereVal = _whereAnim.value;
        final activityVal = _activityAnim.value;
        final outVal = _outgoingAnim?.value ?? 0.0;

        return Stack(
          children: [
            // Faint background track
            Positioned(
              left: 7,
              top: widget.isFirst ? 35.5 : 0,
              bottom: widget.isLast ? null : 0,
              height: widget.isLast ? 35.5 : null,
              width: 1,
              child: ColoredBox(color: p.line(.06)),
            ),

            // Incoming line: draws down from top into dot
            if (!widget.isFirst && inVal > 0)
              Positioned(
                left: 7,
                top: 0,
                height: 35.5 * inVal,
                width: 1,
                child: ColoredBox(color: activeLine),
              ),

            // Outgoing line: moves forward towards next item
            if (!widget.isLast && outVal > 0)
              Positioned(
                left: 7,
                top: 35.5,
                bottom: 0,
                width: 1,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: outVal,
                    child: ColoredBox(color: activeLine),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: dotVal.clamp(0.0, 1.0),
                        child: Opacity(
                          opacity: dotVal.clamp(0.0, 1.0),
                          child: Container(
                            width: 15,
                            height: 15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: p.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: ring),
                            ),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: ring,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: _WrittenLine(
                          progress: dateVal,
                          child: GoldLabel(
                            DateLabels.relative(widget.entry.at),
                            tracking: .24,
                            color: ring,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (artwork != null)
                    IgnorePointer(
                      ignoring: activityVal < 0.5,
                      child: Tappable(
                        onTap: () => context.openArtwork(artwork.id),
                        semanticLabel: artwork.semanticLabel,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, top: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Opacity(
                                opacity: imageVal.clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: 0.88 + 0.12 * imageVal.clamp(0.0, 1.0),
                                  child: SizedBox(
                                    width: 74,
                                    height: 90,
                                    child: ArtImage(
                                      artwork.image,
                                      radius:
                                          _shapes[widget.shapeIndex %
                                                  _shapes.length]
                                              .radius,
                                      alignment: artwork.heroFocus,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _WrittenLine(
                                        progress: titleVal,
                                        child: Text(
                                          artwork.title,
                                          style: AppTypography.serif(
                                            21,
                                            height: 1.05,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _WrittenLine(
                                        progress: whereVal,
                                        child: Text(
                                          widget.entry.where,
                                          style: AppTypography.metadata
                                              .copyWith(color: p.muted),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _WrittenLine(
                                        progress: activityVal,
                                        child: Text(
                                          widget.entry.activity,
                                          style: AppTypography.caption.copyWith(
                                            color: p.ink.withValues(alpha: .75),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Editorial line-by-line reveal: unrolls from left to right like pen strokes,
/// while keeping child text layout stable without re-wrapping jitter.
class _WrittenLine extends StatelessWidget {
  const _WrittenLine({required this.progress, required this.child});

  final double progress;
  final Widget child;

  static const double _slideDistance = 8.0;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(_slideDistance * (1.0 - p), 0),
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: math.max(0.001, p),
                child: SizedBox(
                  width: constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : null,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
