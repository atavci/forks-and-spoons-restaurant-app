import 'package:flutter/material.dart';
import 'package:forks_and_spoons/utils/styles.dart';

class ProductDialog extends StatelessWidget {
  final String imagePath;
  final String productName;
  final String productDesc;
  final int productPrice;
  final int discount;
  final bool isUrlImg;

  ProductDialog({
    this.imagePath,
    this.productName,
    this.productDesc,
    this.productPrice,
    this.discount = 0,
    this.isUrlImg = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 20,
                top: 120,
                right: 20,
                bottom: 20,
              ),
              margin: EdgeInsets.only(top: 80),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 10),
                        blurRadius: 10),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    productName,
                    style: AppTextStyles.title,
                  ),
                  SizedBox(height: 10),
                  Text(
                    productDesc,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  discount > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "\$" + productPrice.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  decoration: TextDecoration.lineThrough),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "\$" +
                                  (productPrice * ((100 - discount) / 100))
                                      .toInt()
                                      .toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            )
                          ],
                        )
                      : Text(
                          "\$" + productPrice.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 100,
                child: Hero(
                  tag: productName,
                  child: isUrlImg
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
          ],
        ));
  }
}
