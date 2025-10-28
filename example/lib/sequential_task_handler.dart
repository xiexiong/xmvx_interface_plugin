import 'dart:async';
import 'dart:isolate';

/// 顺序执行耗时任务的工具类
/// 确保循环中的每个任务按顺序执行，前一个完成后再开始下一个
class SequentialTaskHandler {
  final List<Future Function()> _tasks = [];
  bool _isProcessing = false;
  final StreamController<double> _progressController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<dynamic> _resultController = StreamController<dynamic>.broadcast();

  /// 添加单个任务到队列
  void addTask(Future Function() task) {
    _tasks.add(task);
    if (!_isProcessing) {
      _startProcessing();
    }
  }

  /// 批量添加任务
  void addTasks(List<Future Function()> tasks) {
    _tasks.addAll(tasks);
    if (!_isProcessing) {
      _startProcessing();
    }
  }

  /// 开始顺序处理任务队列
  Future<void> _startProcessing() async {
    _isProcessing = true;
    _statusController.add('任务处理开始，共 ${_tasks.length} 个任务');

    for (int i = 0; i < _tasks.length; i++) {
      try {
        // 更新进度
        double progress = i / _tasks.length;
        _progressController.add(progress);
        _statusController.add('正在执行任务 ${i + 1}/${_tasks.length}');

        // 执行当前任务并等待完成
        dynamic result = await _tasks[i]();

        // 发送任务完成结果
        _resultController.add({'taskIndex': i, 'result': result, 'status': 'completed'});

        // 给事件循环处理其他任务的机会，避免阻塞UI
        await Future.delayed(Duration.zero);
      } catch (e) {
        // if (_statusController.isClosed) return;
        _statusController.add('任务 ${i + 1} 执行失败: $e');
        _resultController.add({'taskIndex': i, 'error': e.toString(), 'status': 'failed'});
        // 继续执行后续任务
      }
    }

    // 所有任务完成
    _tasks.clear();
    _isProcessing = false;
    _progressController.add(1.0);
    _statusController.add('所有任务处理完成');
  }

  /// 获取进度流 - 0.0 到 1.0
  Stream<double> get progressStream => _progressController.stream;

  /// 获取状态流
  Stream<String> get statusStream => _statusController.stream;

  /// 获取结果流
  Stream<dynamic> get resultStream => _resultController.stream;

  /// 清空任务队列
  void clearTasks() {
    _tasks.clear();
    _isProcessing = false;
    _statusController.add('任务队列已清空');
  }

  /// 获取当前任务数量
  int get taskCount => _tasks.length;

  /// 是否正在处理任务
  bool get isProcessing => _isProcessing;

  /// 销毁资源
  void dispose() {
    _progressController.close();
    _statusController.close();
    _resultController.close();
  }
}

/// Isolate 任务处理器 - 用于计算密集型任务
class IsolateTaskHandler {
  /// 使用 isolate 执行计算密集型任务
  static Future<T> execute<T>({
    required T Function() task,
    void Function(double progress)? onProgress,
  }) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(_isolateEntry, receivePort.sendPort);

    final sendPort = await receivePort.first as SendPort;
    final responsePort = ReceivePort();

    sendPort.send({'task': task, 'sendPort': responsePort.sendPort});

    final result = await responsePort.first;

    if (result is Exception) {
      throw result;
    }
    return result as T;
  }

  static void _isolateEntry(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (final message in receivePort) {
      final task = message['task'] as Function();
      final responseSendPort = message['sendPort'] as SendPort;

      try {
        final result = task();
        responseSendPort.send(result);
      } catch (e) {
        responseSendPort.send(e);
      }
    }
  }
}
