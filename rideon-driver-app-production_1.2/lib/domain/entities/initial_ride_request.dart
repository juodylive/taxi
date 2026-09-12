// class RideRequest {.  ///old
//   final String bookingId;
//   final String rideId;
//   final String userId;
//   final String selectedDriverId;
//   final String userName;
//   final String? userImageUrl;
//   final String userPhoneNumber;
//   final Location pickupLocation;
//   final Location dropoffLocation;
//   final String distance;
//   final String travelCharges;
//   final String routeStatus;
//   final int timestamp;

//   RideRequest({
//     this.userImageUrl,
//     required this.bookingId,
//     required this.rideId,
//     required this.userId,
//     required this.selectedDriverId,
//     required this.userName,
//     required this.userPhoneNumber,
//     required this.pickupLocation,
//     required this.dropoffLocation,
//     required this.distance,
//     required this.travelCharges,
//     required this.routeStatus,
//     required this.timestamp,
//   });

//   // Convert from JSON
//   factory RideRequest.fromJson(String rideId, Map<String, dynamic> json) {
//     return RideRequest(
//       rideId: rideId,
//       userImageUrl: json["userImageUrl"] ?? '',
//       bookingId: json["bookingId"] ?? '',
//       userId: json['userId'] ?? '',
//       selectedDriverId: json['selectedDriverId'] ?? '',
//       userName: json['userName'] ?? '',
//       userPhoneNumber: json['userPhoneNumber'] ?? '',
//       pickupLocation: Location.fromJson(json['pickupLocation'] ?? {}),
//       dropoffLocation: Location.fromJson(json['dropoffLocation'] ?? {}),
//       distance: json['distance']?.toString() ?? "",
//       travelCharges: json['travelCharges']?.toString() ?? "",
//       routeStatus: json['routeStatus'] ?? 'Pending',
//       timestamp: (json['timestamp'] ?? 0),
//     );
//   }

//   // Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       "userImageUrl": userImageUrl,
//       "bookingId": bookingId,
//       "userId": userId,
//       "selectedDriverId": selectedDriverId,
//       "userName": userName,
//       "userPhoneNumber": userPhoneNumber,
//       "pickupLocation": pickupLocation.toJson(),
//       "dropoffLocation": dropoffLocation.toJson(),
//       "distance": distance,
//       "travelCharges": travelCharges,
//       "routeStatus": routeStatus,
//       "timestamp": timestamp,
//     };
//   }
// }

// // Location Model
// class Location {
//   final double lat;
//   final double lng;
//   final String address;

//   Location({required this.lat, required this.lng, required this.address});

//   // Convert from JSON
//   factory Location.fromJson(Map<String, dynamic> json) {
//     return Location(
//       lat: (json['lat'] ?? 0).toDouble(),
//       lng: (json['lng'] ?? 0).toDouble(),
//       address: json['pickupAddress'] ?? json['dropoffAddress'] ?? '',
//     );
//   }

//   // Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       "lat": lat,
//       "lng": lng,
//       "pickupAddress": address,
//     };
//   }
// }

class InitialRideRequest {
  final String rideId;
  final String pickupLocation;
  final String dropoffLocation;
  final String userId;
  final Customer customer;
  final String travelCharges;
  final String status;
  final String travelDistance;
  final String travelTime;

  InitialRideRequest({
    required this.rideId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.userId,
    required this.customer,
    required this.travelCharges,
    required this.status,
    required this.travelDistance,
    required this.travelTime,
  });

  factory InitialRideRequest.fromJson(Map<String, dynamic> json) {
    return InitialRideRequest(
      rideId: json['rideId'] as String? ?? '',
      pickupLocation: json['pickupLocation'] as String? ?? '',
      dropoffLocation: json['dropoffLocation'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      customer:
          Customer.fromJson(json['customer'] as Map<String, dynamic>? ?? {}),
      travelCharges: json['travelCharges'] as String? ?? '',
      status: json['status'] as String? ?? '',
      travelDistance: json['travelDistance'] as String? ?? '',
      travelTime: json['travelTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'userId': userId,
      'customer': customer.toJson(),
      'travelCharges': travelCharges,
      'status': status,
      'travelDistance': travelDistance,
      'travelTime': travelTime,
    };
  }
}

class Customer {
  final String userName;
  final String userPhone;
  final String? userPhoto;
  final String userRating;

  Customer({
    required this.userName,
    required this.userPhone,
    this.userPhoto,
    required this.userRating,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      userPhoto: json['userPhoto'] as String?,
      userRating: json['userRating'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userPhone': userPhone,
      'userPhoto': userPhoto,
      'userRating': userRating,
    };
  }
}
