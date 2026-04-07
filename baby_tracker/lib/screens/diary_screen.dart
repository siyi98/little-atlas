import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/baby_provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../theme/app_theme.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
      if (baby != null) {
        Provider.of<DiaryProvider>(context, listen: false).loadEntries(baby.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.warmGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<DiaryProvider>(
                builder: (context, provider, _) {
                  if (provider.entries.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildDiaryList(provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            '📝 成长日记',
            style: GoogleFonts.notoSansSc(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddDiarySheet(context),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('写日记'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            '还没有日记',
            style: GoogleFonts.notoSansSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '用文字记录宝宝的点滴故事',
            style: GoogleFonts.notoSansSc(fontSize: 14, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryList(DiaryProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: provider.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.entries[index];
        return _buildDiaryCard(context, entry, provider);
      },
    );
  }

  Widget _buildDiaryCard(BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    final weatherIcons = {
      'sunny': '☀️',
      'cloudy': '⛅',
      'rainy': '🌧️',
      'snowy': '❄️',
      'windy': '💨',
    };

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这篇日记吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteEntry(entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('M月d日').format(entry.date),
                    style: GoogleFonts.notoSansSc(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE', 'zh_CN').format(entry.date),
                  style: GoogleFonts.notoSansSc(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                if (entry.weather != null)
                  Text(
                    weatherIcons[entry.weather] ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                if (entry.mood != null) ...[
                  const SizedBox(width: 4),
                  Text(entry.mood!, style: const TextStyle(fontSize: 18)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.content,
              style: GoogleFonts.notoSansSc(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.8,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            if (entry.photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.photos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: AppColors.textLight),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddDiarySheet(BuildContext context) {
    final contentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedMood;
    String? selectedWeather;

    final moods = ['😊', '😍', '😂', '🥰', '😴', '😢', '😡', '🤔', '😋', '🤗'];
    final weathers = [
      {'icon': '☀️', 'value': 'sunny', 'label': '晴'},
      {'icon': '⛅', 'value': 'cloudy', 'label': '多云'},
      {'icon': '🌧️', 'value': 'rainy', 'label': '雨'},
      {'icon': '❄️', 'value': 'snowy', 'label': '雪'},
      {'icon': '💨', 'value': 'windy', 'label': '风'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '📝 写成长日记',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2010),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('yyyy年M月d日').format(selectedDate),
                              style: GoogleFonts.notoSansSc(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '心情',
                      style: GoogleFonts.notoSansSc(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: moods.map((mood) {
                        final isSelected = selectedMood == mood;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedMood = isSelected ? null : mood;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(mood, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '天气',
                      style: GoogleFonts.notoSansSc(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: weathers.map((w) {
                        final isSelected = selectedWeather == w['value'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedWeather = isSelected ? null : w['value'] as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(w['icon'] as String, style: const TextStyle(fontSize: 20)),
                                  Text(
                                    w['label'] as String,
                                    style: GoogleFonts.notoSansSc(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: '记录宝宝今天的故事...',
                          hintStyle: GoogleFonts.notoSansSc(
                            color: AppColors.textLight,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (contentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入日记内容')),
                            );
                            return;
                          }

                          final baby =
                              Provider.of<BabyProvider>(context, listen: false).currentBaby;
                          if (baby == null) return;

                          Provider.of<DiaryProvider>(context, listen: false).addEntry(
                            babyId: baby.id,
                            date: selectedDate,
                            content: contentController.text.trim(),
                            mood: selectedMood,
                            weather: selectedWeather,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('保存日记'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
