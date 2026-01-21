import 'dart:convert';

import 'package:xmvx_interface_plugin/src/http/vx_http_request_utils.dart';

export 'package:xmvx_interface_plugin/src/http/vx_xmvx_signature_util.dart';

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

  static Future<String?> getSingleCreateImage(
    String credential,
    String signature,
    int modeType,
    String imageUrl,
  ) async {
    var jsonStr = jsonEncode({'req_key': imageType[modeType], 'image_url': imageUrl});
    String? reqBody = await VXHttpRequestUtils.getSubmitTask(credential, signature, jsonStr);
    return reqBody;
  }

  static Future<String?> getSingleCreateImageResult(
    String credential,
    String signature,
    int modeType,
    String taskId,
  ) async {
    String? reqBody = await VXHttpRequestUtils.getResultImpl(
      credential,
      signature,
      imageType[modeType],
      taskId,
    );
    return reqBody;
  }

  static Future<String?> getSingleVideoGeneration(
    String credential,
    String signature,
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
    String? reqBody = await VXHttpRequestUtils.getSubmitTask(credential, signature, jsonStr);
    return reqBody;
  }

  static Future<String?> getSingleVideoGenerationResult(
    String credential,
    String signature,
    int modeType,
    String taskId,
  ) async {
    String? reqBody = await VXHttpRequestUtils.getResultImpl(
      credential,
      signature,
      videoType[modeType],
      taskId,
    );
    return reqBody;
  }

  static Future<String?> getVideoUpdateLipShape(
    String credential,
    String signature,
    String mp4,
    String mp3,
  ) async {
    var jsonStr = jsonEncode({'req_key': "realman_change_lips", 'url': mp4, 'pure_audio_url': mp3});
    String? reqBody = await VXHttpRequestUtils.getSubmitTask(credential, signature, jsonStr);
    return reqBody;
  }

  static Future<String?> getVideoUpdateLipShapeResult(
    String credential,
    String signature,
    String taskId,
  ) async {
    String? reqBody = await VXHttpRequestUtils.getResultImpl(
      credential,
      signature,
      "realman_change_lips",
      taskId,
    );
    return reqBody;
  }

  static Future<String?> getAISubjectIdentification(
    String credential,
    String signature,
    String imageUrl,
  ) async {
    var jsonStr = jsonEncode({
      'req_key': "jimeng_realman_avatar_picture_create_role_omni",
      'image_url': imageUrl,
    });
    String? reqBody = await VXHttpRequestUtils.getSubmitTask(credential, signature, jsonStr);
    return reqBody;
  }

  static Future<String?> getAISubjectIdentificationResult(
    String credential,
    String signature,
    String taskId,
  ) async {
    String? reqBody = await VXHttpRequestUtils.getResultImpl(
      credential,
      signature,
      "jimeng_realman_avatar_picture_create_role_omni",
      taskId,
    );
    return reqBody;
  }

  static Future<String?> getAIVideoGeneration(
    String credential,
    String signature,
    String imageUrl,
    String audioUrl,
  ) async {
    var jsonStr = jsonEncode({
      'req_key': "jimeng_realman_avatar_picture_omni_v2",
      'image_url': imageUrl,
      'audio_url': audioUrl,
    });
    String? reqBody = await VXHttpRequestUtils.getSubmitTask(credential, signature, jsonStr);
    return reqBody;
  }

  static Future<String?> getAIVideoGenerationResult(
    String credential,
    String signature,
    String taskId,
  ) async {
    String? reqBody = await VXHttpRequestUtils.getResultImpl(
      credential,
      signature,
      "jimeng_realman_avatar_picture_omni_v2",
      taskId,
    );
    return reqBody;
  }
}
