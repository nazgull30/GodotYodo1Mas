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

	void setGDPR(bool gdpr);
	void setCCPA(bool ccpa);	
	void setCOPPA(bool coppa);
	
	bool isBannerAdLoaded();
    void showBannerAd();
	void showBannerAdWithAlign(const int align);
	void showBannerAdWithAlignAndOffset(const int align, const int offsetX, const int offsetY);
    void dismissBannerAd();
	

	bool isInterstitialAdLoaded();
    void showInterstitialAd();

	bool isRewardedAdLoaded();
    void showRewardedAd();

    GodotYodo1Mas();
    ~GodotYodo1Mas();
};

#endif