import 'dart:developer';
import 'dart:typed_data';

import 'package:agconnect_crash/agconnect_crash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forks_and_spoons/main.dart';
import 'package:forks_and_spoons/utils/data.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_map/map.dart';

class OrderPage extends StatefulWidget {
  final List<String> userChoices;

  OrderPage({this.userChoices});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool isLocationObtained = false;
  LatLng userLocation;
  FusedLocationProviderClient locationService;
  Set<Marker> _markers = Set();
  Marker userMarker;
  Map<String, double> closest = {};
  bool isServable = false;

  /// Map controller for Huawei Map.
  static HuaweiMapController mapController;

  /// Defines controller for the map.
  void _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  /// Mock location coordinates.
  double lat = 41.0567829;
  double lng = 28.9994479;

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  void initializeServices() async {
    checkLocationPermission();
    locationService = FusedLocationProviderClient();
    if (await setMockLocationForTest()) {
      initMarkers();
      checkingLocationDialog();
    }
  }

  void checkLocationPermission() async {
    PermissionHandler permissionHandler = PermissionHandler();
    if (!await permissionHandler.hasLocationPermission() ||
        !await permissionHandler.requestLocationPermission()) {
      Navigator.pop(context);
      showErrorDialog(
          "Permission error, please allow the location permissions.");
    }
  }

  /// Centers map to user location.
  void centerMyLocation() async {
    // Creating a [CameraUpdate] object to animate.
    CameraUpdate cameraUpdate = CameraUpdate.newLatLng(LatLng(lat, lng));

    // Animating the camera.
    mapController.animateCamera(cameraUpdate);

    if (userMarker != null) {
      Future.delayed(Duration(milliseconds: 500)).then((_) {
        // Starts marker animation.
        mapController.startAnimationOnMarker(userMarker);
      });
    }
  }

  /// Sets mock location and a marker for testing.
  Future<bool> setMockLocationForTest() async {
    try {
      // Enables the mock mode.
      await locationService.setMockMode(true);

      // Sets mock location.
      await locationService.setMockLocation(
        Location(latitude: lat, longitude: lng),
      );

      // Custom marker icon.
      BitmapDescriptor userIcon;

      // Obtaining [Uint8List] of an image.
      Uint8List data =
          (await rootBundle.load("assets/userIcon.png")).buffer.asUint8List();

      // Creating a custom marker icon from obtained data.
      userIcon = BitmapDescriptor.fromBytes(data);

      // Creating an animation for marker.
      HmsMarkerAlphaAnimation userAnimation = HmsMarkerAlphaAnimation(
        animationId: "userAnimation",
        fromAlpha: 0,
        toAlpha: 1,
        interpolator: HmsMarkerAnimation.LINEAR,
      );

      // Defining the marker for user location.
      userMarker = Marker(
          markerId: MarkerId("user"),
          position: LatLng(lat, lng),
          icon: userIcon,
          infoWindow: InfoWindow(title: "Me"),
          animationSet: [userAnimation]);

      setState(() {
        // Adds the user marker to marker list of Huawei Map.
        _markers.add(userMarker);
      });
      return true;
    } on PlatformException catch (e, stacktrace) {
      AGCCrash.instance.recordError(e, stacktrace);
      log("Set mock location failed!, Error is:${e.message}");
      showErrorDialog(
          "Error while setting the mock location, please set mock location app from developer options.");
      return false;
    }
  }

  /// Obtains user location.
  ///
  /// In this case, it is a mock location.
  Future<bool> getCurrentLocation() async {
    // Obtains user location from Flutter Location Plugin.
    try {
      Location currentLocation = await locationService.getLastLocation();
      setState(() {
        userLocation =
            LatLng(currentLocation.latitude, currentLocation.longitude);
        isLocationObtained = true;
      });
    } on PlatformException catch (e, stacktrace) {
      AGCCrash.instance.recordError(e, stacktrace);
      log("Sign In Failed!, Error is:${e.message}");
      setState(() {
        isLocationObtained = false;
      });
    }
    return isLocationObtained;
  }

