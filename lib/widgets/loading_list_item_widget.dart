
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';

const double decksPadding = 16.0;
class LoadingListItemWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          // create border radius
          borderRadius: BorderRadius.circular(20.0),
          child: LoadingSkeleton(
            // set width full screen
            // avoid render flex error
            width: MediaQuery.of(context).size.width - 2 * decksPadding,
            height: 56,
            animationDuration: 300,
            colors: [
              Color(0xFFf8f4f4),
              Color(0xFFf8f4f4),
              Colors.grey,
            ],
          ),
        ),
      ],
    );
  }
}
