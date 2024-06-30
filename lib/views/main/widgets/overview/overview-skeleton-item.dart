import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OverviewSkeletonItem extends StatelessWidget {
  const OverviewSkeletonItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(),
          ),
        ),
        SizedBox(width: 40),
        SizedBox(
          width: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(),
          ),
        ),
      ],
    ));
  }
}
