/// ============================================================================
/// 📄 API 客户端
/// ============================================================================
///
/// 用途: 统一的网络请求入口
/// 规则: 所有业务数据获取必须通过此类发起 (铁律 #7)
///
/// 特性:
/// - 基于 Dio 封装
/// - 支持 Mock 数据切换 (通过 AppConfig)
/// - 统一错误处理 (通过 ErrorInterceptor)
/// - 可配置的超时时间
/// ============================================================================

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'interceptors/mock_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// [ApiClient] - API 客户端
///
/// 单例模式，全局唯一实例
/// 通过 locator 注入使用，或直接调用 ApiClient()
///
/// 使用示例:
/// ```dart
/// final apiClient = locator<ApiClient>();
/// final response = await apiClient.get<Map<String, dynamic>>('/users');
/// ```
class ApiClient {
  late Dio _dio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        // 使用 AppConfig 中的配置
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.apiTimeout),
        receiveTimeout: Duration(seconds: AppConfig.apiTimeout),
        contentType: Headers.jsonContentType,
        // 默认响应数据类型
        responseType: ResponseType.json,
      ),
    );

    // 拦截器添加顺序很重要：
    // 1. Mock 拦截器 (开发时返回本地数据)
    // 2. 日志拦截器 (记录请求/响应)
    // 3. 错误拦截器 (统一错误处理)

    // Mock 拦截器 (由 AppConfig.useMock 控制)
    _dio.interceptors.add(MockInterceptor());

    // 日志拦截器 (由 AppConfig.enableNetworkLog 控制)
    if (AppConfig.enableNetworkLog) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (msg) => print('[HTTP] $msg'),
      ));
    }

    // 错误拦截器 (统一处理网络错误)
    _dio.interceptors.add(ErrorInterceptor());

    // 打印当前配置 (仅调试模式)
    AppConfig.printConfig();
  }

  /// 获取底层 Dio 实例 (不推荐直接使用)
  Dio get dio => _dio;

  // ============================================================================
  // GET 请求
  // ============================================================================

  /// 发起 GET 请求
  ///
  /// [path] 请求路径 (会自动拼接 baseUrl)
  /// [queryParameters] URL 查询参数
  /// [options] 额外选项 (如自定义 Header)
  /// [cancelToken] 取消令牌
  ///
  /// 返回: Dio Response 对象
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ============================================================================
  // POST 请求
  // ============================================================================

  /// 发起 POST 请求
  ///
  /// [path] 请求路径
  /// [data] 请求体数据 (Map 或 FormData)
  /// [queryParameters] URL 查询参数
  /// [options] 额外选项
  /// [cancelToken] 取消令牌
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ============================================================================
  // PUT 请求
  // ============================================================================

  /// 发起 PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ============================================================================
  // DELETE 请求
  // ============================================================================

  /// 发起 DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ============================================================================
  // 文件上传
  // ============================================================================

  /// 上传文件
  ///
  /// [path] 上传接口路径
  /// [file] 文件数据 (MultipartFile)
  /// [fieldName] 表单字段名，默认 'file'
  /// [extraData] 附加表单数据
  /// [onProgress] 上传进度回调
  Future<Response<T>> uploadFile<T>(
    String path, {
    required MultipartFile file,
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      fieldName: file,
      ...?extraData,
    });

    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}
