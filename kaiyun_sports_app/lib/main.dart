import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/providers/auth_provider.dart';
import 'app/providers/theme_provider.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/navigation/navigation_controller.dart';

void main() {
  // 初始化GetX的全局服务
  Get.put(NavigationController());
  
  runApp(const KaiyunSportsApp());
}

class KaiyunSportsApp extends StatelessWidget {
  const KaiyunSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            title: '开云体育',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            getPages: AppPages.pages,
            locale: const Locale('zh', 'CN'),
            fallbackLocale: const Locale('zh', 'CN'),
            // 全局页面切换动画配置
            defaultTransition: Transition.rightToLeftWithFade,
            transitionDuration: const Duration(milliseconds: 300),
            // 禁用GetX的日志
            enableLog: false,
            // 智能管理
            smartManagement: SmartManagement.full,
          );
        },
      ),
    );
  }
}