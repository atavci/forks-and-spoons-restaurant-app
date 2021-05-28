import 'package:flutter/material.dart';

class CarouselItem extends StatefulWidget {
  final Widget title;
  final String content;
  final Function onPressedButton;

  const CarouselItem({
    Key key,
    @required this.title,
    @required this.content,
    @required this.onPressedButton,
  }) : super(key: key);

  @override
  _CarouselItemState createState() => _CarouselItemState();
}

class _CarouselItemState extends State<CarouselItem> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(widget.content),
            fit: BoxFit.cover,
          )),
        ),
        Align(
            alignment: Alignment.topCenter,
            child: Padding(padding: EdgeInsets.all(10.0), child: widget.title)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 34.0),
                  child: ElevatedButton(
                    onPressed: widget.onPressedButton,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: Text(
                      "Explore",
                      style: TextStyle(color: Colors.black),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
