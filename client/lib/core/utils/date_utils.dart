import 'package:intl/intl.dart';

/// 日期工具类
/// 提供常用的日期格式化和计算方法
class DateUtils {
  DateUtils._();

  /// 常用日期格式
  static const String formatDateTime = 'yyyy-MM-dd HH:mm:ss';
  static const String formatDate = 'yyyy-MM-dd';
  static const String formatTime = 'HH:mm';
  static const String formatMonthDay = 'MM月dd日';
  static const String formatMonthDayTime = 'MM月dd日 HH:mm';
  static const String formatYearMonth = 'yyyy年MM月';
  static const String formatWeekday = 'EEEE';

  /// 格式化日期时间
  static String formatDateTimeStr(DateTime dateTime, [String pattern = formatDateTime]) {
    return DateFormat(pattern, 'zh_CN').format(dateTime);
  }

  /// 格式化日期
  static String formatDateStr(DateTime dateTime) {
    return DateFormat(formatDate).format(dateTime);
  }

  /// 格式化时间
  static String formatTimeStr(DateTime dateTime) {
    return DateFormat(formatTime).format(dateTime);
  }

  /// 格式化为友好时间（如：刚刚、5分钟前、1小时前、昨天）
  static String formatFriendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 2) {
      return '昨天 ${formatTimeStr(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDateTimeStr(dateTime, formatMonthDay);
    }
  }

  /// 计算两个日期之间的天数
  static int daysBetween(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return endDay.difference(startDay).inDays;
  }

  /// 计算行程天数
  static int tripDays(DateTime startDate, DateTime endDate) {
    return daysBetween(startDate, endDate) + 1;
  }

  /// 判断是否是今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 判断是否是明天
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  /// 获取星期几的中文名称
  static String getWeekdayName(DateTime dateTime) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[dateTime.weekday - 1];
  }

  /// 判断日期是否在范围内
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return (date.isAtSameMomentAs(start) || date.isAfter(start)) &&
        (date.isAtSameMomentAs(end) || date.isBefore(end));
  }

  /// 解析日期字符串
  static DateTime? parseDate(String dateString, [String pattern = formatDate]) {
    try {
      return DateFormat(pattern).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
