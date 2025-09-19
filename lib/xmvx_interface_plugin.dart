import 'dart:convert';

import 'package:xmvx_interface_plugin/src/http/vx_http_request_utils.dart';

class XmvxInterfacePlugin {
  static final XmvxInterfacePlugin _instance = XmvxInterfacePlugin._internal();
  bool videoTypeIsOpen = false;
  static List<String> imageType = [
    "realman_avatar_picture_create_role ",
    "realman_avatar_picture_create_role_loopy",
    "realman_avatar_picture_create_role_loopyb",
    "jimeng_realman_avatar_picture_create_role_omni",
  ];
  static List<String> videoType = [
    "realman_avatar_picture_v2",
    "realman_avatar_picture_loopy",
    "realman_avatar_picture_loopyb",
    "jimeng_realman_avatar_picture_omni_v2",
  ];

  factory XmvxInterfacePlugin() => _instance;
  XmvxInterfacePlugin._internal();

  static Future<String?> getSingleCreateImage(int modeType, String imageUrl) async {
    var jsonStr = jsonEncode({'req_key': imageType[modeType], 'image_url': imageUrl});
    String? reqBody = await VXHttpRequestUtils.getCVSubmitTask(jsonStr);
    return reqBody;
  }

  static Future<String?> getSingleVideoGeneration(
    int modeType,
    // ignore: non_constant_identifier_names
    String audio_url,
    // ignore: non_constant_identifier_names
    String resource_id,
  ) async {
    var jsonStr = jsonEncode({
      'req_key': videoType[modeType],
      'audio_url': audio_url,
      'resource_id': resource_id,
    });
    String? reqBody = await VXHttpRequestUtils.getCVSubmitTask(jsonStr);
    return reqBody;
  }

  static Future<String?> getVideoUpdateLipShape(String mp4, String mp3) async {
    var jsonStr = jsonEncode({'req_key': "realman_change_lips", 'url': mp4, 'pure_audio_url': mp3});
    String? reqBody = await VXHttpRequestUtils.getCVSubmitTask(jsonStr);
    return reqBody;
  }

  static Future<String?> getAISubjectIdentification(String imageUrl) async {
    var jsonStr = jsonEncode({
      'req_key': "jimeng_realman_avatar_picture_create_role_omni",
      'image_url': imageUrl,
    });
    String? reqBody = await VXHttpRequestUtils.getCVSubmitTask(jsonStr);
    return reqBody;
  }

  static Future<String?> getAIVideoGeneration(String imageUrl, String audioUrl) async {
    var jsonStr = jsonEncode({
      'req_key': "jimeng_realman_avatar_picture_omni_v2",
      'url': imageUrl,
      'pure_audio_url': audioUrl,
    });
    String? reqBody = await VXHttpRequestUtils.getCVSubmitTask(jsonStr);
    return reqBody;
  }
}
