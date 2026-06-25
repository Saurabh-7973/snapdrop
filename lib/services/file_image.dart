import 'package:photo_manager/photo_manager.dart';

class FileImageServices {
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

  Future<double> getTotalImageSize(List<AssetEntity> selectedAssetList) async {
    // Reuses the per-asset cache, so summing the selected set is instant once
    // their labels have resolved — the <=5 MB guard no longer recomputes.
    final sizes = await Future.wait(
        selectedAssetList.map((a) async => double.parse(await getImageSize(a))));
    return sizes.fold<double>(0.0, (sum, s) => sum + s);
  }
}
