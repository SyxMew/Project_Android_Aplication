import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

InterstitialAd? _interstitialAd;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: 'ca-app-pub-3940256099942544/1033173712',
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        _interstitialAd = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        _interstitialAd = null;
      },
    ),
  );
}

Future<void> showInterstitialAd(VoidCallback onAdDismissed) async {
  if (_interstitialAd != null) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        onAdDismissed();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  } else {
    onAdDismissed();
  }
}
