import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../error/error_types.dart';
import '../error/error_handler.dart';

/// 用户友好的错误展示组件
class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;
  final bool showRetryButton;
  final EdgeInsets padding;
  
  const ErrorDisplayWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
    this.showRetryButton = true,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 错误图标和标题
          Row(
            children: [
              Icon(
                _getErrorIcon(),
                color: _getIconColor(context),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getErrorTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                  color: _getTextColor(context).withOpacity(0.7),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 错误消息
          Text(
            ErrorHandler().createUserFriendlyMessage(error),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getTextColor(context).withOpacity(0.8),
            ),
          ),
          
          // 详细信息
          if (showDetails && kDebugMode) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                '技术详情',
                style: TextStyle(
                  color: _getTextColor(context).withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (error.statusCode != null)
                        Text('状态码: ${error.statusCode}'),
                      Text('错误类型: ${error.type.name}'),
                      if (error.originalError != null)
                        Text('原始错误: ${error.originalError}'),
                      Text('重试次数: ${error.retryCount}'),
                    ].map((text) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: text,
                    )).toList(),
                  ),
                ),
              ],
            ),
          ],
          
          // 操作按钮
          if (showRetryButton && error.retryable) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(context),
                      foregroundColor: Colors.white,
                    ),
                  ),
                const Spacer(),
                if (error.requiresAuth)
                  TextButton(
                    onPressed: () => _handleAuthRequired(context),
                    child: Text(
                      '重新登录',
                      style: TextStyle(
                        color: _getButtonColor(context),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  /// 获取错误图标
  IconData _getErrorIcon() {
    switch (error.type) {
      case ErrorType.networkUnavailable:
      case ErrorType.connectionTimeout:
        return Icons.wifi_off;
      case ErrorType.serverError:
        return Icons.cloud_off;
      case ErrorType.unauthorized:
        return Icons.lock;
      case ErrorType.forbidden:
        return Icons.block;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.tooManyRequests:
        return Icons.timer;
      case ErrorType.validation:
        return Icons.warning;
      default:
        return Icons.error;
    }
  }
  
  /// 获取错误标题
  String _getErrorTitle() {
    switch (error.type) {
      case ErrorType.networkUnavailable:
        return '网络连接问题';
      case ErrorType.connectionTimeout:
        return '连接超时';
      case ErrorType.serverError:
        return '服务器错误';
      case ErrorType.unauthorized:
        return '身份验证失败';
      case ErrorType.forbidden:
        return '权限不足';
      case ErrorType.notFound:
        return '资源不存在';
      case ErrorType.tooManyRequests:
        return '请求过于频繁';
      case ErrorType.validation:
        return '数据验证错误';
      default:
        return '操作失败';
    }
  }
  
  /// 获取背景颜色
  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (error.type) {
      case ErrorType.networkUnavailable:
      case ErrorType.connectionTimeout:
        return isDark ? Colors.orange.shade900.withOpacity(0.2) 
                     : Colors.orange.shade50;
      case ErrorType.serverError:
        return isDark ? Colors.red.shade900.withOpacity(0.2) 
                     : Colors.red.shade50;
      case ErrorType.unauthorized:
      case ErrorType.forbidden:
        return isDark ? Colors.purple.shade900.withOpacity(0.2) 
                     : Colors.purple.shade50;
      default:
        return isDark ? Colors.grey.shade800.withOpacity(0.3) 
                     : Colors.grey.shade100;
    }
  }
  
  /// 获取边框颜色
  Color _getBorderColor(BuildContext context) {
    switch (error.type) {
      case ErrorType.networkUnavailable:
      case ErrorType.connectionTimeout:
        return Colors.orange.shade300;
      case ErrorType.serverError:
        return Colors.red.shade300;
      case ErrorType.unauthorized:
      case ErrorType.forbidden:
        return Colors.purple.shade300;
      default:
        return Colors.grey.shade300;
    }
  }
  
  /// 获取图标颜色
  Color _getIconColor(BuildContext context) {
    switch (error.type) {
      case ErrorType.networkUnavailable:
      case ErrorType.connectionTimeout:
        return Colors.orange;
      case ErrorType.serverError:
        return Colors.red;
      case ErrorType.unauthorized:
      case ErrorType.forbidden:
        return Colors.purple;
      default:
        return Colors.grey.shade600;
    }
  }
  
  /// 获取文本颜色
  Color _getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
  }
  
  /// 获取按钮颜色
  Color _getButtonColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
  
  /// 处理身份验证失败
  void _handleAuthRequired(BuildContext context) {
    // TODO: 实现跳转到登录页面的逻辑
    Get.toNamed('/login');
  }
}

/// 全局错误提示工具
class ErrorToast {
  static OverlayEntry? _currentOverlay;
  
  /// 显示错误 Toast
  static void show(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
    bool dismissible = true,
  }) {
    // 移除已存在的 Toast
    dismiss();
    
    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => _ToastWidget(
        error: error,
        onRetry: onRetry,
        onDismiss: dismissible ? dismiss : null,
        duration: duration,
      ),
    );
    
    overlay.insert(_currentOverlay!);
    
    // 自动消失
    Future.delayed(duration, () {
      dismiss();
    });
  }
  
  /// 显示网络错误 Toast
  static void showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    show(
      context,
      AppError(
        type: ErrorType.networkUnavailable,
        message: '网络连接失败，请检查网络设置',
        retryable: true,
        isRecoverable: true,
      ),
      onRetry: onRetry,
    );
  }
  
  /// 显示服务器错误 Toast
  static void showServerError(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
  }) {
    show(
      context,
      AppError(
        type: ErrorType.serverError,
        message: message ?? '服务器错误，请稍后重试',
        retryable: true,
        isRecoverable: true,
      ),
      onRetry: onRetry,
    );
  }
  
  /// 隐藏 Toast
  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// Toast 展示组件
class _ToastWidget extends StatefulWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Duration duration;
  
  const _ToastWidget({
    required this.error,
    this.onRetry,
    this.onDismiss,
    required this.duration,
  });
  
  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -50 * (1 - _animation.value)),
            child: Opacity(
              opacity: _animation.value,
              child: child,
            ),
          );
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: ErrorDisplayWidget(
            error: widget.error,
            onRetry: widget.onRetry,
            onDismiss: widget.onDismiss,
            showRetryButton: widget.error.retryable,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

/// 错误页面组件
class ErrorPageWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? customTitle;
  final String? customMessage;
  
  const ErrorPageWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onBack,
    this.customTitle,
    this.customMessage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customTitle ?? '出现问题'),
        leading: onBack != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 错误图标
              Icon(
                _getErrorIcon(),
                size: 80,
                color: Colors.grey.shade400,
              ),
              
              const SizedBox(height: 24),
              
              // 错误标题
              Text(
                customTitle ?? _getErrorTitle(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 错误消息
              Text(
                customMessage ?? ErrorHandler().createUserFriendlyMessage(error),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 操作按钮
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error.retryable && onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  if (error.requiresAuth)
                    OutlinedButton.icon(
                      onPressed: () => Get.toNamed('/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('重新登录'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('返回上一页'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getErrorIcon() {
    switch (error.type) {
      case ErrorType.networkUnavailable:
        return Icons.cloud_off;
      case ErrorType.serverError:
        return Icons.error_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      default:
        return Icons.warning_amber;
    }
  }
  
  String _getErrorTitle() {
    switch (error.type) {
      case ErrorType.networkUnavailable:
        return '网络连接失败';
      case ErrorType.serverError:
        return '服务临时不可用';
      case ErrorType.notFound:
        return '页面不存在';
      default:
        return '出现问题';
    }
  }
}