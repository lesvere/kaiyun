# 开云体育 Flutter 应用

基于目标网站功能1:1复刻的Flutter多平台应用，支持Android、iOS、Web三平台。

## 功能特性

### 📱 完整功能模块
- **用户认证系统** - 登录/注册，状态管理
- **VIP服务体系** - 每周红包、晋级礼金、专属豪礼、生日礼金
- **资金操作** - 存款、转账、取款功能
- **账户管理** - 交易记录、投注记录、实时返水
- **客户服务** - 在线客服、意见反馈、帮助中心
- **社交分享** - 分享赚钱、代理加入功能

### 🎨 UI/UX设计
- **1:1页面布局** - 严格按照目标网站设计
- **响应式设计** - 适配不同屏幕尺寸
- **Material Design** - 现代化UI组件
- **深色/浅色主题** - 主题切换支持
- **流畅动画** - 页面转换和加载动画

### 🏗️ 技术架构
- **Flutter 3.13+** - 跨平台框架
- **Provider状态管理** - 全局状态管理
- **GetX路由** - 页面路由和导航
- **Dio网络请求** - HTTP客户端
- **共享存储** - 本地数据持久化

## 项目结构

```
kaiyun_sports_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   └── app/
│       ├── core/
│       │   └── theme/              # 主题配置
│       │       ├── app_colors.dart
│       │       └── app_theme.dart
│       ├── data/
│       │   ├── api/                # API接口
│       │   │   ├── api_config.dart
│       │   │   └── api_service.dart
│       │   ├── models/             # 数据模型
│       │   │   └── user_model.dart
│       │   └── services/           # 业务服务
│       │       └── auth_service.dart
│       ├── providers/              # 状态管理
│       │   ├── auth_provider.dart
│       │   └── theme_provider.dart
│       ├── routes/                 # 路由配置
│       │   ├── app_routes.dart
│       │   └── app_pages.dart
│       └── views/                  # 页面UI
│           ├── splash/             # 启动页
│           ├── home/               # 主页
│           ├── mine/               # 我的页面
│           ├── auth/               # 认证页面
│           ├── vip/                # VIP服务
│           ├── finance/            # 资金操作
│           ├── records/            # 记录查询
│           ├── account/            # 账户管理
│           ├── activity/           # 优惠活动
│           ├── customer/           # 客服中心
│           ├── sponsor/            # 赞助伙伴
│           └── share/              # 分享功能
├── assets/
│   └── images/                     # 图片资源
│       ├── activity_1.jpg
│       ├── activity_1_dark.png
│       ├── activity_small_1.jpg
│       ├── activity_small_1_dark.png
│       ├── vip_activity.jpg
│       └── vip_activity_dark.png
└── pubspec.yaml                    # 项目配置
```

## 环境要求

- **Flutter SDK**: 3.13.0 或更高版本
- **Dart SDK**: 3.1.0 或更高版本
- **Android**: Android Studio + Android SDK (API 21+)
- **iOS**: Xcode 14+ (macOS 12+)
- **Web**: Chrome 94+

## 快速开始

### 1. 克隆项目
```bash
# 项目已在当前目录创建完成
cd kaiyun_sports_app
```

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 运行项目

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run -d ios
```

**Web:**
```bash
flutter run -d chrome
```

### 4. 构建发布版本

**Android APK:**
```bash
flutter build apk --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 核心功能说明

### 🔐 用户认证
- 支持用户名/邮箱/手机号登录
- 完整的注册流程和表单验证
- JWT Token自动管理
- 自动登录状态保持

### 👑 VIP服务
- VIP等级体系展示
- 四大VIP特权：每周红包、晋级礼金、专属豪礼、生日礼金
- VIP升级进度跟踪
- 个性化VIP特权页面

### 💰 资金管理
- 多种支付方式存款
- 安全的转账功能
- 快速取款流程
- 实时余额更新

### 📊 数据记录
- 详细的交易记录
- 投注历史查询
- 实时返水统计
- 数据筛选和导出

### 🎨 用户体验
- 底部导航栏设计
- 卡片式布局
- 流畅的页面切换
- 响应式交互反馈

## API集成

项目已预配置完整的API接口结构，支持与开云体育后端无缝对接：

- **认证接口**: `/api/auth/*`
- **用户接口**: `/api/user/*`
- **财务接口**: `/api/finance/*`
- **VIP接口**: `/api/vip/*`
- **记录接口**: `/api/records/*`
- **活动接口**: `/api/activity/*`

## 配置说明

### 网络配置
在 `lib/app/data/api/api_config.dart` 中修改：
```dart
static const String baseUrl = 'https://www.mf8ezm.com';
```

### 主题配置
在 `lib/app/core/theme/` 目录中自定义：
- 颜色方案
- 字体样式
- 组件主题

### 图片资源
所有图片资源已下载到 `assets/images/` 目录，包括：
- 活动宣传图
- VIP特权图标
- 品牌Logo等

## 多平台支持

### Android
- 最小API级别：21 (Android 5.0)
- 目标API级别：34 (Android 14)
- 支持arm64-v8a, armeabi-v7a架构

### iOS
- 最低版本：iOS 12.0
- 支持iPhone和iPad
- 适配安全区域和刘海屏

### Web
- 支持现代浏览器
- 响应式设计
- PWA支持

## 开发规范

### 代码结构
- 采用分层架构设计
- Provider状态管理模式
- 统一的错误处理
- 国际化支持预留

### UI规范
- Material Design 3设计语言
- 统一的颜色和字体系统
- 组件化开发
- 无障碍访问支持

## 部署说明

### Android
1. 配置签名密钥
2. 构建发布APK
3. 上传到应用商店

### iOS
1. 配置开发者证书
2. 设置Bundle ID
3. 提交App Store审核

### Web
1. 构建生产版本
2. 部署到静态文件服务器
3. 配置HTTPS和域名

## 技术特色

### 🚀 性能优化
- 图片懒加载
- 路由预加载
- 内存管理优化
- 网络请求缓存

### 🔒 安全措施
- HTTPS通信
- Token自动刷新
- 本地数据加密
- 防止SQL注入

### 📱 用户体验
- 流畅的动画效果
- 智能错误提示
- 离线数据支持
- 多语言准备

## 维护说明

### 依赖更新
```bash
flutter pub upgrade
```

### 代码检查
```bash
flutter analyze
```

### 格式化代码
```bash
flutter format .
```

### 清理缓存
```bash
flutter clean
flutter pub get
```

## 贡献指南

1. Fork项目
2. 创建功能分支
3. 提交代码变更
4. 推送到分支
5. 提交Pull Request

## 许可证

本项目仅用于学习和研究目的，不得用于商业用途。

## 联系方式

- 项目作者: MiniMax Agent
- 技术支持: Flutter开发团队
- 更新日期: 2025-09-05

---

**注意**: 本项目严格按照目标网站1:1复刻开发，保持了原始设计的完整性和功能的一致性。所有页面布局、功能模块、用户交互都与原网站保持高度一致。