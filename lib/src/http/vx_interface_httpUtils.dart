// ignore_for_file: file_names

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class VXInterfaceHttputils {
  static const _urlEncoderChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~';
  static const _hexChars = '0123456789ABCDEF';

  final String region;
  final String service;
  final String schema;
  final String host;
  final String path;
  final String ak;
  final String sk;

  VXInterfaceHttputils({
    required this.region,
    required this.service,
    required this.schema,
    required this.host,
    required this.path,
    required this.ak,
    required this.sk,
  });

  Future<http.Response> doRequest({
    required String method,
    required String bodyJson,
    required DateTime date,
    required String action,
    required String version,
  }) async {
    final body = utf8.encode(bodyJson);
    final xContentSha256 = _hashSHA256(body);
    final formatter = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final xDate = formatter.format(date.toUtc());
    final shortXDate = xDate.substring(0, 8);
    const contentType = 'application/json';
    const signHeader = 'host;x-date;x-content-sha256;content-type';

    final realQueryList = <String, String>{'Action': action, 'Version': version};
    final querySB = StringBuffer();
    realQueryList.forEach((key, value) {
      querySB
        ..write(_signStringEncoder(key))
        ..write('=')
        ..write(_signStringEncoder(value))
        ..write('&');
    });
    final queryString = querySB.toString().substring(0, querySB.length - 1);

    final canonicalStringBuilder = [
      method,
      path,
      queryString,
      'host:$host',
      'x-date:$xDate',
      'x-content-sha256:$xContentSha256',
      'content-type:$contentType',
      '',
      signHeader,
      xContentSha256,
    ].join('\n');

    final hashCanonicalString = _hashSHA256(utf8.encode(canonicalStringBuilder));
    final credentialScope = '$shortXDate/$region/$service/request';
    final signString = ['HMAC-SHA256', xDate, credentialScope, hashCanonicalString].join('\n');

    final signKey = _genSigningSecretKeyV4(sk, shortXDate, region, service);
    final signature = _hmacSHA256(signKey, signString);

    final url = Uri.parse('$schema://$host$path?$queryString');
    final headers = {
      'Host': host,
      'X-Date': xDate,
      'X-Content-Sha256': xContentSha256,
      'Content-Type': contentType,
      'Authorization': [
        'HMAC-SHA256 Credential=$ak/$credentialScope',
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

  String _signStringEncoder(String source) {
    if (source.isEmpty) return '';
    final result = StringBuffer();
    for (final rune in source.runes) {
      final char = String.fromCharCode(rune);
      if (_urlEncoderChars.contains(char)) {
        result.write(char);
      } else if (char == ' ') {
        result.write('%20');
      } else {
        result
          ..write('%')
          ..write(_hexChars[(rune >> 4) & 0xF])
          ..write(_hexChars[rune & 0xF]);
      }
    }
    return result.toString();
  }

  String _hashSHA256(List<int> content) {
    return sha256.convert(content).toString();
  }

  String _hmacSHA256(List<int> key, String content) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(content)).toString();
  }

  List<int> _genSigningSecretKeyV4(String secretKey, String date, String region, String service) {
    final kDate = _hmacSHA256Raw(utf8.encode(secretKey), utf8.encode(date));
    final kRegion = _hmacSHA256Raw(kDate, utf8.encode(region));
    final kService = _hmacSHA256Raw(kRegion, utf8.encode(service));
    return _hmacSHA256Raw(kService, utf8.encode('request'));
  }

  List<int> _hmacSHA256Raw(List<int> key, List<int> content) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(content).bytes;
  }
}

// var jsonStr = jsonEncode({
//                   'req_key': 'realman_change_lips',
//                   'url':
//                       'https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_781b6ce3f43df82d3e313d0d4b936eb9.mp4',
//                   'pure_audio_url':
//                       'http://yofotoai-test.oss-cn-hangzhou.aliyuncs.com/ai/voice_text.wav',
//                 });
// _getRespBody("CVSubmitTask", jsonStr);

// void _getRespBody(action, jsonStr) async {
//     // 创建实例
//     final httpSignUtil = HttpSignUtil(
//       region: 'cn-north-1',
//       service: 'cv',
//       schema: 'https',
//       host: 'visual.volcengineapi.com',
//       path: '/',
//       ak: 'AKLTZDVlMjUyMmFkNjI0NDVlMzg2ZjhlMTZkZmE4YmYyZDk',
//       sk: 'TURSaFlqaGhPV013T1RNeE5EYzNaVGhrWVRKaVlqVTNNVGxqT0RKbVpqSQ==',
//     );
//     // 发起请求
//     try {
//       final response = await httpSignUtil.doRequest(
//         method: 'POST',
//         bodyJson: jsonStr,
//         date: DateTime.now().toUtc(),
//         action: action,
//         version: '2022-08-31',
//       );
//       // ignore: avoid_print
//       print('Response status: ${response.statusCode}');
//       // ignore: avoid_print
//       print('Response body: ${response.body}');
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error: $e');
//     }
//   }
