import 'package:flutter/material.dart';
import 'package:forks_and_spoons/utils/styles.dart';
import 'package:forks_and_spoons/widgets/product/product_dialog.dart';
import 'package:huawei_analytics/huawei_analytics.dart';

class ProductCard extends StatefulWidget {
  final String imagePath;
  final String productName;
  final String category;
  final String productDesc;
  final int productPrice;
  final int discount;
  final Function onTapAddToCart;
  final HMSAnalytics hmsAnalytics;
  final bool isUrlImg;

  ProductCard({
    this.category,
    this.productName,
    this.imagePath,
    this.productDesc,
    this.productPrice,
    this.onTapAddToCart,
    this.hmsAnalytics,
    this.isUrlImg = false,
    this.discount = 0,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  /// Huawei Analytics
  ///
  /// Custom Event
  void exploreEvent() async {
    // Creating custom event
    String name = "kesfet";
    Map<String, dynamic> value = {
      "product": widget.productName,
    };

    // Sending an event
    widget.hmsAnalytics.onEvent(name, value);
  }

  /// Huawei Analytics
  ///
  /// Custom Event
  void exploreWithImageEvent() async {
    // Creating custom event
    String name = "kesfetWithImage";
    Map<String, dynamic> value = {
      "product": widget.productName,
    };

    // Sending an event
    widget.hmsAnalytics.onEvent(name, value);
  }

  _showcase() {
    exploreEvent();
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return new FadeTransition(
                  opacity: new CurvedAnimation(
                      parent: animation, curve: Curves.easeOut),
                  child: child);
            },
            pageBuilder: (BuildContext context, _, __) {
              return ProductDialog(
                productName: widget.productName,
                imagePath: widget.imagePath,
                isUrlImg: widget.isUrlImg,
                productDesc: widget.productDesc,
                productPrice: widget.productPrice,
                discount: widget.discount,
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                height: 210,
                color: Colors.white,
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(widget.category + " ",
                                  style: AppTextStyles.boldAndSpacedTitle),
                              Text(
                                widget.productName,
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () => _showcase(),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                child: Text(
                                  "Explore",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: widget.onTapAddToCart,
                                child: Text("Add"),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        /// Sending an event.
                        exploreWithImageEvent();
                        _showcase();
                      },
                      child: Container(
                        height: 200,
                        width: 250,
                        child: Hero(
                          tag: widget.productName,
                          child: widget.isUrlImg
                              ? Image.network(
                                  widget.imagePath,
                                  fit: BoxFit.contain,
                                )
                              : Image.asset(
                                  widget.imagePath,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
