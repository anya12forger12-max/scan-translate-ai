import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Adaptive banner ad shown at the bottom of the home screen.
///
/// Uses Google's official *test* ad unit until real AdMob IDs are configured.
/// Production: replace [adUnitId] and the app id in AndroidManifest.xml with
/// values from a real AdMob account.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  // Android test banner unit (see https://developers.google.com/admob/android/test-ads).
  static const String adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    await MobileAds.instance.initialize();

    final adapter = BannerAd(
      adUnitId: AdBanner.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _banner = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() => _loaded = false);
          }
        },
        onAdImpression: (_) {},
        onAdClicked: (_) {},
      ),
    );

    await adapter.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      child: Container(
        alignment: Alignment.topCenter,
        child: AdWidget(ad: _banner!),
      ),
    );
  }
}
