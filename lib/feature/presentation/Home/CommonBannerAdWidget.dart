import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sep/utils/appUtils.dart';

class CommonBannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const CommonBannerAdWidget({super.key, required this.adUnitId});

  @override
  State<CommonBannerAdWidget> createState() => _CommonBannerAdWidgetState();
}

class _CommonBannerAdWidgetState extends State<CommonBannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  bool _loadFailed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    AppUtils.log('🎯 ========== AD WIDGET INIT ==========');
    AppUtils.log('🎯 Ad Unit ID: ${widget.adUnitId}');
    AppUtils.log('🎯 Ad Unit ID Length: ${widget.adUnitId.length}');
    AppUtils.log(
      '🎯 Ad Unit ID contains newline: ${widget.adUnitId.contains('\n')}',
    );
    AppUtils.log('🎯 Ad Unit ID trimmed: ${widget.adUnitId.trim()}');
    AppUtils.log('🎯 Package Name: com.app.sep');
    AppUtils.log('🎯 Creating BannerAd...');

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId.trim(),
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppUtils.log('✅ ========== AD LOADED SUCCESSFULLY ==========');
          AppUtils.log('✅ Ad Unit ID: ${widget.adUnitId}');
          setState(() {
            _isAdLoaded = true;
            _loadFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          AppUtils.log('❌ ========== AD LOAD FAILED ==========');
          AppUtils.log('❌ Error Code: ${error.code}');
          AppUtils.log('❌ Error Domain: ${error.domain}');
          AppUtils.log('❌ Error Message: ${error.message}');
          AppUtils.log('❌ Response Info: ${error.responseInfo}');
          AppUtils.log('❌ Ad Unit ID used: ${widget.adUnitId}');
          AppUtils.log('');
          AppUtils.log('📋 Common Error Code 3 (No Fill) - No ads available');
          AppUtils.log('   This is normal and means AdMob has no ads to show');
          AppUtils.log(
            '   Error Code 403 would indicate a configuration issue',
          );
          AppUtils.log('');

          setState(() {
            _loadFailed = true;
            // Error code 3 = No fill (no ads available) - show friendly message
            if (error.code == 3) {
              _errorMessage = 'No Ads Available at the moment';
            } else {
              _errorMessage = 'Error ${error.code}: ${error.message}';
            }
          });
          ad.dispose();
        },
        onAdOpened: (ad) => AppUtils.log('📱 Ad opened'),
        onAdClosed: (ad) => AppUtils.log('📱 Ad closed'),
        onAdImpression: (ad) => AppUtils.log('👁️ Ad impression recorded'),
        onAdClicked: (ad) => AppUtils.log('👆 Ad clicked'),
      ),
    )..load();

    AppUtils.log('🎯 BannerAd.load() called');
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      // Show error message
      return Container(
        width: double.infinity,
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _errorMessage ?? 'Ad failed to load',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!_isAdLoaded) {
      // Show loading placeholder while ad is loading
      return Container(
        width: double.infinity,
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.shade500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Loading ad...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Show the actual Google Ad when loaded
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd),
    );
  }
}
