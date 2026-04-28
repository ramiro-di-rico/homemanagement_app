import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../custom/components/app-textfield.dart';
import '../../../models/main_account.dart';
import '../../../services/repositories/main_account.repository.dart';

class MainAccountSheet extends StatefulWidget {
  final MainAccountModel? mainAccountModel;

  MainAccountSheet({Key? key, this.mainAccountModel}) : super(key: key);

  @override
  State<MainAccountSheet> createState() => _MainAccountSheetState();
}

class _MainAccountSheetState extends State<MainAccountSheet> {
  MainAccountRepository mainAccountRepository = GetIt.instance<MainAccountRepository>();
  TextEditingController _textEditingController = TextEditingController();
  late MainAccountModel mainAccount;
  bool isEditMode = false;
  bool enableButton = false;

  @override
  void initState() {
    super.initState();
    mainAccount = widget.mainAccountModel ?? MainAccountModel(0, "", 0, 0, false);
    isEditMode = widget.mainAccountModel != null;
    _textEditingController.text = mainAccount.name;
    _textEditingController.addListener(onNameChanged);
  }

  @override
  void dispose() {
    this._textEditingController.removeListener(onNameChanged);
    this._textEditingController.dispose();
    super.dispose();
  }

  void onNameChanged() {
    setState(() {
      this.mainAccount.name = this._textEditingController.text;
      this.enableButton = this.mainAccount.name.length > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Main Account Name',
            editingController: _textEditingController,
          ),
          SizedBox(height: 20),
          AnimatedOpacity(
            opacity: mainAccount.name.length > 3 ? 1.0 : 0,
            duration: const Duration(milliseconds: 500),
            child: ElevatedButton(
              onPressed: save,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(40),
              ),
              child: Icon(
                Icons.check,
                color: Colors.greenAccent,
              ),
            ),
          )
        ],
      ),
    );
  }

  void save() {
    if (isEditMode) {
      this.mainAccountRepository.update(mainAccount);
    } else {
      this.mainAccountRepository.add(mainAccount);
    }
    Navigator.pop(context);
  }
}
