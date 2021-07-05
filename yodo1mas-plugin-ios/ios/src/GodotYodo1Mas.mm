#include "GodotYodo1Mas.h"
#import "app_delegate.h"
#import "Yodo1Mas.h"

static GodotYodo1Mas *godotYodo1MasInstance = NULL;


// BEGIN CALLBALS
@interface GodotYodo1MasBannerAd: NSObject<Yodo1MasBannerAdDelegate>

@end

@implementation GodotYodo1MasBannerAd

- (void)setBannerAdDelegate {
    [Yodo1Mas sharedInstance].bannerAdDelegate = self;
}

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasBannerAd onAdOpened");
    godotYodo1MasInstance->emit_signal("on_banner_ad_opened");
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasBannerAd onAdClosed");
    godotYodo1MasInstance->emit_signal("on_banner_ad_closed");
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
	if (error.code != Yodo1MasErrorCodeAdLoadFail) {
		NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasBannerAd onAdError, %d", (int)error.code);
	    godotYodo1MasInstance->emit_signal("on_banner_ad_error", (int)error.code);	
	}
}

@end


@interface GodotYodo1MasInterstitialAd: NSObject<Yodo1MasInterstitialAdDelegate>


@end


@implementation GodotYodo1MasInterstitialAd

- (void)setInterstitialAdDelegate {
    [Yodo1Mas sharedInstance].interstitialAdDelegate = self;
}

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasInterstitial onAdOpened");
    godotYodo1MasInstance->emit_signal("on_interstitial_ad_opened");
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasInterstitial onAdClosed");
    godotYodo1MasInstance->emit_signal("on_interstitial_ad_closed");
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
	if (error.code != Yodo1MasErrorCodeAdLoadFail) {
		NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasInterstitial onAdError, %d", (int)error.code);
	    godotYodo1MasInstance->emit_signal("on_interstitial_ad_error", (int)error.code);	
	}
}

@end


@interface GodotYodo1MasRewardedAd: NSObject<Yodo1MasRewardAdDelegate>

@end


@implementation GodotYodo1MasRewardedAd

- (void)setRewardAdDelegate {
    [Yodo1Mas sharedInstance].rewardAdDelegate = self;
}

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdOpened");
    godotYodo1MasInstance->emit_signal("on_rewarded_ad_opened");
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdClosed");
    godotYodo1MasInstance->emit_signal("on_rewarded_ad_closed");
}

- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdRewardEarned");
    godotYodo1MasInstance->emit_signal("on_rewarded_ad_earned");
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
	if (error.code != Yodo1MasErrorCodeAdLoadFail) {
		NSLog(@"GodotYodo1MasWrapper -> GodotYodo1MasRewardAd onAdError, %d", (int)error.code);
	    godotYodo1MasInstance->emit_signal("on_rewarded_ad_error", (int)error.code);
	}
}

@end

// END CALLBALS



// BEGIN INITIALIZATION

bool initialized;
	
GodotYodo1Mas::GodotYodo1Mas() {
	godotYodo1MasInstance = this;
}

GodotYodo1Mas::~GodotYodo1Mas() {
}

bool GodotYodo1Mas::isInitialized() {
	return initialized;
}

void GodotYodo1Mas::setGDPR(bool gdpr) {
	NSLog(@"GodotYodo1MasWrapper -> setGDPR, %d", gdpr);
	[Yodo1Mas sharedInstance].isGDPRUserConsent = gdpr;
}
void GodotYodo1Mas::setCCPA(bool ccpa) {
	NSLog(@"GodotYodo1MasWrapper -> setCCPA, %d", ccpa);
	[Yodo1Mas sharedInstance].isCCPADoNotSell = ccpa;
}	
void GodotYodo1Mas::setCOPPA(bool coppa) {
	NSLog(@"GodotYodo1MasWrapper -> setCOPPA, %d", coppa);
	[Yodo1Mas sharedInstance].isCOPPAAgeRestricted = coppa;
}

