import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Crops JPEG [bytes] to [targetAspectRatio] (width / height), center-cropped
/// the same way `BoxFit.cover` windows an image — so a captured photo
/// matches exactly what was visible inside an on-screen viewfinder frame of
/// that ratio, rather than the camera's full (usually wider) sensor output.
///
/// Runs off the UI thread; returns the original bytes unchanged if decoding
/// fails.
Future<Uint8List> cropToAspectRatio(
  Uint8List bytes,
  double targetAspectRatio,
) {
  return compute(_cropSync, _CropArgs(bytes, targetAspectRatio));
}

class _CropArgs {
  const _CropArgs(this.bytes, this.targetAspectRatio);
  final Uint8List bytes;
  final double targetAspectRatio;
}

Uint8List _cropSync(_CropArgs args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) return args.bytes;

  // Normalize EXIF rotation into actual pixel data first, so crop math
  // works against the image as the user actually saw it.
  final oriented = img.bakeOrientation(decoded);

  final sourceAspect = oriented.width / oriented.height;
  int cropWidth;
  int cropHeight;
  if (sourceAspect > args.targetAspectRatio) {
    // Source is relatively wider than the frame — crop the left/right
    // edges, keep full height (matches BoxFit.cover scaling by height).
    cropHeight = oriented.height;
    cropWidth = (oriented.height * args.targetAspectRatio).round();
  } else {
    // Source is relatively taller/narrower — crop top/bottom, keep full
    // width (matches BoxFit.cover scaling by width).
    cropWidth = oriented.width;
    cropHeight = (oriented.width / args.targetAspectRatio).round();
  }
  final offsetX = ((oriented.width - cropWidth) / 2).round();
  final offsetY = ((oriented.height - cropHeight) / 2).round();

  final cropped = img.copyCrop(
    oriented,
    x: offsetX,
    y: offsetY,
    width: cropWidth,
    height: cropHeight,
  );
  return Uint8List.fromList(img.encodeJpg(cropped, quality: 92));
}
