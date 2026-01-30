/// ============================================================================
/// 📄 错误拦截器
/// ============================================================================
///
/// 用途: 统一处理网络请求错误
/// 功能:
/// - 友好的错误信息转换
/// - 日志记录
/// - 特殊错误码处理 (如 Token 过期)
/// ============================================================================

import 'package:dio/dio.dart';
import '../../config/app_config.dart';

/// [ErrorInterceptor] - 错误拦截器
///
/// 拦截所有网络错误，进行统一处理和转换
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 记录错误日志 (仅开发模式)
    if (AppConfig.enableNetworkLog) {
      _logError(err);
    }

    // 转换为友好的错误信息
    final friendlyError = _transformError(err);

    handler.next(friendlyError);
  }

  /// 记录错误日志
  void _logError(DioException err) {
    print('╔══════════════════════════════════════════╗');
    print('║           Network Error                  ║');
    print('╠══════════════════════════════════════════╣');
    print('║ URL: ${err.requestOptions.uri}');
    print('║ Method: ${err.requestOptions.method}');
    print('║ Type: ${err.type}');
    print('║ Status Code: ${err.response?.statusCode}');
    print('║ Message: ${err.message}');
    if (err.response?.data != null) {
      print('║ Response: ${err.response?.data}');
    }
    print('╚══════════════════════════════════════════╝');
  }

  /// 转换错误为友好的错误信息
  DioException _transformError(DioException err) {
    String friendlyMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        friendlyMessage = '连接超时，请检查网络后重试';
        break;

      case DioExceptionType.sendTimeout:
        friendlyMessage = '请求超时，请检查网络后重试';
        break;

      case DioExceptionType.receiveTimeout:
        friendlyMessage = '响应超时，请稍后重试';
        break;

      case DioExceptionType.badResponse:
        friendlyMessage = _handleBadResponse(err.response);
        break;

      case DioExceptionType.cancel:
        friendlyMessage = '请求已取消';
        break;

      case DioExceptionType.connectionError:
        friendlyMessage = '网络连接失败，请检查网络设置';
        break;

      case DioExceptionType.badCertificate:
        friendlyMessage = '证书验证失败';
        break;

      case DioExceptionType.unknown:
      default:
        if (err.message?.contains('SocketException') == true) {
          friendlyMessage = '网络连接失败，请检查网络设置';
        } else {
          friendlyMessage = '未知错误，请稍后重试';
        }
        break;
    }

    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: friendlyMessage,
    );
  }

  /// 处理 HTTP 错误状态码
  String _handleBadResponse(Response? response) {
    if (response == null) {
      return '服务器无响应';
    }

    final statusCode = response.statusCode ?? 0;

    // 尝试从响应体获取错误信息
    String? serverMessage;
    if (response.data is Map) {
      serverMessage = response.data['message'] as String? ??
          response.data['error'] as String?;
    }

    switch (statusCode) {
      case 400:
        return serverMessage ?? '请求参数错误';

      case 401:
        // 可以在这里触发退出登录逻辑
        // _handleUnauthorized();
        return '登录已过期，请重新登录';

      case 403:
        return '没有权限访问';

      case 404:
        return '请求的资源不存在';

      case 500:
        return '服务器内部错误';

      case 502:
        return '网关错误';

      case 503:
        return '服务暂时不可用';

      case 504:
        return '网关超时';

      default:
        if (statusCode >= 500) {
          return '服务器错误 ($statusCode)';
        } else if (statusCode >= 400) {
          return serverMessage ?? '请求错误 ($statusCode)';
        }
        return '未知错误 ($statusCode)';
    }
  }

  // ============================================================================
  // 特殊错误处理 (可扩展)
  // ============================================================================

  /// 处理未授权错误 (Token 过期)
  /// 可以在这里调用全局的退出登录逻辑
  // void _handleUnauthorized() {
  //   // 清除本地 Token
  //   // 跳转到登录页
  //   // 发送事件通知
  // }
}

// ============================================================================
// 自定义业务异常
// ============================================================================

/// [ApiException] - API 业务异常
///
/// 用于表示业务层面的错误（code != 0 的情况）
class ApiException implements Exception {
  /// 错误代码
  final int code;

  /// 错误信息
  final String message;

  /// 原始响应数据
  final dynamic data;

  const ApiException({
    required this.code,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException: [$code] $message';

  /// 是否为 Token 过期错误
  bool get isTokenExpired => code == 401 || code == 10001;

  /// 是否为参数错误
  bool get isParamError => code == 400 || (code >= 40000 && code < 50000);
}
