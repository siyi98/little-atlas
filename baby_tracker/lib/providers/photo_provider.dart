import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoProvider extends ChangeNotifier {
  List<AssetEntity> _photos = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  int _currentPage = 0;
  bool _hasMore = true;
  static const int _pageSize = 50;

  DateTime? _filterStart;
  DateTime? _filterEnd;

  List<AssetEntity> get photos => _photos;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  bool get hasMore => _hasMore;
  DateTime? get filterStart => _filterStart;
  DateTime? get filterEnd => _filterEnd;
  bool get hasFilter => _filterStart != null || _filterEnd != null;

  Map<String, List<AssetEntity>> get photosByMonth {
    final Map<String, List<AssetEntity>> grouped = {};
    for (final photo in _photos) {
      final key = '${photo.createDateTime.year}年${photo.createDateTime.month}月';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(photo);
    }
    return grouped;
  }

  void setDateFilter({DateTime? start, DateTime? end}) {
    _filterStart = start;
    _filterEnd = end;
    loadPhotos(refresh: true);
  }

  void clearFilter() {
    _filterStart = null;
    _filterEnd = null;
    loadPhotos(refresh: true);
  }

  Future<bool> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    _hasPermission = ps.isAuth || ps.hasAccess;
    notifyListeners();
    return _hasPermission;
  }

  Future<void> loadPhotos({bool refresh = false}) async {
    if (_isLoading) return;
    if (!_hasPermission) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    if (refresh) {
      _currentPage = 0;
      _photos.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final filterGroup = FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
        createTimeCond: DateTimeCond(
          min: _filterStart ?? DateTime(2000),
          max: _filterEnd ?? DateTime.now(),
        ),
      );

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: filterGroup,
      );

      if (albums.isEmpty) {
        _isLoading = false;
        _hasMore = false;
        notifyListeners();
        return;
      }

      final AssetPathEntity recentAlbum = albums.first;
      final int totalCount = await recentAlbum.assetCountAsync;

      final List<AssetEntity> assets = await recentAlbum.getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      _photos.addAll(assets);
      _currentPage++;
      _hasMore = _photos.length < totalCount;
    } catch (e) {
      debugPrint('Error loading photos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Uint8List?> getThumbnail(AssetEntity asset, {int width = 200, int height = 200}) async {
    return await asset.thumbnailDataWithSize(ThumbnailSize(width, height));
  }
}
