// ignore_for_file: file_names

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:xmvx_interface_plugin/src/http/vx_xmvx_signature_util.dart';

class VXInterfaceHttputils {
  VXInterfaceHttputils();

  Future<http.Response> doRequest({
    required String method,
    required String bodyJson,
    required String action,
    required String xDate,
    required String credential,
    required String signature,
  }) async {
    final body = utf8.encode(bodyJson);
    final xContentSha256 = _hashSHA256(body);
    const contentType = 'application/json';
    const signHeader = 'host;x-date;x-content-sha256;content-type';

    final realQueryList = <String, String>{'Action': action, 'Version': '2022-08-31'};
    final querySB = StringBuffer();
    realQueryList.forEach((key, value) {
      querySB
        ..write(VxXmvxSignatureUtil.signStringEncoder(key))
        ..write('=')
        ..write(VxXmvxSignatureUtil.signStringEncoder(value))
        ..write('&');
    });
    final queryString = querySB.toString().substring(0, querySB.length - 1);

    final url = Uri.parse('https://visual.volcengineapi.com/?$queryString');
    final headers = {
      'Host': 'visual.volcengineapi.com',
      'X-Date': xDate,
      'X-Content-Sha256': xContentSha256,
      'Content-Type': contentType,
      'Authorization': [
        'HMAC-SHA256 Credential=$credential',
        'SignedHeaders=$signHeader',
        'Signature=$signature',
      ].join(', '),
    };

    if (method.toUpperCase() == 'GET') {
      return await http.get(url, headers: headers);
    } else {
      return await http.post(url, headers: headers, body: body);
    }
  }

  String _hashSHA256(List<int> content) {
    return sha256.convert(content).toString();
  }
}
