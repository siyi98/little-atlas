import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/baby_provider.dart';
import '../providers/daily_care_provider.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/vaccination.dart';
import '../theme/app_theme.dart';

class DailyCareScreen extends StatefulWidget {
  const DailyCareScreen({super.key});

  @override
  State<DailyCareScreen> createState() => _DailyCareScreenState();
}

class _DailyCareScreenState extends State<DailyCareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
      if (baby != null) {
        Provider.of<DailyCareProvider>(context, listen: false).loadAll(baby.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.warmGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                '🍼 日常记录',
                style: GoogleFonts.notoSansSc(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            _buildSummaryCards(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FeedingTab(),
                  _SleepTab(),
                  _VaccinationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<DailyCareProvider>(
      builder: (context, provider, _) {
        final sleepHours = provider.todaySleepMinutes / 60;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _summaryCard('🍼', '今日喂养', '${provider.todayFeedingCount}次', AppColors.babyPink)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('😴', '今日睡眠', '${sleepHours.toStringAsFixed(1)}h', AppColors.babyBlue)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('💉', '已接种', '${provider.completedVaccinationIds.length}针', AppColors.mintGreen)),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.notoSansSc(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: GoogleFonts.notoSansSc(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
        indicatorSize: TabBarIndicatorSize.tab,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        labelStyle: GoogleFonts.notoSansSc(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.notoSansSc(fontSize: 14),
        tabs: const [Tab(text: '喂养'), Tab(text: '睡眠'), Tab(text: '疫苗')],
      ),
    );
  }
}

// ======================== Feeding Tab ========================
class _FeedingTab extends StatelessWidget {
  void _showAddFeeding(BuildContext context) {
    String type = 'bottle';
    final amountController = TextEditingController();
    final durationController = TextEditingController();
    final foodController = TextEditingController();
    DateTime time = DateTime.now();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('🍼 添加喂养记录', style: GoogleFonts.notoSansSc(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, children: [
                for (final t in [('breast_left', '🤱 左侧'), ('breast_right', '🤱 右侧'), ('bottle', '🍼 奶瓶'), ('solid', '🥣 辅食')])
                  ChoiceChip(
                    label: Text(t.$2),
                    selected: type == t.$1,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) => setModalState(() => type = t.$1),
                  ),
              ]),
              const SizedBox(height: 16),
              if (type == 'bottle')
                TextField(controller: amountController, keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '奶量 (ml)', labelStyle: GoogleFonts.notoSansSc(fontSize: 14))),
              if (type == 'breast_left' || type == 'breast_right')
                TextField(controller: durationController, keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '时长 (分钟)', labelStyle: GoogleFonts.notoSansSc(fontSize: 14))),
              if (type == 'solid')
                TextField(controller: foodController,
                  decoration: InputDecoration(labelText: '食物名称', hintText: '如：米糊、南瓜泥', labelStyle: GoogleFonts.notoSansSc(fontSize: 14))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                onPressed: () {
                  final baby = Provider.of<BabyProvider>(ctx, listen: false).currentBaby;
                  if (baby == null) return;
                  Provider.of<DailyCareProvider>(ctx, listen: false).addFeedingRecord(
                    babyId: baby.id, startTime: time, type: type,
                    amountMl: double.tryParse(amountController.text),
                    durationMinutes: int.tryParse(durationController.text),
                    foodName: foodController.text.isNotEmpty ? foodController.text : null,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('保存'),
              )),
              const SizedBox(height: 16),
            ]),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyCareProvider>(builder: (context, provider, _) {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            const Spacer(),
            ElevatedButton.icon(onPressed: () => _showAddFeeding(context),
              icon: const Icon(Icons.add, size: 18), label: const Text('记录'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8))),
          ]),
        ),
        Expanded(
          child: provider.feedingRecords.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🍼', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 12),
                  Text('还没有喂养记录', style: GoogleFonts.notoSansSc(color: AppColors.textSecondary)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: provider.feedingRecords.length,
                  itemBuilder: (context, i) {
                    final r = provider.feedingRecords[i];
                    String detail = '';
                    if (r.amountMl != null) detail = '${r.amountMl!.toInt()} ml';
                    if (r.durationMinutes != null) detail = '${r.durationMinutes} 分钟';
                    if (r.foodName != null) detail = r.foodName!;
                    return Dismissible(
                      key: Key(r.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => provider.deleteFeedingRecord(r.id),
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline, color: AppColors.error)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
                        child: Row(children: [
                          Text(r.typeIcon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.typeLabel, style: GoogleFonts.notoSansSc(fontSize: 15, fontWeight: FontWeight.w600)),
                            if (detail.isNotEmpty)
                              Text(detail, style: GoogleFonts.notoSansSc(fontSize: 13, color: AppColors.textSecondary)),
                          ])),
                          Text(DateFormat('HH:mm').format(r.startTime),
                              style: GoogleFonts.notoSansSc(fontSize: 13, color: AppColors.textLight)),
                        ]),
                      ),
                    );
                  }),
        ),
      ]);
    });
  }
}

