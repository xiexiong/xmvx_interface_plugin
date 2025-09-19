import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xmvx_interface_plugin/xmvx_interface_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? resourceId;
  // ignore: non_constant_identifier_names
  String mp3 = "http://aidatatest.sharexm.com/ai/DesVoice_Baoge01.mp3";
  String imageUrl =
      "https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_e4aa1f1be7a79946a852463284ca5e87.jpg";
  String mp4 =
      "https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_781b6ce3f43df82d3e313d0d4b936eb9.mp4";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
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
        ),
      ),
    );
  }
}
