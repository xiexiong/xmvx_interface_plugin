import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  static final SPUtil _instance = SPUtil._internal();
  late SharedPreferences _prefs;

  // 单例构造
  factory SPUtil() => _instance;
  SPUtil._internal();

  // 初始化方法
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 存储方法
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  // 读取方法
  String? getString(String key) => _prefs.getString(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  bool? getBool(String key) => _prefs.getBool(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // 删除方法
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // 检查是否存在
  bool containsKey(String key) => _prefs.containsKey(key);
}



// 初始化
// await SPUtil().init();

// // 存储数据
// await SPUtil().setString('username', 'flutter_user');
// await SPUtil().setInt('login_count', 5);
// await SPUtil().setBool('dark_mode', true);

// // 读取数据
// String? name = SPUtil().getString('username');
// int? count = SPUtil().getInt('login_count');
// bool? isDark = SPUtil().getBool('dark_mode');

// // 删除数据
// await SPUtil().remove('login_count');

// // 清空所有数据
// await SPUtil().clear();