import 'package:photo_manager/photo_manager.dart';

class MediaProviderServices {
  // One grid page ≈ 10 rows in a 3-col grid. Small enough that the first screen
  // paints almost instantly on a large library; the rest streams in on scroll.
  static const int pageSize = 90;

  Future<List<AssetPathEntity>> loadAlbums(bool hasAll) async {
    return PhotoManager.getAssetPathList(
        type: RequestType.image, hasAll: hasAll);
  }

  /// Loads a single page of an album. Paged (vs the whole roll at once) so a
  /// big library doesn't block on resolving thousands of AssetEntity up front.
  Future<List<AssetEntity>> loadAssetPage(AssetPathEntity album, int page,
      {int size = pageSize}) {
    return album.getAssetListPaged(page: page, size: size);
  }

  static Future<int> getAssetCount(AssetPathEntity selectedAlbum) async {
    return selectedAlbum.assetCountAsync;
  }
}
