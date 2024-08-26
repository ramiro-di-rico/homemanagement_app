import 'package:flutter/material.dart';

class TransactionsSearchDesktopView extends StatefulWidget {
  static const String id = 'transactions_search_desktop_view';

  TransactionsSearchDesktopView();

  @override
  State<TransactionsSearchDesktopView> createState() => _TransactionsSearchDesktopViewState();
}

class _TransactionsSearchDesktopViewState extends State<TransactionsSearchDesktopView> {
  bool filtering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search transactions'),
        actions: [
          IconButton(
              onPressed: () {
                displayFilteringOptions();
              },
              icon: Icon(filtering ? Icons.filter_alt : Icons.filter_alt_outlined),
              tooltip: 'Filter transactions',
          ),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue,
                child: Text('Transactions'),
              ),
            ),
          ],
        )
      ),
    );
  }

  void displayFilteringOptions(){
    showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(
          maxHeight: 1000,
          maxWidth: 1000,
        ),
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(25.0))),
        builder: (context) {
          return SizedBox(
            height: 100,
            child: AnimatedPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search transaction by name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    // create a category dropdown component that somehow output the selected item
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          filtering = !filtering;
                          Navigator.pop(context);
                        });
                      },
                      child: Text('Filter'),
                    ),
                  ],
                )
            ),
          );
        }
    );
  }
}
