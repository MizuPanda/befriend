
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/nearby_provider.dart';

/// NearbyDevicesList is a widget that displays a list of nearby devices.
/// It uses the NearbyProvider to get the nearby devices.
/// It uses the ListView to display the nearby devices.
class NearbyDevicesList extends StatefulWidget {
  const NearbyDevicesList({super.key});

  @override
  State<NearbyDevicesList> createState() => _NearbyDevicesListState();
}

class _NearbyDevicesListState extends State<NearbyDevicesList> {
  final NearbyProvider _provider = NearbyProvider();

  @override
  void initState() {
    _provider.startScanning();
    super.initState();
  }

  @override
  void dispose() {
    _provider.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      builder: (BuildContext context, Widget? child) {
        return Consumer<NearbyProvider>(
          builder: (BuildContext context, NearbyProvider provider, Widget? child) {
            return ListView.builder(
              itemCount: provider.length(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ProfilePhoto(
                    user: provider.bubble(index),
                    radius: Constants.pictureDialogAvatarSize,
                  ),
                  title: Text(provider.username(index)),
                  subtitle: Text(
                      provider.isFriend(index) ? "Your Friend" : "Not Friend"),
                  onTap: () async {
                    await provider.onTap(index, context);
                  },
                );
              },
            );
          }
        );
      }
    );
  }
}
