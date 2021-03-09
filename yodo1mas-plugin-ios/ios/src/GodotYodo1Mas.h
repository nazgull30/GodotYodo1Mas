#ifndef GodotYodo1Mas_h
#define GodotYodo1Mas_h

#include "reference.h"

class GodotYodo1Mas : public Reference {
    GDCLASS(GodotYodo1Mas, Reference);

    bool initialized;

protected:
    static void _bind_methods();

public:
	bool isInitialized();
    void init(const String &appId);


	bool isBannerAdLoaded();
    void showBannerAd();
	void showBannerAdWithAlign(const int align);
	void showBannerAdWithAlignAndOffset(const int align, float offsetX, float offsetY);
    void dismissBannerAd();
	

	bool isInterstitialAdLoaded();
    void showInterstitialAd();

	bool isRewardedAdLoaded();
    void showRewardedAd();

    GodotYodo1Mas();
    ~GodotYodo1Mas();
};

#endif