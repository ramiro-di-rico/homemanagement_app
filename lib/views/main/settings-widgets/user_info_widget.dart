import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/models/view-models/my_user_view_model.dart';

import '../../../services/repositories/identity_user_repository.dart';

class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({super.key});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  IdentityUserRepository identityUserRepository = GetIt.I<IdentityUserRepository>();

  MyUserViewModel? _userInfo = null;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 140,
          child: Column(
            children: [
              ListTile(
                title: Text('Email'),
                subtitle: Text(_userInfo?.email ?? ""),
              ),
              ListTile(
                title: Text('Username'),
                subtitle: Text(_userInfo?.username ?? ""),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future load() async {
    var userInfo = await identityUserRepository.getUser();
    setState(() {
      _userInfo = userInfo;
    });
  }
}
