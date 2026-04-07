import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

import '../providers/photo_provider.dart';
import '../theme/app_theme.dart';

class PhotoTimelineScreen extends StatefulWidget {
  const PhotoTimelineScreen({super.key});

  @override
  State<PhotoTimelineScreen> createState() => _PhotoTimelineScreenState();
}

class _PhotoTimelineScreenState extends State<PhotoTimelineScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhotoProvider>(context, listen: false).loadPhotos(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      Provider.of<PhotoProvider>(context, listen: false).loadPhotos();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showDateFilter(BuildContext context) async {
    final provider = Provider.of<PhotoProvider>(context, listen: false);
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: now,
      initialDateRange: provider.hasFilter
          ? DateTimeRange(
              start: provider.filterStart ?? DateTime(2010),
              end: provider.filterEnd ?? now,
            )
          : null,
      locale: const Locale('zh', 'CN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setDateFilter(
        start: picked.start,
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.warmGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterBar(),
            Expanded(
              child: Consumer<PhotoProvider>(
                builder: (context, photoProvider, _) {
                  if (!photoProvider.hasPermission && !photoProvider.isLoading) {
                    return _buildPermissionRequest(photoProvider);
                  }

                  if (photoProvider.isLoading && photoProvider.photos.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (photoProvider.photos.isEmpty) {
                    return _buildEmptyState(photoProvider);
                  }

                  return _buildPhotoTimeline(photoProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            '📸 照片时光轴',
            style: GoogleFonts.notoSansSc(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Provider.of<PhotoProvider>(context, listen: false).loadPhotos(refresh: true);
            },
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Consumer<PhotoProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showDateFilter(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.hasFilter
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.hasFilter ? AppColors.primary : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        size: 16,
                        color: provider.hasFilter ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.hasFilter
                            ? '${DateFormat('yy/M/d').format(provider.filterStart!)} - ${DateFormat('yy/M/d').format(provider.filterEnd!)}'
                            : '筛选时间',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                          color: provider.hasFilter ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: provider.hasFilter ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.hasFilter) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => provider.clearFilter(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          '清除',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (provider.photos.isNotEmpty)
                Text(
                  '${provider.photos.length} 张',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionRequest(PhotoProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text('📷', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '需要相册权限',
              style: GoogleFonts.notoSansSc(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请允许访问相册，以便浏览和管理宝宝的照片',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.requestPermission().then((_) {
                if (provider.hasPermission) {
                  provider.loadPhotos(refresh: true);
                }
              }),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('授权访问相册'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('正在加载照片...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(PhotoProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📷', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            provider.hasFilter ? '该时间段没有照片' : '还没有照片',
            style: GoogleFonts.notoSansSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.hasFilter ? '试试调整筛选范围' : '快去拍照记录宝宝的成长吧',
            style: GoogleFonts.notoSansSc(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          if (provider.hasFilter) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => provider.clearFilter(),
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('清除筛选'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoTimeline(PhotoProvider provider) {
    final photosByMonth = provider.photosByMonth;
    final months = photosByMonth.keys.toList();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: months.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= months.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final month = months[index];
        final photos = photosByMonth[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      month,
                      style: GoogleFonts.notoSansSc(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${photos.length}张',
                    style: GoogleFonts.notoSansSc(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, photoIndex) {
                return _PhotoThumbnail(
                  asset: photos[photoIndex],
                  onTap: () => _showPhotoDetail(context, photos, photoIndex),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showPhotoDetail(BuildContext context, List<AssetEntity> photos, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoDetailView(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onTap;

  const _PhotoThumbnail({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }
            return Container(
              color: AppColors.divider,
              child: const Center(
                child: Icon(Icons.image, color: AppColors.textLight, size: 24),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PhotoDetailView extends StatefulWidget {
  final List<AssetEntity> photos;
  final int initialIndex;

  const _PhotoDetailView({required this.photos, required this.initialIndex});

  @override
  State<_PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<_PhotoDetailView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          DateFormat('yyyy年M月d日 HH:mm').format(widget.photos[_currentIndex].createDateTime),
          style: GoogleFonts.notoSansSc(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List?>(
            future: widget.photos[index].thumbnailDataWithSize(
              const ThumbnailSize(1080, 1920),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.memory(snapshot.data!, fit: BoxFit.contain),
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          );
        },
      ),
    );
  }
}
