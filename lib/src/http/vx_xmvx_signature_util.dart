import 'dart:convert';

import 'package:crypto/crypto.dart';

class VxXmvxSignatureUtil {
  static const _urlEncoderChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~';
  static const _hexChars = '0123456789ABCDEF';

  static String generateSignatureParam(String action, String bodyJson) {
    final realQueryList = <String, String>{'Action': action, 'Version': '2022-08-31'};
    final querySB = StringBuffer();
    realQueryList.forEach((key, value) {
      querySB
        ..write(signStringEncoder(key))
        ..write('=')
        ..write(signStringEncoder(value))
        ..write('&');
    });
    final queryString = querySB.toString().substring(0, querySB.length - 1);

    final body = utf8.encode(bodyJson);
    final xContentSha256 = _hashSHA256(body);

    const contentType = 'application/json';

    const signHeader = 'host;x-date;x-content-sha256;content-type';

    final canonicalStringBuilder = [
      'POST',
      '/',
      queryString,
      'host:visual.volcengineapi.com',
      'x-date:xxxx',
      'x-content-sha256:$xContentSha256',
      'content-type:$contentType',
      '',
      signHeader,
      xContentSha256,
    ].join('\n');
    return canonicalStringBuilder;
  }

  static String signStringEncoder(String source) {
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

  static String _hashSHA256(List<int> content) {
    return sha256.convert(content).toString();
  }
}
