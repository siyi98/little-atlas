# Little Atlas

一款精美温馨的宝宝成长记录应用，支持 Android 和 iOS 双平台。

## ✨ 功能特点

### 📸 照片时光轴
- 自动读取手机相册中的照片
- 按时间（年月）分组展示
- 支持照片详情查看和缩放
- 分页加载，流畅浏览

### 📏 成长曲线
- 记录宝宝身高、体重、头围
- 精美的成长趋势图表
- 历史记录查看和管理

### 🏆 成长里程碑
- 20+ 预设里程碑（第一次微笑、翻身、走路等）
- 时间轴式展示
- 分类标签（运动、语言、社交等）
- 自定义描述记录

### 📝 成长日记
- 记录每天的故事
- 心情和天气标签
- 滑动删除操作

### 👶 宝宝档案
- 支持多宝宝管理
- 记录出生信息（体重、身长、血型）
- 实时计算年龄天数

## 🎨 UI 设计
- 温馨粉色系配色
- 圆润卡片式设计
- 流畅动画过渡
- Material Design 3 风格

## 🛠 技术栈
- **框架**: Flutter 3.22+
- **状态管理**: Provider
- **数据库**: SQLite (sqflite)
- **图表**: fl_chart
- **相册**: photo_manager
- **字体**: Google Fonts (Noto Sans SC)

## 📦 构建

### 前提条件
- Flutter SDK 3.22.0+
- Android Studio / Xcode
- JDK 17 (Android)

### 本地构建

```bash
cd baby_tracker

# 获取依赖
flutter pub get

# 运行调试版
flutter run

# 构建 Android APK
flutter build apk --release

# 构建 iOS
flutter build ios --release --no-codesign
```

### CI/CD 自动构建

项目配置了 GitHub Actions，支持自动构建：

- **Android APK**: 推送到 main 分支或创建 tag 时自动构建
- **iOS IPA**: 推送到 main 分支或创建 tag 时自动构建

创建 Release 版本：
```bash
git tag v1.0.0
git push origin v1.0.0
```

构建产物会自动上传到 GitHub Release。

## 📁 项目结构

```
baby_tracker/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── models/                # 数据模型
│   │   ├── baby.dart          # 宝宝信息
│   │   ├── growth_record.dart # 成长记录
│   │   ├── milestone.dart     # 里程碑
│   │   └── diary_entry.dart   # 日记条目
│   ├── providers/             # 状态管理
│   │   ├── baby_provider.dart
│   │   ├── photo_provider.dart
│   │   └── diary_provider.dart
│   ├── screens/               # 页面
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── add_baby_screen.dart
│   │   ├── photo_timeline_screen.dart
│   │   ├── growth_screen.dart
│   │   ├── milestone_screen.dart
│   │   └── diary_screen.dart
│   ├── widgets/               # 组件
│   │   └── home_tab.dart
│   ├── theme/                 # 主题
│   │   └── app_theme.dart
│   └── utils/                 # 工具类
│       └── database_helper.dart
├── android/                   # Android 平台配置
├── ios/                       # iOS 平台配置
├── assets/                    # 资源文件
├── test/                      # 测试
└── .github/workflows/         # CI/CD 配置
    ├── build-android.yml
    └── build-ios.yml
```

## 📄 License

MIT License
