import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sep/utils/appUtils.dart';

class CommonBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final VoidCallback? onAdDismissed;

  const CommonBannerAdWidget({
    super.key,
    required this.adUnitId,
    this.onAdDismissed,
  });

  @override
  State<CommonBannerAdWidget> createState() => _CommonBannerAdWidgetState();
}

class _CommonBannerAdWidgetState extends State<CommonBannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isAdLoaded = true);
          // Auto-dismiss ad after 10 seconds
          Future.delayed(Duration(seconds: 10), () {
            if (mounted) {
              setState(() => _isVisible = false);
              widget.onAdDismissed?.call();
            }
          });
        },
        onAdFailedToLoad: (ad, error) {
          AppUtils.log('Failed to load a banner ad: $error');
          ad.dispose();
          // Dismiss on error
          if (mounted) {
            setState(() => _isVisible = false);
            widget.onAdDismissed?.call();
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return SizedBox.shrink();
    }

    // Always show a test ad regardless of Google Ads loading status
    return Container(
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.campaign, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 TEST ADVERTISEMENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sponsored Content • Click to Learn More',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                      ),
                    ),
                    if (_isAdLoaded)
                      Text(
                        '✅ Google Ad Loaded',
                        style: TextStyle(
                          color: Colors.green.shade200,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Google Ad overlay (if loaded)
          if (_isAdLoaded)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
          // Close button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() => _isVisible = false);
                widget.onAdDismissed?.call();
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
