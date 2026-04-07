import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/baby_provider.dart';
import '../models/growth_record.dart';
import '../theme/app_theme.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<BabyProvider>(
                builder: (context, provider, _) {
                  final records = provider.growthRecords;
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChartTab(records, 'height', '身高', 'cm', AppColors.babyBlue),
                      _buildChartTab(records, 'weight', '体重', 'kg', AppColors.babyPink),
                      _buildChartTab(records, 'head', '头围', 'cm', AppColors.peach),
                    ],
                  );
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            '📏 成长曲线',
            style: GoogleFonts.notoSansSc(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddRecordDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('记录'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.notoSansSc(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.notoSansSc(fontSize: 14),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        tabs: const [
          Tab(text: '身高'),
          Tab(text: '体重'),
          Tab(text: '头围'),
        ],
      ),
    );
  }

  Widget _buildChartTab(
    List<GrowthRecord> records,
    String type,
    String label,
    String unit,
    Color color,
  ) {
    final filteredRecords = records.where((r) {
      switch (type) {
        case 'height':
          return r.height != null;
        case 'weight':
          return r.weight != null;
        case 'head':
          return r.headCircumference != null;
        default:
          return false;
      }
    }).toList();

    if (filteredRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '还没有${label}记录',
              style: GoogleFonts.notoSansSc(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角添加记录',
              style: GoogleFonts.notoSansSc(fontSize: 14, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChart(filteredRecords, type, label, unit, color),
          const SizedBox(height: 24),
          _buildRecordList(filteredRecords, type, label, unit, color),
        ],
      ),
    );
  }

  Widget _buildChart(
    List<GrowthRecord> records,
    String type,
    String label,
    String unit,
    Color color,
  ) {
    List<FlSpot> spots = [];
    for (int i = 0; i < records.length; i++) {
      double value;
      switch (type) {
        case 'height':
          value = records[i].height!;
          break;
        case 'weight':
          value = records[i].weight!;
          break;
        case 'head':
          value = records[i].headCircumference!;
          break;
        default:
          value = 0;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            '$label变化趋势',
            style: GoogleFonts.notoSansSc(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getInterval(spots),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: GoogleFonts.notoSansSc(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= records.length) return const Text('');
                        return Text(
                          DateFormat('M/d').format(records[index].date),
                          style: GoogleFonts.notoSansSc(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final record = records[spot.spotIndex];
                        return LineTooltipItem(
                          '${DateFormat('M月d日').format(record.date)}\n${spot.y.toStringAsFixed(1)} $unit',
                          GoogleFonts.notoSansSc(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final values = spots.map((s) => s.y).toList();
    final range = values.reduce((a, b) => a > b ? a : b) -
        values.reduce((a, b) => a < b ? a : b);
    if (range == 0) return 1;
    return (range / 4).ceilToDouble();
  }

  Widget _buildRecordList(
    List<GrowthRecord> records,
    String type,
    String label,
    String unit,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '历史记录',
          style: GoogleFonts.notoSansSc(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...records.reversed.map((record) {
          double? value;
          switch (type) {
            case 'height':
              value = record.height;
              break;
            case 'weight':
              value = record.weight;
              break;
            case 'head':
              value = record.headCircumference;
              break;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    type == 'height'
                        ? Icons.straighten
                        : type == 'weight'
                            ? Icons.monitor_weight_outlined
                            : Icons.circle_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${value?.toStringAsFixed(1)} $unit',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy年M月d日').format(record.date),
                        style: GoogleFonts.notoSansSc(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.textLight, size: 20),
                  onPressed: () {
                    Provider.of<BabyProvider>(context, listen: false)
                        .deleteGrowthRecord(record.id);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
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
                  mainAxisSize: MainAxisSize.min,
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
                      '📏 添加成长记录',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '身高 (cm)',
                              labelStyle: GoogleFonts.notoSansSc(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '体重 (kg)',
                              labelStyle: GoogleFonts.notoSansSc(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: headController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '头围 (cm)',
                        labelStyle: GoogleFonts.notoSansSc(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final height = double.tryParse(heightController.text);
                          final weight = double.tryParse(weightController.text);
                          final head = double.tryParse(headController.text);

                          if (height == null && weight == null && head == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请至少填写一项数据')),
                            );
                            return;
                          }

                          Provider.of<BabyProvider>(context, listen: false).addGrowthRecord(
                            date: selectedDate,
                            height: height,
                            weight: weight,
                            headCircumference: head,
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
