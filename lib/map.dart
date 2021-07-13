import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.doc('locationRef/1').snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              /// Get the GeoPoint from the firestore
              GeoPoint geoPoint = snapshot.data?.get('location');
              double lat = geoPoint.latitude;
              double lng = geoPoint.longitude;

              /// Updating the Camera Position
              updateCameraPosition(lat, lng);
              return GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition:
                    CameraPosition(target: LatLng(lat, lng), zoom: 10),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: _createMarker(lat, lng),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  /// Updating the Camera Position
  Future<void> updateCameraPosition(double lat, double lng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 10)));
  }

  /// Creating the Marker
  Set<Marker> _createMarker(double lat, double long) {
    return <Marker>[
      Marker(
        markerId: MarkerId('Home'),
        position: LatLng(lat, long),
        icon: BitmapDescriptor.defaultMarker,
      )
    ].toSet();
  }
}
