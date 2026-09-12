// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import '../../domain/entities/document_image.dart';
import '../../domain/entities/login.dart';
import '../../presentation/cubits/realtime/manage_driver_cubit.dart';
import '../../presentation/cubits/register_vehicle/vehicle_register_cubit.dart';
import '../../presentation/screens/Auth/login_screen.dart';
import '../../presentation/screens/bottom_bar/home_main.dart';
import '../../presentation/screens/setup_account/setup_initial_screen.dart';
import '../services/data_store.dart';
import '../utils/common_widget.dart';

String token = "";

final List locale = [

  {'name': 'English', 'locale': "en"},
  {'name': 'Arabic', 'locale': 'ar'},

];

bool isOnDuty = false;
bool isOnDutyArrived = false;
bool isOnDutyStart = false;
bool isOnDutyCompleted = false;

LoginModel? loginModel;

enum ScreenMode { add, edit }

String myImage = "";
String myName = "";
String socialEmail = "";
bool isNumeric=false;
dynamic oneSignalPlayerId = "";
dynamic oneSignalToken = "";
dynamic oneSignalOptedIn = "";
String bearerToken = box.get("bearerToken")??"";

Locale appLocale = const Locale('en');
var latitudeGlobal = "";
var longitudeGlobal = "";
bool isFatechedData = false;
 
Location location = Location();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

getUserLocation(BuildContext context) async {

  try {
    await Future.delayed(const Duration(seconds: 1));

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();

      if (permissionGranted == PermissionStatus.denied) {
        showOpenAppSettingsDialog(
            context, "Please allow location access in settings to continue.");

        return;
      }
    }

    if (permissionGranted == PermissionStatus.deniedForever) {

      showOpenAppSettingsDialog(
          context, "Please allow location access in settings to continue.");

      return;
    }

    locationData = await location.getLocation();
    if (locationData.latitude != null && locationData.longitude != null) {
      latitudeGlobal = locationData.latitude.toString();
      longitudeGlobal = locationData.longitude.toString();
      context.read<GetCurrentLocationCubit>().updateCurrentLocation(
          currentLongitude: latitudeGlobal, currentLatitude: longitudeGlobal);

      goTo(const LoginScreen());
    }
  } on PlatformException {
    if (Platform.isIOS) {
      showOpenAppSettingsDialog(
          context, "Please allow location access in settings to continue.");
    }
  } catch (e) {
   //
  }
}


DocumentImageModel? documentImageModel;
double walletBalance = 0.0;

String driverId = "";
int? itemId;
String? documentApprovedStatus = "";
String currency = "";

Future<void> updateDriverLocation({
  Position? currentLocation,
}) async {
  final DatabaseReference database =
      FirebaseDatabase.instance.ref().child('drivers');

  try {

    if (driverId.toString().isNotEmpty && driverId.toString() != '') {
      await database.child(driverId.toString()).update({
        'location': {
          'latitude': currentLocation!.latitude,
          'longitude': currentLocation.longitude,
        },
      });
    }
  } catch (e) {
     //
  }
}

getUserDataLocallyToHandleTheState(BuildContext context ,{bool? isHomePage}) async {
  

  if (isFatechedData) return;
  isFatechedData = true;

  itemId = 0;
  documentApprovedStatus = "";
 
  if (box.get("UserData") != null) {
 
    String data = box.get("UserData");

    if (box.get("documentData") != null) {
     
      String docData = box.get("documentData");
 
      if (docData.isNotEmpty) {
        var json = jsonDecode(docData);
        documentImageModel = DocumentImageModel.fromJson(json);
      }
    }

    if (data.isNotEmpty) {
      try {
        var json = jsonDecode(data);
        loginModel = LoginModel.fromJson(json);

        if (loginModel?.data != null) {
          final userData = loginModel!.data!;
          token = userData.token ?? "";
          myName = loginModel!.data?.firstName??"";
          socialEmail = userData.email ?? "";
          driverId = userData.fireStoreId??"";
          box.put("driverId", driverId);

          context
              .read<UpdateDriverParameterCubit>()
              .updateDriverId(driverId: driverId.toString());
          final gender = userData.gender;
          if (gender?.isNotEmpty ?? false) {
            loginModel?.data?.gender = gender;
          }
         
          if (userData.profileImage != null &&
              userData.profileImage["url"] != null &&
              userData.profileImage["url"].toString().isNotEmpty) {
            myImage = userData.profileImage["url"].toString();
            debugPrint("my image $myImage");


          }

          if (userData.itemId != null) {
            itemId = userData.itemId!;

            context
                .read<UpdateAddEditVehicleIdCubit>()
                .updateItemId(vehicleAddEditTypeId: loginModel!.data!.itemId!);
          }

          if (userData.verificationDocumentStatus != null) {
            documentApprovedStatus = userData.verificationDocumentStatus;

          }
        }
        if(isHomePage==true){
          return;
        }

        if (box.get('gender') == true) {
          if (box.get('itemTypeId') == true) {
            if (documentApprovedStatus == "approved") {

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeMain(initialIndex: 0),
                ),
              );
            } else {

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SetupInitialScreen(stepIndex: 2)));
            }
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SetupInitialScreen(stepIndex: 1)));
            return;
          }
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const SetupInitialScreen(stepIndex: 0)));
          return;
        }
      } catch (e) {
   //
      }
    }
  }
}

extension FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
