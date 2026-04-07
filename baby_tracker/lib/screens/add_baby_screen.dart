import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/baby_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class AddBabyScreen extends StatefulWidget {
  final bool isFirstBaby;

  const AddBabyScreen({super.key, this.isFirstBaby = false});

  @override
  State<AddBabyScreen> createState() => _AddBabyScreenState();
}

class _AddBabyScreenState extends State<AddBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  DateTime _birthday = DateTime.now();
  String _gender = 'girl';
  String? _bloodType;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
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
      setState(() => _birthday = picked);
    }
  }

  Future<void> _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BabyProvider>(context, listen: false);
    await provider.addBaby(
      name: _nameController.text.trim(),
      birthday: _birthday,
      gender: _gender,
      bloodType: _bloodType,
      birthWeight: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      birthHeight: _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null,
    );

    if (!mounted) return;

    if (widget.isFirstBaby) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.warmGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isFirstBaby)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        const Text('👶', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        Text(
                          widget.isFirstBaby ? '欢迎使用 Little Atlas' : '添加宝宝',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isFirstBaby ? '先来添加宝宝的信息吧' : '记录多个宝宝的成长',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('宝宝昵称'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: '输入宝宝的昵称',
                      prefixIcon: Icon(Icons.child_care, color: AppColors.primary),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? '请输入宝宝昵称' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('性别'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderOption('girl', '👧', '女宝宝'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderOption('boy', '👦', '男宝宝'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('出生日期'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('yyyy年M月d日').format(_birthday),
                            style: GoogleFonts.notoSansSc(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('出生体重（选填）'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '例如: 3.5',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.monitor_weight_outlined, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('出生身长（选填）'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '例如: 50',
                      suffixText: 'cm',
                      prefixIcon: Icon(Icons.straighten, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('血型（选填）'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['A', 'B', 'AB', 'O'].map((type) {
                      final isSelected = _bloodType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: GoogleFonts.notoSansSc(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() => _bloodType = selected ? type : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveBaby,
                      child: Text(
                        '开始记录',
                        style: GoogleFonts.notoSansSc(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.notoSansSc(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildGenderOption(String value, String emoji, String label) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'girl' ? AppColors.babyPink : AppColors.babyBlue).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (value == 'girl' ? AppColors.babyPink : AppColors.babyBlue)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.notoSansSc(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
