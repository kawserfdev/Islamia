// import 'dart:convert';
// import 'package:islamia/data/models/user/user_model.dart';
// import 'package:islamia/data/models/user/user_profile.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LocalStorageService {
//   static final LocalStorageService _instance = LocalStorageService._internal();
//   factory LocalStorageService() => _instance;
//   LocalStorageService._internal();

//   SharedPreferences? _prefs;

//   static const String _userKey = 'user_data';
//   static const String _userPreferencesKey = 'user_preferences';
//   static const String _userProfileKey = 'user_profile';
//   static const String _authTokenKey = 'auth_token';
//   static const String _isLoggedInKey = 'is_logged_in';
//   static const String _lastSyncTimeKey = 'last_sync_time';
//   static const String _appSettingsKey = 'app_settings';

//   Future<SharedPreferences> get prefs async {
//     _prefs ??= await SharedPreferences.getInstance();
//     return _prefs!;
//   }

//   // User Data Methods
//   Future<void> saveUser(UserModel user) async {
//     try {
//       final preferences = await prefs;
//       final userJson = jsonEncode(user.toJson());
//       await preferences.setString(_userKey, userJson);
//       await preferences.setBool(_isLoggedInKey, true);
//     } catch (e) {
//       throw Exception('Failed to save user data: $e');
//     }
//   }

//   Future<UserModel?> getUser() async {
//     try {
//       final preferences = await prefs;
//       final userJson = preferences.getString(_userKey);
      
//       if (userJson == null) return null;
      
//       final userMap = jsonDecode(userJson) as Map<String, dynamic>;
//       return UserModel.fromJson(userMap);
//     } catch (e) {
//       print('Failed to get user data: $e');
//       return null;
//     }
//   }

//   Future<void> updateUser(UserModel user) async {
//     await saveUser(user);
//   }

//   Future<void> deleteUser() async {
//     try {
//       final preferences = await prefs;
//       await preferences.remove(_userKey);
//       await preferences.remove(_userPreferencesKey);
//       await preferences.remove(_userProfileKey);
//       await preferences.setBool(_isLoggedInKey, false);
//     } catch (e) {
//       throw Exception('Failed to delete user data: $e');
//     }
//   }

//   // User Preferences Methods
//   Future<void> saveUserPreferences(UserPreferences preferences) async {
//     try {
//       final prefs = await this.prefs;
//       final preferencesJson = jsonEncode(preferences.toJson());
//       await prefs.setString(_userPreferencesKey, preferencesJson);
//     } catch (e) {
//       throw Exception('Failed to save user preferences: $e');
//     }
//   }

//   Future<UserPreferences?> getUserPreferences() async {
//     try {
//       final prefs = await this.prefs;
//       final preferencesJson = prefs.getString(_userPreferencesKey);
      
//       if (preferencesJson == null) return null;
      
//       final preferencesMap = jsonDecode(preferencesJson) as Map<String, dynamic>;
//       return UserPreferences.fromJson(preferencesMap);
//     } catch (e) {
//       print('Failed to get user preferences: $e');
//       return null;
//     }
//   }

//   // User Profile Methods
//   Future<void> saveUserProfile(UserProfile profile) async {
//     try {
//       final prefs = await this.prefs;
//       final profileJson = jsonEncode(profile.toJson());
//       await prefs.setString(_userProfileKey, profileJson);
//     } catch (e) {
//       throw Exception('Failed to save user profile: $e');
//     }
//   }

//   Future<UserProfile?> getUserProfile() async {
//     try {
//       final prefs = await this.prefs;
//       final profileJson = prefs.getString(_userProfileKey);
      
//       if (profileJson == null) return null;
      
//       final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
//       return UserProfile.fromJson(profileMap);
//     } catch (e) {
//       print('Failed to get user profile: $e');
//       return null;
//     }
//   }

//   // Authentication Methods
//   Future<void> saveAuthToken(String token) async {
//     try {
//       final prefs = await this.prefs;
//       await prefs.setString(_authTokenKey, token);
//     } catch (e) {
//       throw Exception('Failed to save auth token: $e');
//     }
//   }

//   Future<String?> getAuthToken() async {
//     try {
//       final prefs = await this.prefs;
//       return prefs.getString(_authTokenKey);
//     } catch (e) {
//       print('Failed to get auth token: $e');
//       return null;
//     }
//   }

