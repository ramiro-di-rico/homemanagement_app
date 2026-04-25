import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../services/repositories/preferences.repository.dart';

class FeatureTogglesWidget extends StatefulWidget {
  const FeatureTogglesWidget({super.key});

  @override
  State<FeatureTogglesWidget> createState() => _FeatureTogglesWidgetState();
}

class _FeatureTogglesWidgetState extends State<FeatureTogglesWidget> {
  final PreferencesRepository _preferencesRepository = GetIt.I<PreferencesRepository>();
  bool useMainAccounts = false;

  @override
  void initState() {
    super.initState();
    useMainAccounts = _preferencesRepository.getUseMainAccounts();
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
                    _preferencesRepository.setUseMainAccounts(value);
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
