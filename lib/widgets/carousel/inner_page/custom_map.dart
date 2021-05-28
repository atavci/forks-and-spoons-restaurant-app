import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huawei_map/map.dart';
import '../../../utils/styles.dart';

/// A widget that customizes the [HuaweiMap].
class CustomMap extends StatefulWidget {
  final String name;
  final double lat;
  final double lng;

  CustomMap({this.name, this.lat, this.lng});

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  /// Map controller for Huawei Map.
  static HuaweiMapController mapController;

  /// Custom marker icon.
  BitmapDescriptor customMarkerIcon;

  @override
  void initState() {
    super.initState();

    /// Initializing the custom marker icon.
    setCustomMarker();
  }

  /// Defines controller for the map.
  void _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  /// A function for centering the map to a position.
  void centerMap() {
    /// Creating a [CameraUpdate] object to animate.
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(widget.lat, widget.lng), zoom: 17, tilt: 90),
    );

    /// Animating the camera.
    mapController.animateCamera(cameraUpdate);
  }

  /// Creating the custom marker icon from an asset image.
  void setCustomMarker() async {
    /// Obtaining [Uint8List] of an image.
    Uint8List data = (await rootBundle.load("assets/customMarkerIcon.png"))
        .buffer
        .asUint8List();

    setState(() {
      /// Creating a custom marker icon from obtained data.
      customMarkerIcon = BitmapDescriptor.fromBytes(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: (MediaQuery.of(context).size.height / 5) * 2,
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(2.75),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),

                  ///  Huawei Map widget.
                  child: HuaweiMap(
                    /// Defining controller.
                    onMapCreated: _onMapCreated,

                    /// Initial camera position for creating a map.
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.lat, widget.lng),
                      zoom: 18,
                      tilt: 90,
                    ),

                    /// Enables the 3D buildings.
                    buildingsEnabled: true,

                    /// Enables the specified gestures.
                    rotateGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    scrollGesturesEnabled: true,

                    /// Marker for specified location.
                    markers: {
                      Marker(
                          markerId: MarkerId(widget.name),
                          position: LatLng(widget.lat, widget.lng),
                          icon: customMarkerIcon)
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                /// Centering the map on tap.
                onTap: centerMap,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.name,
                      style: AppTextStyles.simpleBoldTitle,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.amber, width: 2.75),
                        left: BorderSide(color: Colors.amber, width: 2.75),
                        right: BorderSide(color: Colors.amber, width: 2.75),
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