// ======================== Sleep Tab ========================
class _SleepTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DailyCareProvider>(builder: (context, provider, _) {
      final ongoing = provider.ongoingSleep;
      return Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            if (ongoing != null)
              Text('💤 睡眠中 ${DateFormat('HH:mm').format(ongoing.startTime)} 开始',
                  style: GoogleFonts.notoSansSc(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                final baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
                if (baby == null) return;
                if (ongoing != null) {
                  provider.endSleep(ongoing.id);
                } else {
                  provider.startSleep(babyId: baby.id);
                }
              },
              icon: Icon(ongoing != null ? Icons.stop_rounded : Icons.bedtime_rounded, size: 18),
              label: Text(ongoing != null ? '结束睡眠' : '开始睡眠'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ongoing != null ? AppColors.secondary : AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            ),
          ]),
        ),
        Expanded(
          child: provider.sleepRecords.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('😴', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 12),
                  Text('还没有睡眠记录', style: GoogleFonts.notoSansSc(color: AppColors.textSecondary)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: provider.sleepRecords.length,
                  itemBuilder: (context, i) {
                    final r = provider.sleepRecords[i];
                    return Dismissible(
                      key: Key(r.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => provider.deleteSleepRecord(r.id),
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline, color: AppColors.error)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
                        child: Row(children: [
                          Text(r.isOngoing ? '💤' : '😴', style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.durationText, style: GoogleFonts.notoSansSc(fontSize: 15, fontWeight: FontWeight.w600,
                              color: r.isOngoing ? AppColors.primary : AppColors.textPrimary)),
                            Text(
                              '${DateFormat('HH:mm').format(r.startTime)}${r.endTime != null ? ' - ${DateFormat('HH:mm').format(r.endTime!)}' : ''}',
                              style: GoogleFonts.notoSansSc(fontSize: 13, color: AppColors.textSecondary)),
                          ])),
                          Text(DateFormat('M/d').format(r.startTime),
                              style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.textLight)),
                        ]),
                      ),
                    );
                  }),
        ),
      ]);
    });
  }
}

// ======================== Vaccination Tab ========================
class _VaccinationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DailyCareProvider, BabyProvider>(builder: (context, careProvider, babyProvider, _) {
      final completed = careProvider.completedVaccinationIds;
      final schedule = Vaccination.standardSchedule;
      final baby = babyProvider.currentBaby;
      final ageMonths = baby != null ? baby.ageInDays / 30.0 : 0.0;

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: schedule.length,
        itemBuilder: (context, i) {
          final v = schedule[i];
          final done = completed.contains(v.id);
          final due = v.recommendedMonths <= ageMonths;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: done ? AppColors.mintGreen.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: done ? AppColors.mintGreen.withOpacity(0.3) : (due && !done) ? AppColors.warning.withOpacity(0.5) : AppColors.divider),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: done ? AppColors.mintGreen.withOpacity(0.15) : (due ? AppColors.warning.withOpacity(0.1) : AppColors.background),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  done ? Icons.check_circle_rounded : (due ? Icons.warning_amber_rounded : Icons.circle_outlined),
                  color: done ? AppColors.mintGreen : (due ? AppColors.warning : AppColors.textLight), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(v.name, style: GoogleFonts.notoSansSc(fontSize: 14, fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null, color: done ? AppColors.textSecondary : AppColors.textPrimary)),
                  if (v.doseNumber > 1) Text(' 第${v.doseNumber}剂', style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(width: 6),
                  if (!v.isFree) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.peach.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text('自费', style: GoogleFonts.notoSansSc(fontSize: 9, color: AppColors.primaryDark)),
                  ),
                ]),
                Text('${v.disease} · ${v.recommendedAgeText}',
                  style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              if (!done)
                GestureDetector(
                  onTap: () => _markDone(context, v),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('已接种', style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                )
              else
                const Icon(Icons.check, color: AppColors.mintGreen, size: 20),
            ]),
          );
        },
      );
    });
  }

  void _markDone(BuildContext context, Vaccination v) async {
    final baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
    if (baby == null) return;

    final date = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2010), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white)),
        child: child!),
    );
    if (date == null) return;

    if (!context.mounted) return;
    Provider.of<DailyCareProvider>(context, listen: false).addVaccinationRecord(
      babyId: baby.id, vaccinationId: v.id, date: date,
    );
  }
}
