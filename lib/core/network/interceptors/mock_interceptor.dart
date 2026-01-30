import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';

/// [MockInterceptor] - Mock 数据拦截器
///
/// 功能: 在开发阶段拦截网络请求，返回本地 Mock 数据
/// 控制: 通过 AppConfig.useMock 开关控制是否启用
/// 
/// Mock 文件规则:
/// - 请求路径 /user/profile → assets/mock/user/profile.json
/// - 请求路径 /items/123 → assets/mock/items/123.json
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 使用 AppConfig 控制 Mock 开关，替代硬编码
    // 通过 --dart-define=USE_MOCK=false 可在编译时关闭
    if (AppConfig.useMock) {
      try {
        // 尝试从 assets/mock 目录读取对应的 json 文件
        // 例如 path 为 /user/profile -> assets/mock/user/profile.json
        String path = options.path;
        if (path.startsWith('/')) path = path.substring(1);
        
        // 处理 query parameters (可选，简单处理)
        if (path.contains('?')) {
          path = path.split('?')[0];
        }
        
        final String fileName = 'assets/mock/$path.json';
        
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 500));

        // 注意：这里需要确保文件存在，否则会抛出异常进入 catch
        final String responseData = await rootBundle.loadString(fileName);
        final dynamic json = jsonDecode(responseData);

        handler.resolve(
          Response(
            requestOptions: options,
            data: json,
            statusCode: 200,
          ),
        );
        return;
      } catch (e) {
        // 如果找不到 mock 文件，则继续请求真实接口
        print('Mock file not found or error for path ${options.path}: $e. Proceeding to real API.');
      }
    }
    
    super.onRequest(options, handler);
  }
}
