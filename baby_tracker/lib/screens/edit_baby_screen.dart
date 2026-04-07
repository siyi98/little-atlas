import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../providers/baby_provider.dart';
import '../models/baby.dart';
import '../theme/app_theme.dart';

class EditBabyScreen extends StatefulWidget {
  final Baby baby;

  const EditBabyScreen({super.key, required this.baby});

  @override
  State<EditBabyScreen> createState() => _EditBabyScreenState();
}

class _EditBabyScreenState extends State<EditBabyScreen> {
  late TextEditingController _nameController;
  late String _gender;
  late DateTime _birthday;
  String? _avatarPath;
  String? _bloodType;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby.name);
    _gender = widget.baby.gender ?? 'girl';
    _birthday = widget.baby.birthday;
    _avatarPath = widget.baby.avatarPath;
    _bloodType = widget.baby.bloodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('选择头像', style: GoogleFonts.notoSansSc(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.babyPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.babyPink),
                ),
                title: Text('拍照', style: GoogleFonts.notoSansSc()),
                onTap: () async {
                  Navigator.pop(context);
                  final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512);
                  if (photo != null) setState(() => _avatarPath = photo.path);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.babyBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.babyBlue),
                ),
                title: Text('从相册选择', style: GoogleFonts.notoSansSc()),
                onTap: () async {
                  Navigator.pop(context);
                  final photo = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
                  if (photo != null) setState(() => _avatarPath = photo.path);
                },
              ),
              if (_avatarPath != null)
                ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: Text('移除头像', style: GoogleFonts.notoSansSc(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _avatarPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入宝宝昵称')),
      );
      return;
    }

    final updated = widget.baby.copyWith(
      name: _nameController.text.trim(),
      gender: _gender,
      birthday: _birthday,
      avatarPath: _avatarPath,
      bloodType: _bloodType,
    );

    await Provider.of<BabyProvider>(context, listen: false).updateBaby(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('编辑资料', style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: GoogleFonts.notoSansSc(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary,
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: (_gender == 'boy' ? AppColors.babyBlue : AppColors.babyPink).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: (_gender == 'boy' ? AppColors.babyBlue : AppColors.babyPink).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: _avatarPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.file(File(_avatarPath!), fit: BoxFit.cover, width: 100, height: 100),
                          )
                        : Center(
                            child: Text(
                              _gender == 'boy' ? '👦' : '👧',
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('点击更换头像', style: GoogleFonts.notoSansSc(fontSize: 12, color: AppColors.textLight)),

            const SizedBox(height: 28),

            // Name
            _buildField(
              label: '昵称',
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: '输入宝宝的昵称',
                  prefixIcon: Icon(Icons.child_care, color: AppColors.primary),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Gender
            _buildField(
              label: '性别',
              child: Row(
                children: [
                  Expanded(child: _buildGenderOption('girl', '👧', '女宝宝')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildGenderOption('boy', '👦', '男宝宝')),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Birthday
            _buildField(
              label: '出生日期',
              child: GestureDetector(
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
            ),

            const SizedBox(height: 20),

            // Blood type
            _buildField(
              label: '血型',
              child: Wrap(
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
                    onSelected: (selected) => setState(() => _bloodType = selected ? type : null),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.notoSansSc(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildGenderOption(String value, String emoji, String label) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'girl' ? AppColors.babyPink : AppColors.babyBlue).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (value == 'girl' ? AppColors.babyPink : AppColors.babyBlue)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.notoSansSc(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}
