import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/baby_provider.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/edit_baby_screen.dart';
import '../screens/milestone_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, _) {
        final baby = babyProvider.currentBaby;
        if (baby == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, baby, babyProvider)),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(child: _buildRecentMilestones(context, babyProvider)),
            SliverToBoxAdapter(child: _buildGrowthSummary(context, babyProvider)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic baby, BabyProvider babyProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Little Atlas',
                    style: GoogleFonts.notoSansSc(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (babyProvider.babies.length > 1)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.swap_horiz, color: Colors.white),
                      onSelected: (id) {
                        final selected = babyProvider.babies.firstWhere((b) => b.id == id);
                        babyProvider.setCurrentBaby(selected);
                      },
                      itemBuilder: (context) => babyProvider.babies
                          .map((b) => PopupMenuItem(value: b.id, child: Text(b.name)))
                          .toList(),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditBabyScreen(baby: baby)),
                  );
                },
                child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: baby.avatarPath != null && File(baby.avatarPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(File(baby.avatarPath!), fit: BoxFit.cover, width: 80, height: 80),
                          )
                        : Center(
                            child: Text(
                              baby.gender == 'boy' ? '👦' : '👧',
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              baby.name,
                              style: GoogleFonts.notoSansSc(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_rounded, color: Colors.white.withOpacity(0.7), size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${baby.ageText} · ${DateFormat('yyyy年M月d日').format(baby.birthday)}出生',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '已陪伴 ${baby.ageInDays} 天 💕',
                            style: GoogleFonts.notoSansSc(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': '🍼', 'label': '日常记录', 'color': AppColors.babyPink, 'index': 1},
      {'icon': '📸', 'label': '照片相册', 'color': AppColors.babyBlue, 'index': 2},
      {'icon': '📏', 'label': '成长曲线', 'color': AppColors.peach, 'index': 3},
      {'icon': '📝', 'label': '写日记', 'color': AppColors.lavender, 'index': 4},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '快捷操作',
            style: GoogleFonts.notoSansSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: actions.map((action) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final homeState = context.findAncestorStateOfType<HomeScreenState>();
                    homeState?.switchTab(action['index'] as int);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            action['icon'] as String,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMilestones(BuildContext context, BabyProvider babyProvider) {
    final milestones = babyProvider.milestones.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近里程碑',
                style: GoogleFonts.notoSansSc(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (milestones.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MilestoneScreen()));
                  },
                  child: Text(
                    '查看全部',
                    style: GoogleFonts.notoSansSc(fontSize: 14, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (milestones.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text('还没有记录里程碑',
                      style: GoogleFonts.notoSansSc(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('记录宝宝的每一个第一次吧',
                      style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            )
          else
            ...milestones.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                  child: Row(
                    children: [
                      Text(m.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title,
                                style: GoogleFonts.notoSansSc(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            Text(DateFormat('yyyy年M月d日').format(m.date),
                                style: GoogleFonts.notoSansSc(
                                    fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textLight),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildGrowthSummary(BuildContext context, BabyProvider babyProvider) {
    final records = babyProvider.growthRecords;
    final latestRecord = records.isNotEmpty ? records.last : null;
    final baby = babyProvider.currentBaby;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '成长概览',
            style: GoogleFonts.notoSansSc(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '身高',
                  latestRecord?.height != null
                      ? '${latestRecord!.height} cm'
                      : baby?.birthHeight != null
                          ? '${baby!.birthHeight} cm'
                          : '--',
                  Icons.straighten,
                  AppColors.babyBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '体重',
                  latestRecord?.weight != null
                      ? '${latestRecord!.weight} kg'
                      : baby?.birthWeight != null
                          ? '${baby!.birthWeight} kg'
                          : '--',
                  Icons.monitor_weight_outlined,
                  AppColors.babyPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '头围',
                  latestRecord?.headCircumference != null
                      ? '${latestRecord!.headCircumference} cm'
                      : '--',
                  Icons.circle_outlined,
                  AppColors.peach,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.notoSansSc(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
