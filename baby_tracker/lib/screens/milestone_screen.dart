import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/baby_provider.dart';
import '../models/milestone.dart';
import '../theme/app_theme.dart';

class MilestoneScreen extends StatelessWidget {
  const MilestoneScreen({super.key});

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
              child: Consumer<BabyProvider>(
                builder: (context, provider, _) {
                  if (provider.milestones.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildMilestoneTimeline(context, provider);
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
            '🏆 成长里程碑',
            style: GoogleFonts.notoSansSc(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddMilestoneSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加'),
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
          const Text('🌟', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            '还没有里程碑记录',
            style: GoogleFonts.notoSansSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '记录宝宝每一个珍贵的第一次',
            style: GoogleFonts.notoSansSc(fontSize: 14, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTimeline(BuildContext context, BabyProvider provider) {
    final milestones = provider.milestones;
    final colorList = [
      AppColors.babyPink,
      AppColors.babyBlue,
      AppColors.peach,
      AppColors.lavender,
      AppColors.mintGreen,
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final color = colorList[index % colorList.length];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (index < milestones.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.divider,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
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
                          Text(milestone.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  milestone.title,
                                  style: GoogleFonts.notoSansSc(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormat('yyyy年M月d日').format(milestone.date),
                                  style: GoogleFonts.notoSansSc(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCategoryChip(milestone.category),
                        ],
                      ),
                      if (milestone.description != null &&
                          milestone.description!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          milestone.description!,
                          style: GoogleFonts.notoSansSc(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    final categoryMap = {
      'first': {'label': '第一次', 'color': AppColors.babyPink},
      'motor': {'label': '运动', 'color': AppColors.babyBlue},
      'language': {'label': '语言', 'color': AppColors.peach},
      'social': {'label': '社交', 'color': AppColors.lavender},
      'growth': {'label': '成长', 'color': AppColors.mintGreen},
      'health': {'label': '健康', 'color': AppColors.accent},
    };

    final info = categoryMap[category] ?? {'label': category, 'color': AppColors.textLight};
    final color = info['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        info['label'] as String,
        style: GoogleFonts.notoSansSc(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showAddMilestoneSheet(BuildContext context) {
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedTitle;
    String selectedIcon = '⭐';
    String selectedCategory = 'first';
    final predefined = Milestone.predefinedMilestones;

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
                      '🏆 添加里程碑',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '选择里程碑',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: predefined.length,
                        itemBuilder: (context, index) {
                          final item = predefined[index];
                          final isSelected = selectedTitle == item['title'];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedTitle = item['title']!;
                                selectedIcon = item['icon']!;
                                selectedCategory = item['category']!;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item['icon']!, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['title']!,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.notoSansSc(
                                      fontSize: 10,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: '描述（选填）',
                        labelStyle: GoogleFonts.notoSansSc(fontSize: 14),
                        hintText: '记录这个特别的时刻...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedTitle == null
                            ? null
                            : () {
                                Provider.of<BabyProvider>(context, listen: false).addMilestone(
                                  title: selectedTitle!,
                                  description: descController.text.isNotEmpty
                                      ? descController.text
                                      : null,
                                  date: selectedDate,
                                  category: selectedCategory,
                                  icon: selectedIcon,
                                );
                                Navigator.pop(context);
                              },
                        child: const Text('保存'),
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
