import 'dart:convert';
import 'package:xmvx_interface_plugin/src/http/vx_interface_httpUtils.dart';

class VXHttpRequestUtils {
  static final VXHttpRequestUtils _instance = VXHttpRequestUtils._internal();

  factory VXHttpRequestUtils() => _instance;
  VXHttpRequestUtils._internal();

  static Future<String?> getSubmitTask(dynamic jsonBody) async {
    return _instance._getCVSubmitTaskImpl(jsonBody);
  }

  Future<String?> _getCVSubmitTaskImpl(dynamic jsonBody) async {
    String jsonResult = await _getRespBody("CVSubmitTask", jsonBody);
    return jsonResult;
  }

  static Future<String?> getResultImpl(String reqKey, String taskId) async {
    return _instance._getCVGetResultImpl(reqKey, taskId);
  }

  Future<String?> _getCVGetResultImpl(String reqKey, String taskId) async {
    var jsonStr = jsonEncode({'req_key': reqKey, 'task_id': taskId});
    String jsonResult = await _getRespBody("CVGetResult", jsonStr);
    var resultBody = jsonDecode(jsonResult);
    if (resultBody['code'] != 10000) {
      return jsonResult;
    }
    if (resultBody['data']['status'] == "done") {
      return jsonResult;
    }
    return "";
  }

  Future<String> _getRespBody(action, jsonStr) async {
    // 创建实例
    final httpSignUtil = VXInterfaceHttputils(
      region: 'cn-north-1',
      service: 'cv',
      schema: 'https',
      host: 'visual.volcengineapi.com',
      path: '/',
      ak: 'AKLTZDVlMjUyMmFkNjI0NDVlMzg2ZjhlMTZkZmE4YmYyZDk',
      sk: 'TURSaFlqaGhPV013T1RNeE5EYzNaVGhrWVRKaVlqVTNNVGxqT0RKbVpqSQ==',
    );
    // 发起请求
    try {
      final response = await httpSignUtil.doRequest(
        method: 'POST',
        bodyJson: jsonStr,
        date: DateTime.now().toUtc(),
        action: action,
        version: '2022-08-31',
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