void GodotYodo1Mas::init(const String &appId) {
    NSLog(@"GodotYodo1MasWrapper init");

	setBannerCallback();
	setInterstitialAdCallback();	
	setRewardedAdCallback();
		
	NSString *appIdPr = [NSString stringWithCString:appId.utf8().get_data() encoding: NSUTF8StringEncoding];
	// [UnityAds initialize:appIdPr delegate:nil testMode:YES];
    [[Yodo1Mas sharedInstance] initWithAppKey:appIdPr successful:^{
		initialized = true;
		NSLog(@"GodotYodo1MasWrapper -> initialize successful");
    } fail:^(NSError * _Nonnull error) {
		NSLog(@"GodotYodo1MasWrapper -> initialize error: %@", error);
    }];
}

void GodotYodo1Mas::setBannerCallback() {
    static GodotYodo1MasBannerAd *bannerAd;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bannerAd = [[GodotYodo1MasBannerAd alloc] init];
    });
    [bannerAd setBannerAdDelegate];
}

void GodotYodo1Mas::setInterstitialAdCallback() {
    static GodotYodo1MasInterstitialAd *interstitialAd;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interstitialAd = [[GodotYodo1MasInterstitialAd alloc] init];
    });
    [interstitialAd setInterstitialAdDelegate];
}

void GodotYodo1Mas::setRewardedAdCallback() {
    static GodotYodo1MasRewardedAd *rewardedAd;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rewardedAd = [[GodotYodo1MasRewardedAd alloc] init];
    });
    [rewardedAd setRewardAdDelegate];
}


// END INITIALIZATION



// BEGIN BANNER AD

bool GodotYodo1Mas::isBannerAdLoaded() {
	return [[Yodo1Mas sharedInstance] isBannerAdLoaded];
}

void GodotYodo1Mas::showBannerAd() {
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper not initialized");
        return;
    }
	
	bool isBannerAdLoaded = [[Yodo1Mas sharedInstance] isBannerAdLoaded];
	NSLog(@"GodotYodo1MasWrapper isBannerAdLoaded %d", isBannerAdLoaded);
	if(!isBannerAdLoaded) {
		godotYodo1MasInstance->emit_signal("on_banner_ad_not_loaded");
		return;
	}
    
	[[Yodo1Mas sharedInstance] showBannerAd];
}

void GodotYodo1Mas::showBannerAdWithAlign(int align) {
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper not initialized");
        return;
    }
	
	bool isBannerAdLoaded = [[Yodo1Mas sharedInstance] isBannerAdLoaded];
	NSLog(@"GodotYodo1MasWrapper isBannerAdLoaded %d", isBannerAdLoaded);
	if(!isBannerAdLoaded) {
		godotYodo1MasInstance->emit_signal("on_banner_ad_not_loaded");
		return;
	}
    
	[[Yodo1Mas sharedInstance] showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align];
}

void GodotYodo1Mas::showBannerAdWithAlignAndOffset(int align, int offsetX, int offsetY){
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper not initialized");
        return;
    }
	
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper not initialized");
        return;
    }
	
	bool isBannerAdLoaded = [[Yodo1Mas sharedInstance] isBannerAdLoaded];
	NSLog(@"GodotYodo1MasWrapper isBannerAdLoaded %d", isBannerAdLoaded);
	if(!isBannerAdLoaded) {
		godotYodo1MasInstance->emit_signal("on_banner_ad_not_loaded");
		return;
	}
    
	CGPoint offset = CGPointMake(offsetX, offsetY);
	[[Yodo1Mas sharedInstance] showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align offset:offset];
}

void GodotYodo1Mas::dismissBannerAd() {
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper not initialized");
        return;
    }
	
	[[Yodo1Mas sharedInstance] dismissBannerAd];
}

// END BANNER AD



// BEGIN INTERSTITIAL AD

bool GodotYodo1Mas::isInterstitialAdLoaded() {
	return [[Yodo1Mas sharedInstance] isInterstitialAdLoaded];
}

