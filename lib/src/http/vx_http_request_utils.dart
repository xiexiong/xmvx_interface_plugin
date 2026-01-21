import 'dart:convert';
import 'package:xmvx_interface_plugin/src/http/vx_interface_httpUtils.dart';

class VXHttpRequestUtils {
  static final VXHttpRequestUtils _instance = VXHttpRequestUtils._internal();

  factory VXHttpRequestUtils() => _instance;
  VXHttpRequestUtils._internal();

  static Future<String?> getSubmitTask(
    String credential,
    String signature,
    dynamic jsonBody,
  ) async {
    return _instance._getCVSubmitTaskImpl(credential, signature, jsonBody);
  }

  Future<String?> _getCVSubmitTaskImpl(
    String credential,
    String signature,
    dynamic jsonBody,
  ) async {
    String jsonResult = await _getRespBody(credential, signature, "CVSubmitTask", jsonBody);
    return jsonResult;
  }

  static Future<String?> getResultImpl(
    String credential,
    String signature,
    String reqKey,
    String taskId,
  ) async {
    return _instance._getCVGetResultImpl(credential, signature, reqKey, taskId);
  }

  Future<String?> _getCVGetResultImpl(
    String credential,
    String signature,
    String reqKey,
    String taskId,
  ) async {
    var jsonStr = jsonEncode({'req_key': reqKey, 'task_id': taskId});
    String jsonResult = await _getRespBody(credential, signature, "CVGetResult", jsonStr);
    var resultBody = jsonDecode(jsonResult);
    if (resultBody['code'] != 10000) {
      return jsonResult;
    }
    if (resultBody['data']['status'] == "done") {
      return jsonResult;
    }
    return "";
  }

  Future<String> _getRespBody(credential, signature, action, jsonStr) async {
    // 创建实例
    final httpSignUtil = VXInterfaceHttputils();
    // 发起请求
    try {
      final response = await httpSignUtil.doRequest(
        method: 'POST',
        bodyJson: jsonStr,
        date: DateTime.now().toUtc(),
        action: action,
        credential: credential,
        signature: signature,
      );
      // ignore: avoid_print
      print('Response status: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
      return response.body;
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
    return "";
  }
}
