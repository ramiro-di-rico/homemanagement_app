import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_management_app/data/repositories/identity_user_repository.dart';

class FeatureTogglesWidget extends StatefulWidget {
  const FeatureTogglesWidget({super.key});

  @override
  State<FeatureTogglesWidget> createState() => _FeatureTogglesWidgetState();
}

class _FeatureTogglesWidgetState extends State<FeatureTogglesWidget> {
  final IdentityUserRepository _identityUserRepository = GetIt.I<IdentityUserRepository>();
  bool useMainAccounts = false;

  @override
  void initState() {
    super.initState();
    useMainAccounts = _identityUserRepository.getUseMainAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Feature Toggles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Use Main Accounts',
                ),
                const Spacer(),
                Switch(
                  value: useMainAccounts,
                  onChanged: (value) {
                    setState(() {
                      useMainAccounts = value;
                    });
                    _identityUserRepository.setUseMainAccounts(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