  void initMarkers() async {
    // Custom marker icon.
    BitmapDescriptor customMarkerIcon;

    // Obtaining [Uint8List] of an image.
    Uint8List data = (await rootBundle.load("assets/customMarkerIcon.png"))
        .buffer
        .asUint8List();

    // Creating a custom marker icon from obtained data.
    customMarkerIcon = BitmapDescriptor.fromBytes(data);

    // Creating restaurant markers.
    restaurantDetails.forEach((name, details) {
      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(details["lat"], details["lng"]),
          icon: customMarkerIcon,

          // Creating Info Windows.
          infoWindow: InfoWindow(
              title: name,
              onClick: () {
                log(name);
              }),
        ),
      );
    });
  }

  void checkingLocationDialog() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => WillPopScope(
                onWillPop: getCurrentLocation,
                child: AlertDialog(
                    title: Text(
                      "Please Wait",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Please wait while Forks & Spoons finding your location.",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        CircularProgressIndicator(
                          backgroundColor: Colors.amber,
                        ),
                      ],
                    )),
              ));

      if (await getCurrentLocation()) {
        Future.delayed(Duration(seconds: 1)).then((_) {
          Navigator.pop(context);
          findClosest();
        });
      } else {
        log('faileddd');
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => WillPopScope(
                  onWillPop: getCurrentLocation,
                  child: AlertDialog(
                      title: Text(
                        "Try again",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Obtain the location again.",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CircularProgressIndicator(
                            backgroundColor: Colors.amber,
                          ),
                        ],
                      )),
                ));
      }
    });
  }

  /// Calculates the closest restaurant.
  void findClosest() async {
    Map<String, double> distances = {};

    for (int i = 0; i < restaurantDetails.length; i++) {
      // Obtains the distance between two coordinates.
      await HuaweiMapUtils.distanceCalculator(
        start: userLocation,
        end: LatLng(restaurantDetails.entries.elementAt(i).value["lat"],
            restaurantDetails.entries.elementAt(i).value["lng"]),
      ).then((distance) {
        distances[restaurantDetails.entries.elementAt(i).key] = distance;
      });
    }

    distances.forEach((name, distance) {
      if (closest.isEmpty || closest.values.first > distance) {
        setState(() {
          closest = {name: distance};
        });
      }
    });

    if (closest.values.first.toInt() < 10000) {
      setState(() {
        isServable = true;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    "assets/logo.png",
                    color: Colors.red,
                    height: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    child:
                        Text('Return', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                        primary: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        backgroundColor: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Container(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "assets/logo.png",
                  color: Colors.black,
                ),
                Text(
                  "Forks &\nSpoons",
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 35,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.my_location),
              onPressed: centerMyLocation,
            )
          ],
        ),
        body: isLocationObtained
            ? Stack(
                children: <Widget>[
                  HuaweiMap(
                    /// Defining controller.
                    onMapCreated: _onMapCreated,
                    initialCameraPosition:
                        CameraPosition(target: userLocation, zoom: 12),
                    markers: _markers,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            color: Colors.white,
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: isServable
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text("Our restaurant in "),
                                            Text(
                                              closest.keys.first,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text("will serve you."),
                                          ],
                                        ),
                                        SizedBox(width: 10.0),
                                        Icon(Icons.arrow_forward_ios),
                                      ],
                                    )
                                  : Text(
                                      "We can not provide service to your location yet..",
                                      textAlign: TextAlign.center,
                                    )),
                        ),
                        onTap: isServable
                            ? () {
                                MyHomePage.userChoices = [];
                                Navigator.of(context).pop();
                                showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Image.asset(
                                                "assets/logo.png",
                                                color: Colors.black,
                                                height: 50,
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                "Your order is preparing.\nThank you for choosing us.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        )));
                              }
                            : null,
                      ),
                    ),
                  )
                ],
              )
            : SizedBox.shrink());
  }
}
