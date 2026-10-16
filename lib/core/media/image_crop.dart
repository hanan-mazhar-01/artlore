import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Rect, Size;
import 'package:image/image.dart' as img;

/// Crops JPEG [bytes] to [targetAspectRatio] (width / height), center-cropped
/// the same way `BoxFit.cover` windows an image — so a captured photo
/// matches exactly what was visible inside an on-screen viewfinder frame of
/// that ratio, rather than the camera's full (usually wider) sensor output.
///
/// Runs off the UI thread; returns the original bytes unchanged if decoding
/// fails.
///
/// When the on-screen preview is itself a crop of the camera (its aspect
/// differs from the photo's), pass its aspect as [previewAspectRatio]: the
/// photo is first cut to what the preview shows, then to the frame — so the
/// result is exactly what lay inside the frame, no more.
Future<Uint8List> cropToAspectRatio(
  Uint8List bytes,
  double targetAspectRatio, {
  double? previewAspectRatio,
}) {
  return compute(
    _cropSync,
    _CropArgs(bytes, targetAspectRatio, previewAspectRatio),
  );
}

class _CropArgs {
  const _CropArgs(this.bytes, this.targetAspectRatio, this.previewAspectRatio);
  final Uint8List bytes;
  final double targetAspectRatio;
  final double? previewAspectRatio;
}

Uint8List _cropSync(_CropArgs args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) return args.bytes;

  // Normalize EXIF rotation into actual pixel data first, so crop math
  // works against the image as the user actually saw it.
  var oriented = img.bakeOrientation(decoded);
  final preview = args.previewAspectRatio;
  if (preview != null) oriented = _centerCrop(oriented, preview);
  final cropped = _centerCrop(oriented, args.targetAspectRatio);
  return Uint8List.fromList(img.encodeJpg(cropped, quality: 92));
}

/// [source] cut to [ratio] (width / height) about its centre, as
/// `BoxFit.cover` would window it.
img.Image _centerCrop(img.Image source, double ratio) {
  final sourceAspect = source.width / source.height;
  int cropWidth;
  int cropHeight;
  if (sourceAspect > ratio) {
    cropHeight = source.height;
    cropWidth = (source.height * ratio).round();
  } else {
    cropWidth = source.width;
    cropHeight = (source.width / ratio).round();
  }
  return img.copyCrop(
    source,
    x: ((source.width - cropWidth) / 2).round(),
    y: ((source.height - cropHeight) / 2).round(),
    width: cropWidth,
    height: cropHeight,
  );
}

/// Crops JPEG [bytes] — a camera photo shown full-screen with `BoxFit.cover`
/// in a box of [viewSize] — to the part that lay under [frame] (a rectangle in
/// that box's own coordinates). The result is exactly what was between the
/// scanning corners.
Future<Uint8List> cropToFrame(
  Uint8List bytes, {
  required Size viewSize,
  required Rect frame,
}) {
  return compute(
    _frameSync,
    _FrameArgs(bytes, viewSize.width, viewSize.height, frame),
  );
}

class _FrameArgs {
  const _FrameArgs(this.bytes, this.viewW, this.viewH, this.frame);
  final Uint8List bytes;
  final double viewW;
  final double viewH;
  final Rect frame;
}

Uint8List _frameSync(_FrameArgs a) {
  final decoded = img.decodeImage(a.bytes);
  if (decoded == null) return a.bytes;
  final photo = img.bakeOrientation(decoded);
  final pw = photo.width.toDouble();
  final ph = photo.height.toDouble();

  // BoxFit.cover: the photo is scaled until it fills the box, and centred.
  final k = a.viewW / pw > a.viewH / ph ? a.viewW / pw : a.viewH / ph;
  final ox = (a.viewW - pw * k) / 2;
  final oy = (a.viewH - ph * k) / 2;

  final left = ((a.frame.left - ox) / k).clamp(0.0, pw - 1);
  final top = ((a.frame.top - oy) / k).clamp(0.0, ph - 1);
  final right = ((a.frame.right - ox) / k).clamp(left + 1, pw);
  final bottom = ((a.frame.bottom - oy) / k).clamp(top + 1, ph);

  final cropped = img.copyCrop(
    photo,
    x: left.round(),
    y: top.round(),
    width: (right - left).round(),
    height: (bottom - top).round(),
  );
  return Uint8List.fromList(img.encodeJpg(cropped, quality: 92));
}
