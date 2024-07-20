import 'package:befriend/models/services/referral_service.dart';
import 'package:befriend/views/widgets/home/buttons/round_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ReferralButton extends StatelessWidget {
  const ReferralButton({super.key});

  @override
  Widget build(BuildContext context) {
    return RoundButton(
        onPressed: () async {
          final Uri uri = ReferralService.generateReferralLink();
          await Share.shareUri(uri);
        },
        data: Icons.person_add_alt_rounded);
  }
}
