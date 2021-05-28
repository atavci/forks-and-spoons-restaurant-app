import 'package:flutter/material.dart';
import '../../../utils/styles.dart';

class CustomInfoContainer extends StatelessWidget {
  final String title;
  final String desc;

  CustomInfoContainer({this.desc, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(left: BorderSide(color: Colors.amber, width: 8))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                title == ""
                    ? SizedBox.shrink()
                    : Column(
                        children: <Widget>[
                          Text(
                            title,
                            style: AppTextStyles.simpleBoldTitle,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                Text(desc)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
