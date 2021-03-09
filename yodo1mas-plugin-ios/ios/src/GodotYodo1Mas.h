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
    void showBanner();
    void hideBanner();
    void showInterstitial();
    void showRewardedVideo();

    GodotYodo1Mas();
    ~GodotYodo1Mas();
};

#endif