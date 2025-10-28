import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xmvx_interface_plugin/xmvx_interface_plugin.dart';
import 'package:xmvx_interface_plugin_example/dio_util.dart';
import 'package:xmvx_interface_plugin_example/image_picket_util.dart';
import 'package:xmvx_interface_plugin_example/sequential_task_handler.dart';
import 'package:xmvx_interface_plugin_example/toast_util.dart';
import 'package:xmvx_interface_plugin_example/viceo_player_webview.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDemo = true;
  String? resourceId;
  // ignore: non_constant_identifier_names
  String mp3 = "http://aidatatest.sharexm.com/ai/DesVoice_Baoge01.mp3";
  String imageUrl =
      "https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_9163ee9a21ff32e0ed69a78c00f6fb30.jpeg";
  String mp4 =
      "https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_781b6ce3f43df82d3e313d0d4b936eb9.mp4";

  final HttpUtil http = HttpUtil.getInstance();
  final TextEditingController _editingController = TextEditingController();
  File? _selectedImage;
  String uploadFileUrl = "";
  List<String> viceoMp3List = [];
  // 耗时任务定时器
  final SequentialTaskHandler _handler = SequentialTaskHandler();
  // ignore: unused_field
  double _progress = 0.0;
  String _status = '等待开始';
  // ignore: prefer_final_fields
  List<String> _logMessages = [];
  bool _isErrorTask = false;

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
        // _logMessages.add('[$_getCurrentTime()] $status');
      });
      if (_status == "所有任务处理完成") {
        if (_isErrorTask) {
          ToastUtils.show(context: context, message: "生成视频失败，请联系管理员");
        } else {
          debugPrint("所有任务处理完成结果:$_logMessages");
          _postRequestVideoJoin(_logMessages);
        }
      }
    });

    _handler.resultStream.listen((result) {
      if (result["status"] == "completed") {
        var obj = jsonDecode(result["result"]);
        if (obj['code'] == 10000) {
          String videoUrl = obj['data']['video_url'];
          setState(() {
            _logMessages.add(videoUrl);
          });
          debugPrint("任务结果：$_logMessages");
        } else {
          setState(() {
            _isErrorTask = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: _appBar()),
      body: isDemo ? _demo() : _ItemTest(),
    );
  }

  Widget _appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('当前状态: $_status', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        SizedBox(width: 60),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
            child: GestureDetector(
              onTap: () {
                if (_selectedImage?.path == null) {
                  ToastUtils.show(context: context, message: "请选择图片");
                  return;
                }
                if (_editingController.text.isEmpty) {
                  ToastUtils.show(context: context, message: "请输入文案");
                  return;
                }
                setState(() {
                  _status = '上传中...';
                  _isErrorTask = false;
                });
                _uploadFile(_selectedImage?.path ?? "", _editingController.text);
                // _postRequestVideoJoin(_logMessages);
                // Navigator.push(context, MaterialPageRoute(builder: (context) => TaskExamplePage()));$_status
              },
              child: Center(child: Text("合成", style: TextStyle(color: Colors.white, fontSize: 16))),
            ),
          ),
        ),
      ],
    );
  }

  // 文件上传示例
  void _uploadFile(String filePath, String viceoTxt) async {
    // 检查文件是否存在
    File file = File(filePath);
    if (!await file.exists()) {
      // ignore: use_build_context_synchronously
      ToastUtils.show(context: context, message: "文件不存在: $filePath");
      setState(() {
        _status = '上传失败...';
      });
      return;
    }

    try {
      var response = await http.uploadFile(
        '/v2/public/upload',
        filePath,
        onSendProgress: (int sent, int total) {
          double progress = sent / total * 100;
          debugPrint('上传进度: ${progress.toStringAsFixed(2)}%');
        },
      );

      setState(() {
        uploadFileUrl = response.data["data"]["url"];
      });
      debugPrint("上创文件返回地址==> $uploadFileUrl");
      _postRequest(viceoTxt);
    } catch (e) {
      ToastUtils.show(context: context, message: "文件上传失败");
      setState(() {
        _status = '上传失败...';
      });
    }
  }

  // POST请求示例
  void _postRequest(String viceoTxt) async {
    try {
      var response = await http.post('/voice/textToVoice', data: {'text': viceoTxt});
      setState(() {
        viceoMp3List = List<String>.from(response.data["data"]["urlList"]);
      });
      debugPrint("文字转语音返回数据==> $viceoMp3List");
      _imageRecognition(viceoMp3List);
    } catch (e) {
      setState(() {
        _status = '上传失败...';
      });
      ToastUtils.show(context: context, message: "文字转语音失败");
    }
  }

  // POST请求示例视频拼接
  void _postRequestVideoJoin(List<String> _logMessages) async {
    try {
      var response = await http.post('/v2/public/videoJoin', data: {'videoList': _logMessages});
      debugPrint("视频拼接返回数据==> $response");
      var json = response.data;
      if (json['code'] == 200 && json['msg'] == 'OK') {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) {
              return VideoPlayerWebview(videoUrl: json['data']['url']);
            },
          ),
        );
      }
    } catch (e) {
      ToastUtils.show(context: context, message: "视频拼接失败");
    }
  }

  void _imageRecognition(List<String> viceoMp3List) async {
    String? response = await XmvxInterfacePlugin.getAISubjectIdentification(uploadFileUrl);
    if (response != null) {
      var obj = jsonDecode(response);
      if (obj['code'] == 10000 && obj['data']['status'] == 'done') {
        _generateVideoTasks(uploadFileUrl, viceoMp3List);
      } else {
        setState(() {
          _status = '上传失败...';
        });
        ToastUtils.show(context: context, message: "AI形象识别失败");
      }
    }
  }

  /// 批量添加任务示例
  void _generateVideoTasks(String imagePath, List<String> viceoMp3List) {
    _logMessages.clear();

    final List<Future<String?> Function()> tasks = [
      // () async {
      //   String? response = await XmvxInterfacePlugin.getAIVideoGeneration(
      //     "https://yofotoai.oss-cn-hangzhou.aliyuncs.com/ai/attache/0-34dacfbI5oisCbp70eH1TAXWK3p-text.jpg",
      //     mp3,
      //   );
      //   return response;
      // },
    ];

    viceoMp3List.asMap().forEach((index, item) {
      tasks.add(() async {
        String? response = await XmvxInterfacePlugin.getAIVideoGeneration(
          imagePath,
          // "https://yofotoai.oss-cn-hangzhou.aliyuncs.com/ai/textToVoice/34fsr6btt2DfqZk8ECR77UL3yVr_part_${index + 1}.mp3",
          item,
        );
        return response;
      });
    });

    _handler.addTasks(tasks);
  }

  Widget _demo() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  final image = await ImagePickerUtil.pickImage(context: context);
                  if (image != null) {
                    setState(() => _selectedImage = image);
                  }
                },
                child: Container(
                  width: 205,
                  height: 335,
                  color:
                      _selectedImage == null ? const Color.fromARGB(255, 88, 87, 87) : Colors.white,
                  child: Center(
                    child:
                        _selectedImage == null
                            ? Text(
                              "请选择图片",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 163, 161, 161),
                                fontSize: 16,
                              ),
                            )
                            : Image.file(
                              File(_selectedImage?.path ?? ""),
                              width: 205,
                              height: 335,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            width: 343,
            height: 300,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 88, 87, 87),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _editingController,
                maxLines: null,
                maxLength: 1000,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "请输入文案...",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 163, 161, 161),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _ItemTest() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            // 普通模式：0，灵动模式：1，大画幅灵动模式：2
            String? version = await XmvxInterfacePlugin.getSingleCreateImage(1, imageUrl);
            var obj = jsonDecode(version ?? "");
            if (obj['code'] == 10000) {
              var objResId = jsonDecode(obj['data']['resp_data']);
              resourceId = objResId["resource_id"];
            }
            // ignore: avoid_print, unnecessary_brace_in_string_interps
            print("单图-形象创建 resourceId：${resourceId}");
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(child: Text("单图-形象创建")),
          ),
        ),
        Container(height: 20),
        GestureDetector(
          onTap: () async {
            // 普通模式：0，灵动模式：1，大画幅灵动模式：2
            String? version = await XmvxInterfacePlugin.getSingleVideoGeneration(
              1,
              mp3,
              resourceId ?? "",
            );
            // ignore: avoid_print, unnecessary_brace_in_string_interps
            print("单图-视频生成：${version}");
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(child: Text("单图-视频生成")),
          ),
        ),
        Container(height: 20),
        GestureDetector(
          onTap: () async {
            String? version = await XmvxInterfacePlugin.getVideoUpdateLipShape(mp4, mp3);
            print("改口型 ：${version}");
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(child: Text("改口型")),
          ),
        ),
        Container(height: 20),
        GestureDetector(
          onTap: () async {
            String? version = await XmvxInterfacePlugin.getAISubjectIdentification(imageUrl);
            print("即梦——AI形象识别：${version}");
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(child: Text("即梦——AI形象识别")),
          ),
        ),
        Container(height: 20),
        GestureDetector(
          onTap: () async {
            String? version = await XmvxInterfacePlugin.getAIVideoGeneration(imageUrl, mp3);
            print("即梦——AI视频生成：${version}");
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(child: Text("即梦——AI视频生成")),
          ),
        ),
        Container(height: 80),
      ],
    );
  }
}
