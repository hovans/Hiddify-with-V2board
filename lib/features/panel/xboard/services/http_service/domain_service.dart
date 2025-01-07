// services/domain_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DomainService {
  // 定义多个 ossDomain 地址
  static const List<String> ossDomains = [
    'https://vdawa.oss-cn-hongkong.aliyuncs.com/boost/config.json',
    'https://boost.ossconfig.top/config.json',
    'https://boost.ossconfig1.top/config.json',
    'https://boost.ossconfig2.top/config.json',
    'https://boost.ossconfig3.top/config.json',
    'https://boost.ossconfig4.top/config.json',
    'https://boost.ossconfig5.top/config.json',
    'https://boost.ossconfig6.top/config.json',
    'https://boost.ossconfig7.top/config.json',
    'https://boost.ossconfig8.top/config.json',
    'https://boost.ossconfig9.top/config.json',
    'https://boost.ossconfig10.top/config.json'
  ];

  // 从多个 ossDomain 中获取 JSON 并挑选一个可以正常访问的域名
  static Future<String> fetchValidDomain() async {
    for (final ossDomain in ossDomains) {
      try {
        // 获取 JSON 配置文件
        final response = await http.get(Uri.parse(ossDomain)).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List<dynamic> websites = json.decode(response.body) as List<dynamic>;

          // 遍历 JSON 文件中的每个域名
          for (final website in websites) {
            final Map<String, dynamic> websiteMap = website as Map<String, dynamic>;
            final String domain = websiteMap['url'] as String;

            // 检查域名的可访问性
            if (await _checkDomainAccessibility(domain)) {
              if (kDebugMode) {
                print('Valid domain found: $domain');
              }
              return domain;
            }
          }
          print('No accessible domains found in $ossDomain.');
        } else {
          print('Failed to fetch JSON from $ossDomain. Status code: ${response.statusCode}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching from $ossDomain: $e');
        }
      }
    }
    throw Exception('No accessible domains found across all OSS domains.');
  }

  static Future<bool> _checkDomainAccessibility(String domain) async {
    try {
      final response = await http.get(Uri.parse('$domain/api/v1/guest/comm/config')).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