void GodotYodo1Mas::showInterstitialAd() {
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper not initialized");
        return;
    }
	
	bool isInterstitialAdLoaded = [[Yodo1Mas sharedInstance] isInterstitialAdLoaded];
	NSLog(@"GodotYodo1MasWrapper isInterstitialAdLoaded %d", isInterstitialAdLoaded);
	if(!isInterstitialAdLoaded) {
		godotYodo1MasInstance->emit_signal("on_interstitial_ad_not_loaded");
		return;
	}

    NSLog(@"GodotYodo1MasWrapper showInterstitialAd");    
	[[Yodo1Mas sharedInstance] showInterstitialAd];
}

// END INTERSTITIAL AD




// BEGIN REWARDED AD

bool GodotYodo1Mas::isRewardedAdLoaded() {
	return [[Yodo1Mas sharedInstance] isRewardAdLoaded];
}

void GodotYodo1Mas::showRewardedAd() {
    if (!initialized) {
        NSLog(@"GodotYodo1MasWrapper Module not initialized");
        return;
    }
	
	bool isRewardedAdLoaded = [[Yodo1Mas sharedInstance] isRewardAdLoaded];
	NSLog(@"GodotYodo1MasWrapper isRewardedAdLoaded %d", isRewardedAdLoaded);
	if(!isRewardedAdLoaded) {
		godotYodo1MasInstance->emit_signal("on_rewarded_ad_not_loaded");
		return;
	}
    
	NSLog(@"GodotYodo1MasWrapper showRewardedVideo");    
	[[Yodo1Mas sharedInstance] showRewardAd];
}

// END REWARDED AD

void GodotYodo1Mas::_bind_methods() {
    ClassDB::bind_method("init", &GodotYodo1Mas::init);

    ClassDB::bind_method("setGDPR", &GodotYodo1Mas::setGDPR);
	ClassDB::bind_method("setCCPA", &GodotYodo1Mas::setCCPA);
	ClassDB::bind_method("setCOPPA", &GodotYodo1Mas::setCOPPA);

    ClassDB::bind_method("showBannerAd", &GodotYodo1Mas::showBannerAd);
	ClassDB::bind_method("showBannerAdWithAlign", &GodotYodo1Mas::showBannerAdWithAlign);
	ClassDB::bind_method("showBannerAdWithAlignAndOffset", &GodotYodo1Mas::showBannerAdWithAlignAndOffset);
    ClassDB::bind_method("dismissBannerAd" ,&GodotYodo1Mas::dismissBannerAd);

    ClassDB::bind_method("isInterstitialAdLoaded", &GodotYodo1Mas::isInterstitialAdLoaded);
    ClassDB::bind_method("showInterstitialAd", &GodotYodo1Mas::showInterstitialAd);

	ClassDB::bind_method("isRewardedAdLoaded", &GodotYodo1Mas::isRewardedAdLoaded);
    ClassDB::bind_method("showRewardedAd", &GodotYodo1Mas::showRewardedAd);

	ADD_SIGNAL(MethodInfo("on_banner_ad_not_loaded"));
    ADD_SIGNAL(MethodInfo("on_banner_ad_opened"));
    ADD_SIGNAL(MethodInfo("on_banner_ad_closed"));
	ADD_SIGNAL(MethodInfo("on_banner_ad_error"));
	
	ADD_SIGNAL(MethodInfo("on_interstitial_ad_not_loaded"));
    ADD_SIGNAL(MethodInfo("on_interstitial_ad_opened"));
    ADD_SIGNAL(MethodInfo("on_interstitial_ad_closed"));
	ADD_SIGNAL(MethodInfo("on_interstitial_ad_error"));
	
	ADD_SIGNAL(MethodInfo("on_rewarded_ad_not_loaded"));
    ADD_SIGNAL(MethodInfo("on_rewarded_ad_opened"));
    ADD_SIGNAL(MethodInfo("on_rewarded_ad_closed"));
	ADD_SIGNAL(MethodInfo("on_rewarded_ad_earned"));
	ADD_SIGNAL(MethodInfo("on_rewarded_ad_error"));

}
