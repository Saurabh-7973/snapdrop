import 'package:photo_manager/photo_manager.dart';

class FileImageServices {
  // The relay caps a single socket.io message at maxHttpBufferSize = 1e7 bytes
  // (10 MB) and each image is sent as its own emit, so the real limit is
  // PER IMAGE, not total. 9 MiB (9_437_184 bytes) leaves headroom under 1e7 for
  // the JSON wrapper + socket.io framing. Tune here if the relay config changes.
  static const double maxImageSizeMb = 9.0;

  // Resolution ceiling for sending. 4096px long-edge keeps full headroom for
  // print/extreme-zoom work (well above any screen/Figma display need). Images
  // already within this send as untouched originals; only larger ones downscale
  // (JPEG q95) to cut transfer weight. Lower to 2560 if pure screen design and
  // you want max speed.
  static const int maxSendEdgePx = 4096;

  // Resolving AssetEntity.file (and reading its length) is comparatively heavy
  // and was being recomputed on every grid rebuild for each selected tile.
  // Cache the formatted MB string per asset id: the first read pays the cost,
  // every later label/guard read is instant. Sizes don't change for an asset.
  static final Map<String, String> _sizeCache = {};

  Future<String> getImageSize(AssetEntity assetFile) async {
    final cached = _sizeCache[assetFile.id];
    if (cached != null) return cached;

    String size = '0.0';
    final file = await assetFile.file;
    if (file != null) {
      final length = await file.length();
      size = (length / (1024 * 1024)).toStringAsFixed(2);
    }
    _sizeCache[assetFile.id] = size;
    return size;
  }

  /// Largest single image in the set (MiB). This is what the transport actually
  /// limits — each image is one emit and must fit the relay's per-message cap.
  Future<double> getMaxImageSize(List<AssetEntity> selectedAssetList) async {
    if (selectedAssetList.isEmpty) return 0.0;
    final sizes = await Future.wait(
        selectedAssetList.map((a) async => double.parse(await getImageSize(a))));
    return sizes.reduce((a, b) => a > b ? a : b);
  }

  Future<double> getTotalImageSize(List<AssetEntity> selectedAssetList) async {
    // Reuses the per-asset cache, so summing the selected set is instant once
    // their labels have resolved — the <=5 MB guard no longer recomputes.
    final sizes = await Future.wait(
        selectedAssetList.map((a) async => double.parse(await getImageSize(a))));
    return sizes.fold<double>(0.0, (sum, s) => sum + s);
  }
}
