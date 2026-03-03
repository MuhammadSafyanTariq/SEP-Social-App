import 'appImages.dart';

/// Helper to map backend gift codes to local asset images.
class GiftImages {
  static String forCode(String code) {
    switch (code) {
      case 'Applause_Hands':
        return AppImages.giftApplauseHands;
      case 'Ascending_Smiling_Face_Heart_Eyes':
        return AppImages.giftAscendingSmilingFaceHeartEyes;
      case 'Beating_Heart':
        return AppImages.giftBeatingHeart;
      case 'Blooming_Flowers':
        return AppImages.giftBloomingFlowers;
      case 'Popping_Champagne':
        return AppImages.giftPoppingChampagne;
      case 'Birthday_Cake':
        return AppImages.giftBirthdayCake;
      case 'Boeing_747_8_VIP_Jet':
        return AppImages.giftVipJet;
      case 'Falling_Gold_Coins':
        return AppImages.giftFallingGoldCoins;
      case 'Floating_Cash':
        return AppImages.giftFloatingCash;
      case 'Soaring_Eagle':
        return AppImages.giftSoaringEagle;
      case 'Verde_Mantis_Lamborghini':
        return AppImages.giftVerdeMantisLamborghini;
      default:
        // Fallback to generic gift image if we don't have a specific asset yet.
        return AppImages.giftImg;
    }
  }
}

