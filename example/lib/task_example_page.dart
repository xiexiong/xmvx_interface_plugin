import 'package:flutter/material.dart';
import 'package:xmvx_interface_plugin_example/sequential_task_handler.dart';

class TaskExamplePage extends StatefulWidget {
  const TaskExamplePage({super.key});

  @override
  State<TaskExamplePage> createState() => _TaskExamplePageState();
}

class _TaskExamplePageState extends State<TaskExamplePage> {
  final SequentialTaskHandler _handler = SequentialTaskHandler();
  double _progress = 0.0;
  String _status = '等待开始';
  List<String> _logMessages = [];

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _handler.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    _handler.statusStream.listen((status) {
      setState(() {
        _status = status;
        _logMessages.add('[$_getCurrentTime()] $status');
      });
    });

    _handler.resultStream.listen((result) {
      setState(() {
        _logMessages.add(
          '[$_getCurrentTime()] 任务${result['taskIndex'] + 1} ${result['status'] == 'completed' ? '完成' : '失败'}',
        );
      });
    });
  }

  String _getCurrentTime() {
    return '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';
  }

  /// 示例耗时任务1 - 模拟网络请求
  Future<String> _simulateNetworkRequest() async {
    await Future.delayed(Duration(seconds: 2));
    return '网络请求数据';
  }

  /// 示例耗时任务2 - 模拟文件处理
  Future<String> _simulateFileProcessing() async {
    await Future.delayed(Duration(seconds: 3));
    return '文件处理完成';
  }

  /// 示例耗时任务3 - 模拟数据处理
  Future<int> _simulateDataProcessing() async {
    await Future.delayed(Duration(seconds: 1));
    return 42; // 示例返回值
  }

  /// 示例耗时任务4 - 模拟数据库操作
  Future<List<String>> _simulateDatabaseOperation() async {
    await Future.delayed(Duration(seconds: 2));
    return ['数据1', '数据2', '数据3'];
  }

  /// 开始顺序执行任务
  void _startSequentialTasks() {
    _logMessages.clear();

    // 添加任务到队列
    _handler.addTask(() async {
      print('开始执行任务1');
      return await _simulateNetworkRequest();
    });

    _handler.addTask(() async {
      print('开始执行任务2');
      return await _simulateFileProcessing();
    });

    _handler.addTask(() async {
      print('开始执行任务3');
      return await _simulateDataProcessing();
    });

    _handler.addTask(() async {
      print('开始执行任务4');
      return await _simulateDatabaseOperation();
    });
  }

  /// 批量添加任务示例
  void _startBatchTasks() {
    _logMessages.clear();

    final tasks = [
      () async {
        await Future.delayed(Duration(seconds: 3));
        return '批量任务1完成';
      },
      () async {
        await Future.delayed(Duration(seconds: 10));
        return '批量任务2完成';
      },
      () async {
        await Future.delayed(Duration(seconds: 7));
        return '批量任务3完成';
      },
    ];

    _handler.addTasks(tasks);
  }

  /// 使用 isolate 执行计算密集型任务
  Future<void> _startIsolateTask() async {
    try {
      setState(() {
        _status = 'isolate 任务执行中...';
      });

      final result = await IsolateTaskHandler.execute<int>(
        task: () {
          // 模拟计算密集型任务
          int sum = 0;
          for (int i = 0; i < 1000000; i++) {
            sum += i;
          }
          return sum;
        },
        onProgress: (progress) {
          print('isolate 进度: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      setState(() {
        _status = 'isolate 任务完成，结果: $result';
        _logMessages.add('[$_getCurrentTime()] isolate 任务完成: $result');
      });
    } catch (e) {
      setState(() {
        _status = 'isolate 任务失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('耗时任务处理器示例'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _handler.clearTasks,
            tooltip: '清空任务队列',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 进度显示区域
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('任务进度监控', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    LinearProgressIndicator(value: _progress),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${(_progress * 100).toStringAsFixed(1)}%'),
                        Chip(
                          label: Text(
                            _handler.isProcessing ? '处理中' : '空闲',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _handler.isProcessing ? Colors.blue : Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('当前状态: $_status', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 控制按钮区域
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('任务控制', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _startSequentialTasks,
                          icon: Icon(Icons.play_arrow),
                          label: Text('开始顺序任务'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _startBatchTasks,
                          icon: Icon(Icons.list),
                          label: Text('批量任务'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _startIsolateTask,
                          icon: Icon(Icons.settings),
                          label: Text('Isolate任务'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _handler.clearTasks,
                          icon: Icon(Icons.clear),
                          label: Text('清空队列'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 任务信息区域
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('任务队列信息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        InfoItem('队列任务数', '${_handler.taskCount}'),
                        SizedBox(width: 20),
                        InfoItem('处理状态', _handler.isProcessing ? '运行中' : '已停止'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 日志区域
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('执行日志', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Spacer(),
                          TextButton(
                            onPressed:
                                () => setState(() {
                                  _logMessages.clear();
                                }),
                            child: Text('清空日志'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _logMessages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(_logMessages[index], style: TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _handler.dispose();
    super.dispose();
  }
}

/// 信息展示组件
class InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const InfoItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
