import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xmvx_interface_plugin_method_channel.dart';

abstract class XmvxInterfacePluginPlatform extends PlatformInterface {
  /// Constructs a XmvxInterfacePluginPlatform.
  XmvxInterfacePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static XmvxInterfacePluginPlatform _instance = MethodChannelXmvxInterfacePlugin();

  /// The default instance of [XmvxInterfacePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelXmvxInterfacePlugin].
  static XmvxInterfacePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XmvxInterfacePluginPlatform] when
  /// they register themselves.
  static set instance(XmvxInterfacePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
