import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class HttpUtil {
  static HttpUtil? _instance;
  late Dio _dio;
  CancelToken _cancelToken = CancelToken();

  // 单例模式
  static HttpUtil getInstance() {
    _instance ??= HttpUtil._internal();
    return _instance!;
  }

  HttpUtil._internal() {
    // 基础配置
    BaseOptions options = BaseOptions(
      baseUrl: "https://aichat.sharexm.com", // 替换为你的API地址
      connectTimeout: Duration(milliseconds: 15000),
      receiveTimeout: Duration(milliseconds: 15000),
      responseType: ResponseType.json,
      headers: {"Content-Type": "application/json; charset=utf-8", "Accept": "application/json"},
    );

    _dio = Dio(options);

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 可在请求前添加token等认证信息
          debugPrint('=== 请求参数 ===');
          debugPrint('URL: ${options.uri}');
          debugPrint('Method: ${options.method}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('=== 响应数据 ===');
          debugPrint('Status: ${response.statusCode}');
          debugPrint('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('=== 请求错误 ===');
          debugPrint('Error: ${e.message}');
          debugPrint('Type: ${e.type}');
          return handler.next(e);
        },
      ),
    );
  }

  // GET请求
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST请求
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 文件上传
  Future<Response> uploadFile(
    String url,
    String filePath, {
    String? fieldName,
    Map<String, dynamic>? formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      String fileName = path.basename(filePath);

      FormData data = FormData.fromMap({
        fieldName ?? 'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?formData,
      });

      Response response = await _dio.post(
        url,
        data: data,
        options: options ?? Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken ?? _cancelToken,
        onSendProgress: onSendProgress,
      );

      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 多文件上传
  Future<Response> uploadMultipleFiles(
    String url,
    List<String> filePaths, {
    String fieldName = 'files',
    Map<String, dynamic>? formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      List<MultipartFile> files = [];

      for (String filePath in filePaths) {
        String fileName = path.basename(filePath);
        files.add(await MultipartFile.fromFile(filePath, filename: fileName));
      }

      FormData data = FormData.fromMap({fieldName: files, ...?formData});

      Response response = await _dio.post(
        url,
        data: data,
        options: options ?? Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken ?? _cancelToken,
        onSendProgress: onSendProgress,
      );

      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 下载文件
  Future<Response> downloadFile(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 错误处理
  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        debugPrint("连接超时");
        break;
      case DioExceptionType.sendTimeout:
        debugPrint("发送超时");
        break;
      case DioExceptionType.receiveTimeout:
        debugPrint("接收超时");
        break;
      case DioExceptionType.badCertificate:
        debugPrint("证书错误");
        break;
      case DioExceptionType.badResponse:
        debugPrint("响应错误: ${e.response?.statusCode}");
        break;
      case DioExceptionType.cancel:
        debugPrint("请求取消");
        break;
      case DioExceptionType.connectionError:
        debugPrint("连接错误");
        break;
      case DioExceptionType.unknown:
        debugPrint("未知错误");
        break;
    }
  }

  // 取消请求
  void cancelRequests({CancelToken? cancelToken}) {
    cancelToken?.cancel("取消请求");
    _cancelToken.cancel("取消请求");
    _cancelToken = CancelToken();
  }

  // 更新全局配置
  void updateBaseOptions(BaseOptions options) {
    _dio.options = options;
  }
}