//   Future<void> deleteAuthToken() async {
//     try {
//       final prefs = await this.prefs;
//       await prefs.remove(_authTokenKey);
//     } catch (e) {
//       throw Exception('Failed to delete auth token: $e');
//     }
//   }

//   Future<bool> isLoggedIn() async {
//     try {
//       final prefs = await this.prefs;
//       return prefs.getBool(_isLoggedInKey) ?? false;
//     } catch (e) {
//       print('Failed to check login status: $e');
//       return false;
//     }
//   }

//   // Sync Methods
//   Future<void> saveLastSyncTime(DateTime syncTime) async {
//     try {
//       final prefs = await this.prefs;
//       await prefs.setString(_lastSyncTimeKey, syncTime.toIso8601String());
//     } catch (e) {
//       throw Exception('Failed to save last sync time: $e');
//     }
//   }

//   Future<DateTime?> getLastSyncTime() async {
//     try {
//       final prefs = await this.prefs;
//       final syncTimeString = prefs.getString(_lastSyncTimeKey);
      
//       if (syncTimeString == null) return null;
      
//       return DateTime.parse(syncTimeString);
//     } catch (e) {
//       print('Failed to get last sync time: $e');
//       return null;
//     }
//   }

//   // App Settings Methods
//   Future<void> saveAppSettings(Map<String, dynamic> settings) async {
//     try {
//       final prefs = await this.prefs;
//       final settingsJson = jsonEncode(settings);
//       await prefs.setString(_appSettingsKey, settingsJson);
//     } catch (e) {
//       throw Exception('Failed to save app settings: $e');
//     }
//   }

//   Future<Map<String, dynamic>?> getAppSettings() async {
//     try {
//       final prefs = await this.prefs;
//       final settingsJson = prefs.getString(_appSettingsKey);
      
//       if (settingsJson == null) return null;
      
//       return jsonDecode(settingsJson) as Map<String, dynamic>;
//     } catch (e) {
//       print('Failed to get app settings: $e');
//       return null;
//     }
//   }

//   // Utility Methods
//   Future<void> clearAll() async {
//     try {
//       final prefs = await this.prefs;
//       await prefs.clear();
//     } catch (e) {
//       throw Exception('Failed to clear all data: $e');
//     }
//   }

//   Future<void> saveBool(String key, bool value) async {
//     final prefs = await this.prefs;
//     await prefs.setBool(key, value);
//   }

//   Future<bool?> getBool(String key) async {
//     final prefs = await this.prefs;
//     return prefs.getBool(key);
//   }

//   Future<void> saveString(String key, String value) async {
//     final prefs = await this.prefs;
//     await prefs.setString(key, value);
//   }

//   Future<String?> getString(String key) async {
//     final prefs = await this.prefs;
//     return prefs.getString(key);
//   }

//   Future<void> saveInt(String key, int value) async {
//     final prefs = await this.prefs;
//     await prefs.setInt(key, value);
//   }

//   Future<int?> getInt(String key) async {
//     final prefs = await this.prefs;
//     return prefs.getInt(key);
//   }

//   Future<void> saveDouble(String key, double value) async {
//     final prefs = await this.prefs;
//     await prefs.setDouble(key, value);
//   }

//   Future<double?> getDouble(String key) async {
//     final prefs = await this.prefs;
//     return prefs.getDouble(key);
//   }

//   Future<void> saveStringList(String key, List<String> value) async {
//     final prefs = await this.prefs;
//     await prefs.setStringList(key, value);
//   }

//   Future<List<String>?> getStringList(String key) async {
//     final prefs = await this.prefs;
//     return prefs.getStringList(key);
//   }

//   Future<void> remove(String key) async {
//     final prefs = await this.prefs;
//     await prefs.remove(key);
//   }

//   Future<bool> containsKey(String key) async {
//     final prefs = await this.prefs;
//     return prefs.containsKey(key);
//   }
// }

















