import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Where an artwork image lives. Today: bundled assets. Later: CDN URLs from
/// the backend — widgets don't change, only the repository data does.
@immutable
class ArtImageSource {
  const ArtImageSource.asset(
    String this.asset, {
    required this.aspect,
    this.hdAsset,
  }) : url = null,
       bytes = null;

  const ArtImageSource.network(String this.url, {required this.aspect})
    : asset = null,
      bytes = null,
      hdAsset = null;

  const ArtImageSource.memory(Uint8List this.bytes, {this.aspect = 1.0})
    : asset = null,
      url = null,
      hdAsset = null;

  final String? asset;
  final String? url;
  final Uint8List? bytes;

  /// Larger rendition for deep zoom (Look Closer).
  final String? hdAsset;

  /// Width ÷ height of the source image.
  final double aspect;

  ImageProvider provider({bool hd = false}) {
    if (bytes != null) return MemoryImage(bytes!);
    if (url != null) return NetworkImage(url!);
    return AssetImage(hd && hdAsset != null ? hdAsset! : asset!);
  }

  @override
  bool operator ==(Object other) =>
      other is ArtImageSource &&
      other.asset == asset &&
      other.url == url &&
      other.hdAsset == hdAsset &&
      (bytes == null && other.bytes == null ||
          bytes != null &&
              other.bytes != null &&
              listEquals(bytes, other.bytes));

  @override
  int get hashCode => Object.hash(asset, url, hdAsset, bytes?.length);
}
