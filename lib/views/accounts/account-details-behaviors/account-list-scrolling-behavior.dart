import 'package:flutter/material.dart';

import 'transaction-fetching-behavior.dart';

mixin AccountListScrollingBehavior<T extends StatefulWidget> on State<T> implements TransactionFetchingBehavior {

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(onScroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    super.dispose();
  }

  void onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      nextPage();
    }
  }
}