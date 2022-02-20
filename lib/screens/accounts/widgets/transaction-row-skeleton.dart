import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class TransactionRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: SkeletonItem(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120,
                        child: SkeletonLine(),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                        child: Container(
                          width: 50,
                          child: SkeletonLine(),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        child: SkeletonLine(),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 80,
                        child: SkeletonLine(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
