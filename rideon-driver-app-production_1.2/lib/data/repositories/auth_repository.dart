import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/extensions/workspace.dart';
import '../../core/services/config.dart';
import '../../core/services/http.dart';
import '../../presentation/cubits/auth/user_authenticate_cubit.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(
      {required String phoneNumber,
      required String phoneCountry,
      required BuildContext context}) async {
    if (!phoneCountry.startsWith("+")) {
      phoneCountry = '+$phoneCountry';
    }
    try {
      final data = {
        "phone": phoneNumber,
        "phone_country": phoneCountry,
      };
      var response =
          await httpPost(Config.sendMobileLoginOtp, data, context: context);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forChangeEmail({
    otp,
    email,
  }) async {
    try {
      var response = await httpPost(
          Config.changeEmail, {"email": email, "otp_value": otp},
          context: navigatorKey.currentContext!);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> userAuthenticateLogin(
      {required BuildContext context,
      required String phoneNumber,
      required String phoneCountry,
      required String otpValue}) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "token": "fake_token_123456789",
        "fireStoreId": "driver_001",
        "phone": phoneNumber,
        "phone_country": phoneCountry,
        "phoneCountry": phoneCountry,
        "defaultCountry": "JO",
        "default_country": "JO",
        "first_name": "Test Driver",
        "name": "Test Driver",
        "email": "test@test.com",
        "id": 1,
        "is_verified": 1,
        "wallet_balance": 100.0,
        "rating": 5.0,
        "otpValue": "1234",
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> signUp(
      {required BuildContext context,
      String? name,
      String? phoneNumber,
      String? email,
      String? phoneCountry,
      String? defaultCountry}) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "token": "fake_token_123456789",
        "fireStoreId": "driver_001",
        "phone": phoneNumber ?? "+962790000000",
        "phone_country": phoneCountry ?? "+962",
        "phoneCountry": phoneCountry ?? "+962",
        "defaultCountry": defaultCountry ?? "JO",
        "default_country": defaultCountry ?? "JO",
        "otpValue": "1234",
        "first_name": name ?? "Test Driver",
        "name": name ?? "Test Driver",
        "email": email ?? "test@test.com",
        "id": 1,
        "is_verified": 1,
        "wallet_balance": 100.0,
        "rating": 5.0,
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> resendOtp({
    required BuildContext context,
    String? phone,
    String? phoneCountry,
  }) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "phone": phone,
        "phone_country": phoneCountry,
        "otpValue": "1234",
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> changePhone({String? phone}) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "phone": phone,
        "otpValue": "1234",
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> changeEmail({String? email}) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "email": email,
        "otpValue": "1234",
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> otpVerify(
      {String? phone,
      required BuildContext context,
      String? otpValue,
      String? countryCode,
      String? email,
      String? resetToken,
      bool? changeEmail,
      bool? changeMobile,
      String? defaultCountry}) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "token": "fake_token_123456789",
        "fireStoreId": "driver_001",
        "phone": phone,
        "phone_country": countryCode,
        "phoneCountry": countryCode,
        "defaultCountry": defaultCountry ?? "JO",
        "default_country": defaultCountry ?? "JO",
        "first_name": "Test Driver",
        "name": "Test Driver",
        "email": email ?? "test@test.com",
        "id": 1,
        "is_verified": 1,
        "wallet_balance": 100.0,
        "rating": 5.0,
        "otpValue": otpValue,
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> resendEmailOtpForChange(
      Map<String, dynamic> data) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "otpValue": "1234",
      }
    };
    // ==============================================================
  }

  Future<Map<String, dynamic>> forChangePhoneNumberOtpVerification(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    // ==================== بيانات وهمية للتجربة ====================
    await Future.delayed(const Duration(seconds: 1));

    return {
      "status": 200,
      "data": {
        "otpValue": "1234",
      }
    };
    // ==============================================================
  }
}
