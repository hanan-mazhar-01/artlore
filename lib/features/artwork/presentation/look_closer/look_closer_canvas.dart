import 'package:flutter/widgets.dart';

import '../../../../core/widgets/art_image.dart';
import '../../domain/artwork.dart';
import '../../domain/artwork_content.dart';
import 'detail_marker.dart';
import 'look_closer_camera.dart';

/// The zoomable canvas with its numbered details.
class LookCloserCanvas extends StatelessWidget {
  const LookCloserCanvas({
    super.key,
    required this.artwork,
    required this.details,
    required this.camera,
    required this.controller,
    required this.zoom,
    required this.pulse,
    required this.selected,
    required this.showAllMarkers,
    required this.onPick,
    required this.onInteractionStart,
  });

  final Artwork artwork;
  final List<ArtworkDetail> details;
  final LookCloserCamera camera;
  final TransformationController controller;
  final ValueNotifier<double> zoom;
  final Animation<double> pulse;
  final int? selected;
  final bool showAllMarkers;
  final ValueChanged<int> onPick;
  final VoidCallback onInteractionStart;

  @override
  Widget build(BuildContext context) {
    final size = camera.canvas;
    const half = DetailMarker.size / 2;
    return InteractiveViewer(
      transformationController: controller,
      constrained: false,
      minScale: 1,
      maxScale: 4,
      clipBehavior: Clip.hardEdge,
      onInteractionStart: (_) => onInteractionStart(),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: ArtImage(
                  artwork.image,
                  hd: true,
                  fit: BoxFit.fill,
                  decodeScale: 1.6,
                  semanticLabel: artwork.semanticLabel,
                ),
              ),
            ),
            for (var i = 0; i < details.length; i++)
              if (showAllMarkers || selected == i)
                Positioned(
                  left: details[i].x * size.width - half,
                  top: details[i].y * size.height - half,
                  width: DetailMarker.size,
                  height: DetailMarker.size,
                  child: DetailMarker(
                    number: (i + 1).toString().padLeft(2, '0'),
                    label: details[i].title,
                    active: selected == i,
                    zoom: zoom,
                    pulse: pulse,
                    onTap: () => onPick(i),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
