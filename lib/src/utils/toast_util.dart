import 'package:flutter/material.dart';

class ToastUtils {
  static final ToastUtils _instance = ToastUtils._internal();
  static BuildContext? _globalContext;

  factory ToastUtils() => _instance;
  ToastUtils._internal();

  static void init(BuildContext context) {
    _globalContext = context;
  }

  static void show({
    String? message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 14.0,
    double borderRadius = 8.0,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  }) {
    if (_globalContext == null) {
      throw Exception('ToastUtils not initialized. Call ToastUtils.init() first');
    }

    final overlay = Overlay.of(_globalContext!);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  padding: padding,
                  child: Text(
                    message ?? '',
                    style: TextStyle(color: textColor, fontSize: fontSize),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, overlayEntry.remove);
  }
}
