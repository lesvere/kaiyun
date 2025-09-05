import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/finance_models.dart';

/// 交易确认对话框组件
/// 用于展示交易详情并进行最终确认
class TransactionConfirmDialog extends StatelessWidget {
  final String title;
  final TransactionType transactionType;
  final Map<String, dynamic> transactionData;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget? additionalWidget;
  final String confirmButtonText;
  final Color? confirmButtonColor;

  const TransactionConfirmDialog({
    Key? key,
    required this.title,
    required this.transactionType,
    required this.transactionData,
    required this.onConfirm,
    this.onCancel,
    this.additionalWidget,
    this.confirmButtonText = '确认',
    this.confirmButtonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTransactionDetails(),
            if (additionalWidget != null) additionalWidget!,
            _buildSecurityNotice(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    IconData iconData;
    Color primaryColor;
    
    switch (transactionType) {
      case TransactionType.deposit:
        iconData = Icons.add_circle;
        primaryColor = Colors.green;
        break;
      case TransactionType.withdrawal:
        iconData = Icons.remove_circle;
        primaryColor = Colors.orange;
        break;
      case TransactionType.transfer:
        iconData = Icons.swap_horiz;
        primaryColor = AppColors.primary;
        break;
      default:
        iconData = Icons.account_balance_wallet;
        primaryColor = AppColors.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '请仔细核对交易信息',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '交易详情',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...transactionData.entries.map((entry) {
            return _buildDetailRow(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    bool isAmount = label.contains('金额') || label.contains('手续费');
    bool isImportant = label.contains('金额') || label.contains('账户') || label.contains('收款');
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isImportant ? Colors.blue.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isImportant 
            ? Border.all(color: Colors.blue.withOpacity(0.2)) 
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: isImportant ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAmount && value is num 
                  ? '￥${value.toStringAsFixed(2)}'
                  : value.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isImportant ? Colors.black87 : Colors.black87,
                fontWeight: isImportant ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• 请仔细核对以上信息，确认无误后再进行操作\n'
            '• 交易完成后无法撤销，如有疑问请联系客服\n'
            '• 请确保网络环境安全，避免在公共场所操作\n'
            '• 切勿将账号密码泄露给他人',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                '取消',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmButtonColor ?? _getConfirmButtonColor(),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                confirmButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfirmButtonColor() {
    switch (transactionType) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.orange;
      case TransactionType.transfer:
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }
}

/// 二级确认对话框 - 用于高风险操作的二次确认
class SecondaryConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool requireTextConfirmation;
  final String? confirmationText;

  const SecondaryConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = '确认',
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.requireTextConfirmation = false,
    this.confirmationText,
  }) : super(key: key);

  @override
  State<SecondaryConfirmDialog> createState() => _SecondaryConfirmDialogState();
}

class _SecondaryConfirmDialogState extends State<SecondaryConfirmDialog> {
  final TextEditingController _textController = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    if (!widget.requireTextConfirmation) {
      _canConfirm = true;
    }
    _textController.addListener(_updateConfirmState);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateConfirmState() {
    if (widget.requireTextConfirmation) {
      setState(() {
        _canConfirm = _textController.text.trim() == 
            (widget.confirmationText ?? '确认操作');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (widget.requireTextConfirmation) ...[
            const SizedBox(height: 20),
            Text(
              '请输入"${widget.confirmationText ?? '确认操作'}"以确认：',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: widget.confirmationText ?? '确认操作',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _canConfirm ? () {
            Navigator.of(context).pop();
            widget.onConfirm();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.confirmButtonColor ?? Colors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}

/// 工具方法：显示交易确认对话框
Future<void> showTransactionConfirmDialog({
  required BuildContext context,
  required String title,
  required TransactionType transactionType,
  required Map<String, dynamic> transactionData,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  Widget? additionalWidget,
  String confirmButtonText = '确认',
  Color? confirmButtonColor,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return TransactionConfirmDialog(
        title: title,
        transactionType: transactionType,
        transactionData: transactionData,
        onConfirm: onConfirm,
        onCancel: onCancel,
        additionalWidget: additionalWidget,
        confirmButtonText: confirmButtonText,
        confirmButtonColor: confirmButtonColor,
      );
    },
  );
}

/// 工具方法：显示二级确认对话框
Future<void> showSecondaryConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = '确认',
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  Color? confirmButtonColor,
  bool requireTextConfirmation = false,
  String? confirmationText,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SecondaryConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmButtonColor: confirmButtonColor,
        requireTextConfirmation: requireTextConfirmation,
        confirmationText: confirmationText,
      );
    },
  );
}
