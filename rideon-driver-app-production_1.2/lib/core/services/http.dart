import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../presentation/cubits/logout_cubit.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../extensions/workspace.dart';
import '../utils/common_widget.dart';
import 'config.dart';
import 'data_store.dart';

bool connectionLost = false;
String latitudeGlobal = '';
String longitudeGlobal = '';
bool shouldLogout = false;

// ==================== بيانات وهمية للتجربة ====================
// اجعل هذه القيمة true لتفعيل الوضع الوهمي بالكامل
// أو false للعودة للاتصال الحقيقي بالسيرفر
const bool USE_FAKE_DATA = true;

// البيانات الوهمية الأساسية
Map<String, dynamic> _fakeDriverData() => {
      "token": "fake_token_123456789",
      "fireStoreId": "driver_001",
      "firestore_id": "driver_001",
      "phone": "+962790000000",
      "phone_country": "+962",
      "phoneCountry": "+962",
      "default_country": "JO",
      "defaultCountry": "JO",
      "first_name": "Test",
      "last_name": "Driver",
      "name": "Test Driver",
      "user_name": "Test Driver",
      "email": "test@test.com",
      "id": 1,
      "user_id": 1,
      "is_verified": 1,
      "is_online": 1,
      "is_available": 1,
      "wallet_balance": 100.0,
      "rating": 5.0,
      "total_rides": 10,
      "total_earnings": 500.0,
      "otpValue": "1234",
      "otp_value": "1234",
      "profile_picture": "",
      "image": "",
      "status": 1,
      "vehicle_id": 1,
    };

Map<String, dynamic> _fakeResponse(String path) {
  // ==================== استجابات وهمية حسب المسار ====================

  // تسجيل / دخول
  if (path.contains("register") ||
      path.contains("login") ||
      path.contains("otp")) {
    return {
      "status": 200,
      "success": true,
      "message": "Success",
      "data": _fakeDriverData(),
    };
  }

  // الملف الشخصي
  if (path.contains("profile") || path.contains("account")) {
    return {
      "status": 200,
      "success": true,
      "data": _fakeDriverData(),
    };
  }

  // المحفظة
  if (path.contains("wallet") || path.contains("payout")) {
    return {
      "status": 200,
      "success": true,
      "data": {
        "balance": 100.0,
        "wallet_balance": 100.0,
        "total_earnings": 500.0,
        "total_withdrawn": 400.0,
        "transactions": [],
      }
    };
  }

  // الرحلات
  if (path.contains("ride") || path.contains("trip") || path.contains("history")) {
    return {
      "status": 200,
      "success": true,
      "data": [],
      "rides": [],
      "trips": [],
    };
  }

  // الإشعارات
  if (path.contains("notification")) {
    return {
      "status": 200,
      "success": true,
      "data": [],
    };
  }

  // عام
  return {
    "status": 200,
    "success": true,
    "message": "Success",
    "data": _fakeDriverData(),
  };
}
// ==============================================================

Future<dynamic> httpPost(path, data, {required BuildContext context}) async {
  // ==================== الوضع الوهمي ====================
  if (USE_FAKE_DATA) {
    await Future.delayed(const Duration(milliseconds: 500));
    return _fakeResponse(path.toString());
  }
  // ======================================================

  try {
    String apiBaseUrl = Config.baseUrl;
    var url = apiBaseUrl + path;
    if (bearerToken.isEmpty) {
      bearerToken = await generateToken() ?? "";
    }
    var headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $bearerToken",
    };
    data['module_id'] = "2";
    data['user_type'] = "driver";
    data['latitude'] = latitudeGlobal;
    data['longitude'] = longitudeGlobal;
    data['token'] = token;

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
    var responseData =
        json.decode(const Utf8Codec().decode(response.bodyBytes));

    if (response.statusCode == 498) {
      final newToken = await generateToken();
      if (newToken != null) {
        bearerToken = newToken;
        headers["Authorization"] = "Bearer $newToken";
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        );
        responseData =
            json.decode(const Utf8Codec().decode(response.bodyBytes));
      } else {
        return {"error": "Token regeneration failed"};
      }
    }
    if (response.statusCode == 419) {
      showErrorToastMessage("Session expired. Please log in again.");
      Future.delayed(const Duration(seconds: 1), () {
        clearData(navigatorKey.currentContext!);
        goToWithClear(const LoginScreen());
      });
    }
    return responseData;
  } catch (err) {
    return {"error": "Something went wrong"};
  }
}

