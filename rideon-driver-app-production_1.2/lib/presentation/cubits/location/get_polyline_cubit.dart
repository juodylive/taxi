import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

const String osrmBaseUrl = 'http://158.101.231.22:5000';

abstract class GetPolylineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPolylineInitial extends GetPolylineState {}

class ResetPolylineInitial extends GetPolylineState {}

class GetPolylineLoading extends GetPolylineState {
  final Map<String, List<LatLng>> polylines;
  GetPolylineLoading(this.polylines);

  @override
  List<Object?> get props => [polylines];
}

class GetPolylineUpdated extends GetPolylineState {
  final Map<String, List<LatLng>>? polylines;
  GetPolylineUpdated({this.polylines});

  @override
  List<Object?> get props => [polylines];
}

class GetPolylineUpdatedError extends GetPolylineState {
  final String error;
  GetPolylineUpdatedError(this.error);

  @override
  List<Object?> get props => [error];
}

class GetPolylineCubit extends Cubit<GetPolylineState> {
  GetPolylineCubit() : super(GetPolylineInitial());

  final Map<String, List<LatLng>> _polylines = {};

  Future<void> getPolyline({
    required double sourcelat,
    required double sourcelng,
    required double destinationlat,
    required double destinationlng,
    required bool isPickupRoute, // true for pickup, false for dropoff
  }) async {
    try {
      if (sourcelat <= 0 ||
          sourcelng <= 0 ||
          destinationlat <= 0 ||
          destinationlng <= 0) {
        emit(GetPolylineUpdatedError("Invalid coordinates"));
        return;
      }

      emit(GetPolylineLoading(Map.from(_polylines)));

      final url = Uri.parse(
          '$osrmBaseUrl/route/v1/driving/$sourcelng,$sourcelat;$destinationlng,$destinationlat?overview=full&geometries=geojson');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'Ok') {
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        final polylineCoordinates = coordinates
            .map<LatLng>((point) => LatLng(point[1] as double, point[0] as double))
            .toList();

        final String polylineId =
            isPickupRoute ? "DriverPickupToUser" : "DriverDropoffToUser";
        final String oppositePolylineId =
            isPickupRoute ? "DriverDropoffToUser" : "DriverPickupToUser";

        _polylines.remove(oppositePolylineId);
        _polylines[polylineId] = polylineCoordinates;

        emit(GetPolylineUpdated(polylines: Map.from(_polylines)));
      } else {
        emit(GetPolylineUpdatedError(
            data['message']?.toString() ?? "Failed to get polyline"));
      }
    } catch (e) {
      emit(GetPolylineUpdatedError("Exception: $e"));
    }
  }

  Map<String, List<LatLng>> get currentPolylines => Map.from(_polylines);

  void resetPolylines() {
    _polylines.clear();
    emit(GetPolylineInitial());
  }
}

// Driver States
abstract class UpdateRideMarkerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RideMarkerInitial extends UpdateRideMarkerState {}

class RideMarkerLoading extends UpdateRideMarkerState {
  final Set<AppMarkerSimple> markers;
  RideMarkerLoading(this.markers);

  @override
  List<Object?> get props => [markers];
}

class RideMarkerUpdated extends UpdateRideMarkerState {
  final Set<AppMarkerSimple> markers;
  RideMarkerUpdated(this.markers);

  @override
  List<Object?> get props => [markers];
}

class RideMarkerError extends UpdateRideMarkerState {
  final String error;
  RideMarkerError(this.error);

  @override
  List<Object?> get props => [error];
}

class AppMarkerSimple {
  final String markerId;
  final LatLng position;
  final String title;
  final Uint8List? icon;

  AppMarkerSimple({
    required this.markerId,
    required this.position,
    required this.title,
    this.icon,
  });
}

// Driver Map Cubit
class UpdateRideMarkerCubit extends Cubit<UpdateRideMarkerState> {
  UpdateRideMarkerCubit() : super(RideMarkerInitial());

  Future<void> getRideMarker({
    required BuildContext context,
    required double sourcelat,
    required double sourcelng,
    required double destinationlat,
    required double destinationlng,
    required String pickupImage,
    required String dropOffImage,
  }) async {
    emit(RideMarkerLoading(const <AppMarkerSimple>{}));

    try {
      final Uint8List markerIconDropOff =
          await getBytesFromAsset(dropOffImage, 40);
      final Uint8List markerIconPickup =
          await getBytesFromAsset(pickupImage, 40);

      Set<AppMarkerSimple> markers = {};

      markers.add(AppMarkerSimple(
        markerId: 'pickup',
        position: LatLng(sourcelat, sourcelng),
        title: 'Pickup Location',
        icon: markerIconPickup,
      ));

      markers.add(AppMarkerSimple(
        markerId: 'dropoff',
        position: LatLng(destinationlat, destinationlng),
        title: 'Dropoff Location',
        icon: markerIconDropOff,
      ));

      emit(RideMarkerUpdated(markers));
    } catch (e) {
      emit(RideMarkerError(e.toString()));
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void resetState() {
    emit(RideMarkerInitial());
  }
}
