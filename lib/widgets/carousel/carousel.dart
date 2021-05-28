import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:forks_and_spoons/widgets/carousel/carousel_item.dart';
import 'package:forks_and_spoons/utils/data.dart';

import 'inner_page/carousel_inner_page.dart';

class CustomCarousel extends StatefulWidget {
  @override
  _CustomCarouselState createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return CarouselItem(
            title: Text(
              carouselItems.keys.elementAt(index),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            content: carouselItems.values.elementAt(index),
            onPressedButton: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarouselInnerPage(
                            name: carouselItems.keys.elementAt(index),
                          )));
            },
          );
        },
        indicatorLayout: PageIndicatorLayout.SCALE,
        autoplay: true,
        duration: 750,
        autoplayDelay: 7500,
        outer: false,
        itemCount: carouselItems.length,
        control: SwiperControl(color: Colors.grey, size: 20),
        pagination: SwiperPagination(
            margin: EdgeInsets.all(0.0),
            builder: SwiperCustomPagination(
                builder: (BuildContext context, SwiperPluginConfig config) {
              return ConstrainedBox(
                child: Row(
                  children: <Widget>[
                    // To test a widget error, uncomment code below.
                    // Expanded(child: null),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: DotSwiperPaginationBuilder(
                                color: Colors.grey,
                                activeColor: Colors.white,
                                size: 10.0,
                                activeSize: 20.0)
                            .build(context, config),
                      ),
                    )
                  ],
                ),
                constraints: BoxConstraints.expand(height: 50.0),
              );
            })),
      ),
    );
  }
}
