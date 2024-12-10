import 'package:app_coosiv/features/shared/infrastructure/services/key_value_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStorageImpl extends KeyValueStorage {
  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Future<T?> getValue<T>(String key) async {
    final prefs = await getSharedPrefs();
    switch (T) {
      case int:
        return prefs.getInt(key) as T?;
      case String:
        return prefs.getString(key) as T?;
      default:
        throw UnimplementedError("GET not impmented for type ${T.runtimeType}");
    }
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    final prefs = await getSharedPrefs();
    switch (T) {
      case int:
        prefs.setInt(key, value as int);
        break;
      case String:
        prefs.setString(key, value as String);
        break;
      default:
        throw UnimplementedError("Set not impmented for type ${T.runtimeType}");
    }
  }

  @override
  Future<bool> removeKeyValue(String key) async {
    final prefs = await getSharedPrefs();
    return prefs.remove(key);
  }
}
