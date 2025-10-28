import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtil {
  /// 选择图片，返回选中的 [File]，未选择则返回 null
  static Future<File?> pickImage({
    required BuildContext context,
    double maxWidth = 1080,
    double maxHeight = 1080,
    int imageQuality = 80,
  }) async {
    final source = await _showImageSourceModal(context);
    if (source == null) return null;

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e, stack) {
      debugPrint('Image picker error: $e\n$stack');
      return null;
    }
  }

  /// 显示底部弹窗选择图片来源
  static Future<ImageSource?> _showImageSourceModal(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              TextButton(child: const Text('取消'), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        );
      },
    );
  }
}
