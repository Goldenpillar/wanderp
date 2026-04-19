# WanderP Flutter 客户端

智能旅行规划与协作平台的 Flutter 客户端应用。

## 技术栈

- **框架**: Flutter 3.x (Dart 3.x)
- **状态管理**: flutter_bloc + Riverpod
- **网络请求**: Dio
- **地图服务**: 高德地图 (amap_flutter_map)
- **本地存储**: Hive + Isar
- **实时协作**: Yjs + WebSocket + MQTT
- **路由**: GoRouter

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── app.dart               # MaterialApp 配置
├── config/                # 配置（环境、路由、主题）
├── core/                  # 核心模块（网络、存储、工具）
├── models/                # 数据模型
├── blocs/                 # BLoC 状态管理
├── services/              # 服务层（API 调用）
├── providers/             # Riverpod Providers
├── pages/                 # 页面
└── widgets/               # 通用组件
```

## 开始使用

### 前置条件

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code

### 安装依赖

```bash
flutter pub get
```

### 运行

```bash
flutter run
```

### 运行测试

```bash
flutter test
```

## 配置说明

在 `lib/config/app_config.dart` 中配置以下环境变量：

- 后端 API 地址
- 高德地图 Key（Android/iOS）
- 天气服务 API Key
- MQTT Broker 配置

## 功能模块

- **行程管理**: 创建、编辑、删除行程
- **地图服务**: 地图展示、标记点、轨迹记录
- **美食探索**: 餐厅推荐、搜索、收藏
- **协作功能**: 成员邀请、偏好收集、投票决策
- **消费管理**: 记账、分摊、结算
- **用户认证**: 登录、注册、第三方登录
