import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          title: Skeletonizer(
            enabled: true,
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
                        child: Container(),
                      ),
                      Container(
                        width: 50,
                        child: Container(),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Container(
                          width: 50,
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
