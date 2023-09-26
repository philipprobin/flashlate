import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import 'google_account_button.dart';

class TopBarWithoutToggleWidget extends StatelessWidget {
  const TopBarWithoutToggleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                child: SvgPicture.asset(
                  'assets/image.svg',
                  height: 56,
                ),
              ),
            ),
            GoogleAccountButton(),
          ],
        ),
      ),
    );
  }
}
