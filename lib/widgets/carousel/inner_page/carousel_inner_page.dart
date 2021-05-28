import 'package:flutter/material.dart';
import 'customInfoContainer.dart';
import 'custom_map.dart';
import 'package:forks_and_spoons/utils/data.dart';

class CarouselInnerPage extends StatefulWidget {
  final String name;

  CarouselInnerPage({this.name});

  @override
  _CarouselInnerPageState createState() => _CarouselInnerPageState();
}

class _CarouselInnerPageState extends State<CarouselInnerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
      body: Column(
        children: <Widget>[
          CustomMap(
            name: widget.name,
            lat: restaurantDetails[widget.name]["lat"],
            lng: restaurantDetails[widget.name]["lng"],
          ),
          CustomInfoContainer(
              title: "", desc: restaurantDetails[widget.name]["details"]),
          CustomInfoContainer(
              title: "Phone Number",
              desc: restaurantDetails[widget.name]["tel"]),
          CustomInfoContainer(
              title: "Address",
              desc: restaurantDetails[widget.name]["address"]),
        ],
      ),
    );
  }
}
