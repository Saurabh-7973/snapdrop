import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class FileImageServices {
  // The relay caps a single socket.io message at maxHttpBufferSize = 1e7 bytes
  // (10 MB) and each image is sent as its own emit, so the real limit is
  // PER IMAGE, not total. 9 MiB (9_437_184 bytes) leaves headroom under 1e7 for
  // the JSON wrapper + socket.io framing. Tune here if the relay config changes.
  static const double maxImageSizeMb = 9.0;

  // Resolution ceiling for sending. 3072px long-edge is the product balance:
  // above any 2x-retina screen/Figma placement (and most zoom) so quality reads
  // as lossless, while still downscaling the 4000px+ phone photos that dominate
  // transfer weight (~1.5-2x faster). Images within this send as untouched
  // originals; larger ones downscale at JPEG q95. 2560 = faster, 4096 = max
  // quality / ~no speedup.
  static const int maxSendEdgePx = 3072;

  static const MethodChannel _imageChannel = MethodChannel('snapdrop/image');

  // Reading a picked file's length was being recomputed on every rebuild for
  // each selected tile. Cache the formatted MB string per path: the first read
  // pays the cost, every later label/guard read is instant.
  static final Map<String, String> _sizeCache = {};

  Future<String> getImageSize(XFile file) async {
    final cached = _sizeCache[file.path];
    if (cached != null) return cached;

    String size = '0.0';
    try {
      final length = await file.length();
      size = (length / (1024 * 1024)).toStringAsFixed(2);
    } catch (_) {
      // Unreadable file: report 0 and let the send path skip it.
    }
    _sizeCache[file.path] = size;
    return size;
  }

  /// Largest single image in the set (MiB). This is what the transport actually
  /// limits — each image is one emit and must fit the relay's per-message cap.
  Future<double> getMaxImageSize(List<XFile> selected) async {
    if (selected.isEmpty) return 0.0;
    final sizes = await Future.wait(
        selected.map((f) async => double.parse(await getImageSize(f))));
    return sizes.reduce((a, b) => a > b ? a : b);
  }

  /// JPEG bytes downscaled to [maxSendEdgePx] when the image is larger than
  /// that, or null when it already fits and should go as the original.
  static Future<Uint8List?> downscaleIfLarger(String path) {
    return _imageChannel.invokeMethod<Uint8List>('downscaleIfLarger', {
      'path': path,
      'maxEdge': maxSendEdgePx,
      'quality': 95,
    });
  }
}
