
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'google_account_button.dart';

class AppBarListWidget extends StatelessWidget {
  const AppBarListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Container(
                  //decoration: BoxDecoration(color: Colors.yellow),
                  child: SvgPicture.asset(
                    'assets/image.svg',
                    height: kToolbarHeight-8, // -2*vertical padding
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(


                  child: AccountButton(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
