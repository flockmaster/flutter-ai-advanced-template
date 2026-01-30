/// ============================================================================
/// 📄 API 响应包装类
/// ============================================================================
///
/// 用途: 统一封装 API 响应，提供一致的错误处理接口
/// 好处: ViewModel 可以统一处理成功/失败状态，无需关心具体的响应格式
/// ============================================================================

/// [ApiResponse] - 通用 API 响应包装
///
/// 泛型 [T] 表示成功时返回的数据类型
/// 
/// 使用示例:
/// ```dart
/// final response = await myService.fetchData();
/// if (response.isSuccess) {
///   print(response.data);
/// } else {
///   print(response.errorMessage);
/// }
/// ```
class ApiResponse<T> {
  /// 是否成功
  final bool success;

  /// 成功时的数据
  final T? data;

  /// 错误信息
  final String? errorMessage;

  /// 错误代码 (业务层面)
  final int? errorCode;

  /// HTTP 状态码
  final int? statusCode;

  /// 原始响应数据 (用于调试)
  final dynamic rawData;

  const ApiResponse._({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.statusCode,
    this.rawData,
  });

  // ============================================================================
  // 工厂方法
  // ============================================================================

  /// 创建成功响应
  factory ApiResponse.success(T data, {int? statusCode, dynamic rawData}) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: statusCode ?? 200,
      rawData: rawData,
    );
  }

  /// 创建失败响应
  factory ApiResponse.failure({
    required String message,
    int? errorCode,
    int? statusCode,
    dynamic rawData,
  }) {
    return ApiResponse._(
      success: false,
      errorMessage: message,
      errorCode: errorCode,
      statusCode: statusCode,
      rawData: rawData,
    );
  }

  /// 从网络错误创建响应
  factory ApiResponse.fromNetworkError(dynamic error) {
    String message = '网络请求失败';

    if (error is Exception) {
      message = error.toString();
    }

    return ApiResponse._(
      success: false,
      errorMessage: message,
      errorCode: -1,
    );
  }

  /// 从标准 API 响应格式解析
  /// 假设后端返回格式为:
  /// { "code": 0, "message": "success", "data": {...} }
  /// 或
  /// { "code": 1001, "message": "xxx error" }
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    final code = json['code'] as int? ?? 0;
    final message = json['message'] as String? ?? '';
    final rawData = json['data'];

    if (code == 0) {
      // 成功
      T? parsedData;
      if (dataParser != null && rawData != null) {
        parsedData = dataParser(rawData);
      } else if (rawData is T) {
        parsedData = rawData;
      }

      return ApiResponse._(
        success: true,
        data: parsedData,
        errorCode: code,
        rawData: json,
      );
    } else {
      // 失败
      return ApiResponse._(
        success: false,
        errorMessage: message,
        errorCode: code,
        rawData: json,
      );
    }
  }

  // ============================================================================
  // 便捷属性
  // ============================================================================

  /// 是否成功
  bool get isSuccess => success;

  /// 是否失败
  bool get isFailure => !success;

  /// 是否有数据
  bool get hasData => data != null;

  // ============================================================================
  // 转换方法
  // ============================================================================

  /// 转换数据类型
  ApiResponse<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      return ApiResponse.success(transform(data as T));
    }
    return ApiResponse.failure(
      message: errorMessage ?? '未知错误',
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  /// 如果成功则执行回调
  void whenSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data as T);
    }
  }

  /// 如果失败则执行回调
  void whenFailure(void Function(String message, int? code) action) {
    if (isFailure) {
      action(errorMessage ?? '未知错误', errorCode);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data)';
    } else {
      return 'ApiResponse.failure(code: $errorCode, message: $errorMessage)';
    }
  }
}

// ============================================================================
// 分页响应扩展
// ============================================================================

/// [PaginatedResponse] - 分页响应包装
///
/// 用于处理分页列表数据
class PaginatedResponse<T> {
  /// 当前页数据
  final List<T> items;

  /// 当前页码
  final int page;

  /// 每页数量
  final int pageSize;

  /// 总数量
  final int total;

  /// 总页数
  final int totalPages;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  /// 是否有下一页
  bool get hasNextPage => page < totalPages;

  /// 是否有上一页
  bool get hasPreviousPage => page > 1;

  /// 是否为第一页
  bool get isFirstPage => page == 1;

  /// 是否为最后一页
  bool get isLastPage => page >= totalPages;

  /// 是否为空
  bool get isEmpty => items.isEmpty;

  /// 从 JSON 解析
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final itemsJson = json['items'] as List? ?? [];
    final items = itemsJson
        .map((e) => itemParser(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}
