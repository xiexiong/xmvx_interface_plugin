import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xmvx_interface_plugin_platform_interface.dart';

/// An implementation of [XmvxInterfacePluginPlatform] that uses method channels.
class MethodChannelXmvxInterfacePlugin extends XmvxInterfacePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xmvx_interface_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
