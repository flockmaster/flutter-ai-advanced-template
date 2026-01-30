/// ============================================================================
/// 📄 应用配置文件
/// ============================================================================
///
/// 用途: 集中管理应用的环境配置
/// 特性: 支持编译时环境变量注入，可在不修改代码的情况下切换环境
///
/// 使用方法:
/// 开发环境 (Mock 模式):
///   flutter run
///
/// 生产环境:
///   flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.production.com
///
/// 测试环境:
///   flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.staging.com
/// ============================================================================

/// [AppConfig] - 应用配置
///
/// 通过 --dart-define 在编译时注入配置，实现环境切换
/// 所有配置项都有默认值，开发时无需额外参数
class AppConfig {
  AppConfig._();

  // ============================================================================
  // 环境标识
  // ============================================================================

  /// 是否使用 Mock 数据
  /// 默认为 true，开发时使用本地 Mock 数据
  /// 生产环境需要设置为 false
  ///
  /// 使用: --dart-define=USE_MOCK=false
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// 是否为调试模式
  /// 可用于控制日志输出级别、性能监控等
  ///
  /// 使用: --dart-define=DEBUG_MODE=true
  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  // ============================================================================
  // API 配置
  // ============================================================================

  /// API 基础地址
  /// 默认指向预留的 API 地址
  ///
  /// 使用: --dart-define=API_BASE_URL=https://your-api.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.baic.com/v1',
  );

  /// API 请求超时时间 (秒)
  ///
  /// 使用: --dart-define=API_TIMEOUT=30
  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 15,
  );

  // ============================================================================
  // 功能开关
  // ============================================================================

  /// 是否启用网络请求日志
  /// 生产环境建议关闭以提高性能
  ///
  /// 使用: --dart-define=ENABLE_LOG=false
  static const bool enableNetworkLog = bool.fromEnvironment(
    'ENABLE_LOG',
    defaultValue: true,
  );

  /// 是否启用性能监控
  ///
  /// 使用: --dart-define=ENABLE_PERFORMANCE=true
  static const bool enablePerformance = bool.fromEnvironment(
    'ENABLE_PERFORMANCE',
    defaultValue: false,
  );

  // ============================================================================
  // 工具方法
  // ============================================================================

  /// 获取当前环境名称
  static String get environmentName {
    if (useMock) return 'Development (Mock)';
    if (debugMode) return 'Staging';
    return 'Production';
  }

  /// 打印当前配置 (仅调试模式)
  static void printConfig() {
    if (!debugMode) return;

    print('╔══════════════════════════════════════════╗');
    print('║           App Configuration              ║');
    print('╠══════════════════════════════════════════╣');
    print('║ Environment: $environmentName');
    print('║ Use Mock: $useMock');
    print('║ Debug Mode: $debugMode');
    print('║ API Base URL: $apiBaseUrl');
    print('║ API Timeout: ${apiTimeout}s');
    print('║ Network Log: $enableNetworkLog');
    print('║ Performance: $enablePerformance');
    print('╚══════════════════════════════════════════╝');
  }
}