Future<dynamic> httpGet(String path, Map<String, dynamic> data,
    {required BuildContext context}) async {
  // ==================== الوضع الوهمي ====================
  if (USE_FAKE_DATA) {
    await Future.delayed(const Duration(milliseconds: 500));
    return _fakeResponse(path);
  }
  // ======================================================

  dynamic responsegetData;
  try {
    String apiBaseUrl = Config.baseUrl;
    var url = apiBaseUrl + path;
    if (bearerToken.isEmpty) {
      bearerToken = await generateToken() ?? "";
    }
    var headers = {
      'Content-Type': 'application/json',
      'x-auth-token': token,
      'Authorization': "Bearer $bearerToken",
    };
    data['module_id'] = "2";
    data['user_type'] = "driver";
    data['latitude'] = latitudeGlobal;
    data['longitude'] = longitudeGlobal;
    data['time_zone'] = "";

    String queryString = Uri(
        queryParameters:
            data.map((key, value) => MapEntry(key, value.toString()))).query;
    var fullUrl = "$url?$queryString";
    var response = await http
        .get(Uri.parse(fullUrl), headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      responsegetData =
          json.decode(const Utf8Codec().decode(response.bodyBytes));
    } else if (response.statusCode == 498) {
      final newToken = await generateToken();
      if (newToken != null) {
        bearerToken = newToken;
        headers['Authorization'] = "Bearer $bearerToken";
        response = await http.get(Uri.parse(fullUrl), headers: headers);
        responsegetData =
            json.decode(const Utf8Codec().decode(response.bodyBytes));
      } else {
        showErrorToastMessage("Token regeneration failed.");
        return {"error": "Token regeneration failed"};
      }
    } else {
      responsegetData =
          json.decode(const Utf8Codec().decode(response.bodyBytes));
      if (response.statusCode == 419) {
        showErrorToastMessage("Session expired. Please log in again.");
        Future.delayed(const Duration(seconds: 1), () {
          clearData(navigatorKey.currentContext!);
          goToWithClear(const LoginScreen());
        });
      }
    }
  } on TimeoutException {
    responsegetData = {'error': "Something went wrong. Please try again."};
  }
  return responsegetData;
}

Future<String?>? _tokenFuture;
Future<String?> generateToken() async {
  // ==================== الوضع الوهمي ====================
  if (USE_FAKE_DATA) {
    bearerToken = "fake_bearer_token_xyz";
    return "fake_bearer_token_xyz";
  }
  // ======================================================

  if (_tokenFuture != null) {
    return _tokenFuture;
  }
  final completer = Completer<String?>();
  _tokenFuture = completer.future;
  try {
    const String url = '${Config.baseUrlForBearer}${Config.generateToken}';
    const Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    Map<String, dynamic> body = {
      "secret": Config.secretKey,
      "user_token": token
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      final token = data['data']["token"].toString();
      bearerToken = token;
      box.put("bearerToken", token);
      completer.complete(token);
    } else if (response.statusCode == 419) {
      showErrorToastMessage("Session expired. Please log in again.");
      Future.delayed(const Duration(seconds: 1), () {
        clearData(navigatorKey.currentContext!);
        goToWithClear(const LoginScreen());
      });
    } else {
      completer.complete(null);
    }
  } catch (e) {
    completer.complete(null);
  } finally {
    _tokenFuture = null;
  }
  return await completer.future;
}
