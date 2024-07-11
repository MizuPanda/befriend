import 'dart:io';

import 'package:befriend/utilities/secrets.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../utilities/constants.dart';

class CustomNativeAd extends StatefulWidget {
  const CustomNativeAd({
    super.key,
  });

  @override
  State<CustomNativeAd> createState() => _CustomNativeAdState();
}

class _CustomNativeAdState extends State<CustomNativeAd> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  // TODO: replace this test ad unit with your own ad unit.
  final String _adUnitId = Platform.isAndroid
      ? Secrets.postTileUnitAndroid
      : Secrets.postTileUnitIOS;
  /*Platform.isAndroid
      ? Constants.postAndroidTestAdUnit
      : Constants.postiOSTestAdUnit;*/

  /// Loads a native ad.
  void loadAd() async {
    _nativeAd = NativeAd(
        adUnitId: _adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('(CustomNativeAd) $NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('(CustomNativeAd) $NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          // Required: Choose a template.
          templateType: TemplateType.medium,
          // Optional: Customize the ad's style.
          //mainBackgroundColor: Colors.purple,
        ))
      ..load();
  }

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return SizedBox(
        height: 0.346 * height,
        child: _nativeAdIsLoaded ? AdWidget(ad: _nativeAd!) : null);
  }
}
