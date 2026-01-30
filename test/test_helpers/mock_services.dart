/// ============================================================================
/// 📄 Mock 服务集合
/// ============================================================================
///
/// 用途: 提供测试用的 Mock 服务实现
/// 使用: 在测试文件中导入并注册到 locator
///
/// 包含:
/// - MockNavigationService: 模拟导航服务
/// - MockDialogService: 模拟弹窗服务
/// - MockApiClient: 模拟 API 客户端
/// ============================================================================

// import 'package:mockito/mockito.dart';
// import 'package:stacked_services/stacked_services.dart';
// import 'package:flutter_template/core/network/api_client.dart';
// import 'package:flutter_template/app/app.locator.dart';

// ============================================================================
// Stacked Services Mocks
// ============================================================================

/// Mock NavigationService
/// 
/// 用于测试 ViewModel 中的导航逻辑
// class MockNavigationService extends Mock implements NavigationService {}

/// Mock DialogService
/// 
/// 用于测试 ViewModel 中的弹窗逻辑
// class MockDialogService extends Mock implements DialogService {}

/// Mock BottomSheetService
/// 
/// 用于测试底部弹窗逻辑
// class MockBottomSheetService extends Mock implements BottomSheetService {}

// ============================================================================
// API Client Mock
// ============================================================================

/// Mock ApiClient
/// 
/// 用于模拟 API 请求和响应
// class MockApiClient extends Mock implements ApiClient {}

// ============================================================================
// 测试辅助函数
// ============================================================================

/// 设置测试环境的 Locator
/// 
/// 在 setUp() 中调用此函数注册所有 Mock 服务
/// 
/// 使用示例:
/// ```dart
/// setUp(() {
///   setupTestLocator();
/// });
/// ```
void setupTestLocator() {
  // 如果 locator 已经设置，先清理
  // if (locator.isRegistered<NavigationService>()) {
  //   locator.unregister<NavigationService>();
  // }
  
  // 注册 Mock 服务
  // locator.registerSingleton<NavigationService>(MockNavigationService());
  // locator.registerSingleton<DialogService>(MockDialogService());
  // locator.registerSingleton<ApiClient>(MockApiClient());
}

/// 清理测试环境的 Locator
/// 
/// 在 tearDown() 中调用此函数取消注册所有 Mock 服务
void tearDownTestLocator() {
  // locator.unregister<NavigationService>();
  // locator.unregister<DialogService>();
  // locator.unregister<ApiClient>();
}

// ============================================================================
// 常用测试数据
// ============================================================================

/// 测试用的示例数据
class TestData {
  /// 示例用户数据
  static Map<String, dynamic> get sampleUser => {
    'id': 'user_001',
    'name': '测试用户',
    'email': 'test@example.com',
    'avatar': 'https://example.com/avatar.jpg',
  };
  
  /// 示例商品列表
  static List<Map<String, dynamic>> get sampleProducts => [
    {
      'id': 'prod_001',
      'name': '商品 A',
      'price': 9900,
      'image': 'https://example.com/product1.jpg',
    },
    {
      'id': 'prod_002',
      'name': '商品 B',
      'price': 19900,
      'image': 'https://example.com/product2.jpg',
    },
  ];
  
  /// 示例分页响应
  static Map<String, dynamic> get samplePaginatedResponse => {
    'code': 0,
    'message': 'success',
    'data': {
      'items': sampleProducts,
      'page': 1,
      'page_size': 10,
      'total': 2,
      'total_pages': 1,
    },
  };
  
  /// 示例错误响应
  static Map<String, dynamic> get sampleErrorResponse => {
    'code': 1001,
    'message': '请求参数错误',
    'data': null,
  };
}
