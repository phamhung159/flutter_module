import 'package:flutter/foundation.dart';
import 'package:logger/web.dart';
import 'dart:developer';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

Logger applog = Logger();

LogLevel appLogLevel = LogLevel.debug;

void tLog(
  dynamic message, {
  LogLevel level = LogLevel.debug,
}) {
  if (level.index > appLogLevel.index) return;
  final now = DateTime.now();
  final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.'
      '${now.millisecond.toString().padLeft(3, '0')}';
      final logMessage = '[$timestamp]: $message';
  switch (level) {
    case LogLevel.debug:
      try {
        if (kDebugMode) {
          log(logMessage);
        } else {
          applog.d(logMessage);
        }
      } catch (_) {}
      break;
    case LogLevel.info:
      applog.i(logMessage);
      break;
    case LogLevel.warning:
      applog.w(logMessage);
      break;
    case LogLevel.error:
      applog.e(logMessage);
      break;
  }
}