import 'dart:convert';
import 'package:islamia/data/models/user/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/database_exceptions.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  static const String _userKey = 'user_data';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _userProfileKey = 'user_profile';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _appSettingsKey = 'app_settings';

  Future<SharedPreferences> get prefs async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!;
    } catch (e) {
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  // User Data Methods with error handling
  Future<void> saveUser(UserModel user) async {
    try {
      final preferences = await prefs;
      final userJson = jsonEncode(user.toJson());
      final success = await preferences.setString(_userKey, userJson);
      if (!success) {
        throw const DatabaseException('Failed to save user data to SharedPreferences');
      }
      await preferences.setBool(_isLoggedInKey, true);
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final preferences = await prefs;
      final userJson = preferences.getString(_userKey);
      
      if (userJson == null) return null;
      
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      // Return null for parsing errors, but log them
      print('Failed to get user data: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  Future<void> deleteUser() async {
    try {
      final preferences = await prefs;
      await Future.wait([
        preferences.remove(_userKey),
        preferences.remove(_userPreferencesKey),
        preferences.remove(_userProfileKey),
        preferences.setBool(_isLoggedInKey, false),
      ]);
    } catch (e) {
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  // Auth Methods with error handling
  Future<void> saveAuthToken(String token) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setString(_authTokenKey, token);
      if (!success) {
        throw const DatabaseException('Failed to save auth token');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final preferences = await prefs;
      return preferences.getString(_authTokenKey);
    } catch (e) {
      print('Failed to get auth token: $e');
      return null;
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      final preferences = await prefs;
      await preferences.remove(_authTokenKey);
    } catch (e) {
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final preferences = await prefs;
      return preferences.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Failed to check login status: $e');
      return false;
    }
  }

  // Sync Methods with error handling
  Future<void> saveLastSyncTime(DateTime syncTime) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setString(_lastSyncTimeKey, syncTime.toIso8601String());
      if (!success) {
        throw const DatabaseException('Failed to save last sync time');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final preferences = await prefs;
      final syncTimeString = preferences.getString(_lastSyncTimeKey);
      
      if (syncTimeString == null) return null;
      
      return DateTime.parse(syncTimeString);
    } catch (e) {
      print('Failed to get last sync time: $e');
      return null;
    }
  }

  // App Settings Methods with error handling
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final preferences = await prefs;
      final settingsJson = jsonEncode(settings);
      final success = await preferences.setString(_appSettingsKey, settingsJson);
      if (!success) {
        throw const DatabaseException('Failed to save app settings');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final preferences = await prefs;
      final settingsJson = preferences.getString(_appSettingsKey);
      
      if (settingsJson == null) return null;
      
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      print('Failed to get app settings: $e');
      return null;
    }
  }

  // Utility Methods with error handling
  Future<void> clearAll() async {
    try {
      final preferences = await prefs;
      final success = await preferences.clear();
      if (!success) {
        throw const DatabaseException('Failed to clear all data');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setBool(key, value);
      if (!success) {
        throw DatabaseException('Failed to save boolean value for key: $key');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getBool(key);
    } catch (e) {
      print('Failed to get boolean value for key $key: $e');
      return null;
    }
  }

  Future<void> saveString(String key, String value) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setString(key, value);
      if (!success) {
        throw DatabaseException('Failed to save string value for key: $key');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<String?> getString(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getString(key);
    } catch (e) {
      print('Failed to get string value for key $key: $e');
      return null;
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setInt(key, value);
      if (!success) {
        throw DatabaseException('Failed to save integer value for key: $key');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getInt(key);
    } catch (e) {
      print('Failed to get integer value for key $key: $e');
      return null;
    }
  }

  Future<void> saveDouble(String key, double value) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setDouble(key, value);
      if (!success) {
        throw DatabaseException('Failed to save double value for key: $key');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getDouble(key);
    } catch (e) {
      print('Failed to get double value for key $key: $e');
      return null;
    }
  }

  Future<void> saveStringList(String key, List<String> value) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setStringList(key, value);
      if (!success) {
        throw DatabaseException('Failed to save string list for key: $key');
      }
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<List<String>?> getStringList(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getStringList(key);
    } catch (e) {
      print('Failed to get string list for key $key: $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      final preferences = await prefs;
      await preferences.remove(key);
    } catch (e) {
      throw DatabaseException.fromSharedPreferences(e);
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      final preferences = await prefs;
      return preferences.containsKey(key);
    } catch (e) {
      print('Failed to check if key exists $key: $e');
      return false;
    }
  }
}