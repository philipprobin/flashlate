import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(

              color: Colors.lightBlue,
              shape: BoxShape.circle,

            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/practice');
              },
              icon: SvgPicture.asset(
                'assets/playing_cards.svg',
                color: Colors.white,
                width: 100,
                height: 100,
              ),
            ),
          ),
          const Text(
            'Flashlate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: Color(0xffe73700),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/list');
              },
              icon: const Icon(
                Icons.view_list,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
