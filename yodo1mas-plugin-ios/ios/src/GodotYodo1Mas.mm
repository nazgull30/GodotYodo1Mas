#include "GodotYodo1Mas.h"
#import "app_delegate.h"
#import "Yodo1Mas.h"

static GodotYodo1Mas *godotYodo1MasInstance = NULL;


@interface GodotYodo1MasInterstitial: NSObject<Yodo1MasInterstitialAdDelegate>

- (void)onAdOpened:(Yodo1MasAdEvent *)event;
- (void)onAdClosed:(Yodo1MasAdEvent *)event;
- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error;

@end


@implementation GodotYodo1MasInterstitial

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1Mas -> GodotYodo1MasInterstitial onAdOpened");
    godotYodo1MasInstance->emit_signal("on_interstitial_opened");
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1Mas -> GodotYodo1MasInterstitial onAdClosed");
    godotYodo1MasInstance->emit_signal("on_interstitial_closed");
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
	if (error.code != Yodo1MasErrorCodeAdLoadFail) {
		NSLog(@"GodotYodo1Mas -> GodotYodo1MasInterstitial onAdError, %d", (int)error.code);
	    godotYodo1MasInstance->emit_signal("on_interstitial_error", (int)error.code);	
	}
}

@end


@interface GodotYodo1MasRewardAd: NSObject<Yodo1MasRewardAdDelegate>

- (void)onAdOpened:(Yodo1MasAdEvent *)event;
- (void)onAdClosed:(Yodo1MasAdEvent *)event;
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event;
- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error;
@end


@implementation GodotYodo1MasRewardAd

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1Mas -> GodotYodo1MasRewardAd onAdOpened");
    godotYodo1MasInstance->emit_signal("on_reward_video_opened");
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1Mas -> GodotYodo1MasRewardAd onAdClosed");
    godotYodo1MasInstance->emit_signal("on_reward_video_closed");
}

- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
	NSLog(@"GodotYodo1Mas -> GodotYodo1MasRewardAd onAdRewardEarned");
    godotYodo1MasInstance->emit_signal("on_reward_video_earned");
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
	if (error.code != Yodo1MasErrorCodeAdLoadFail) {
		NSLog(@"GodotYodo1Mas -> GodotYodo1MasRewardAd onAdError, %d", (int)error.code);
	    godotYodo1MasInstance->emit_signal("reward_video_error", (int)error.code);
	}
}

@end




GodotYodo1Mas::GodotYodo1Mas() {
	godotYodo1MasInstance = this;
}

GodotYodo1Mas::~GodotYodo1Mas() {
}

bool GodotYodo1Mas::isInitialized() {
	return initialized;
}


void GodotYodo1Mas::init(const String &appId) {
    NSLog(@"GodotYodo1Mas Module init");
	
	[Yodo1Mas sharedInstance].interstitialAdDelegate = [[GodotYodo1MasInterstitial alloc] init];
	[Yodo1Mas sharedInstance].rewardAdDelegate = [[GodotYodo1MasRewardAd alloc] init];
	
	NSString *appIdPr = [NSString stringWithCString:appId.utf8().get_data() encoding: NSUTF8StringEncoding];
	// [UnityAds initialize:appIdPr delegate:nil testMode:YES];
    [[Yodo1Mas sharedInstance] initWithAppId:appIdPr successful:^{
		initialized = true;
		NSLog(@"GodotYodo1Mas -> initialize successful");
    } fail:^(NSError * _Nonnull error) {
		NSLog(@"GodotYodo1Mas -> initialize error: %@", error);
    }];
}

void GodotYodo1Mas::showBanner() {
    if (!initialized) {
        NSLog(@"GodotYodo1Mas Module not initialized");
        return;
    }
    
	[[Yodo1Mas sharedInstance] showBannerAd];
}

void GodotYodo1Mas::hideBanner() {
    if (!initialized) {
        NSLog(@"GodotYodo1Mas Module not initialized");
        return;
    }
	
	[[Yodo1Mas sharedInstance] dismissBannerAd];
}

void GodotYodo1Mas::showInterstitial() {
    if (!initialized) {
        NSLog(@"GodotYodo1Mas Module not initialized");
        return;
    }
	
	bool isInterstitialAdLoaded = [[Yodo1Mas sharedInstance] isInterstitialAdLoaded];
	NSLog(@"GodotYodo1Mas isInterstitialAdLoaded %d", isInterstitialAdLoaded);
	if(!isInterstitialAdLoaded) {
		godotYodo1MasInstance->emit_signal("on_interstitial_not_loaded");
		return;
	}

    NSLog(@"GodotYodo1Mas showInterstitial");    
	[[Yodo1Mas sharedInstance] showInterstitialAd];
}


void GodotYodo1Mas::showRewardedVideo() {
    if (!initialized) {
        NSLog(@"GodotAdmob Module not initialized");
        return;
    }
	
	bool isRewardedVideoLoaded = [[Yodo1Mas sharedInstance] isRewardAdLoaded];
	NSLog(@"GodotYodo1Mas isRewardedVideoLoaded %d", isRewardedVideoLoaded);
	if(!isRewardedVideoLoaded) {
		godotYodo1MasInstance->emit_signal("on_reward_video_not_loaded");
		return;
	}
    
	NSLog(@"GodotYodo1Mas showRewardedVideo");    
	[[Yodo1Mas sharedInstance] showRewardAd];
}


void GodotYodo1Mas::_bind_methods() {
    ClassDB::bind_method("init",&GodotYodo1Mas::init);
    ClassDB::bind_method("showBanner",&GodotYodo1Mas::showBanner);
    ClassDB::bind_method("hideBanner",&GodotYodo1Mas::hideBanner);
    ClassDB::bind_method("showInterstitial",&GodotYodo1Mas::showInterstitial);
    ClassDB::bind_method("showRewardedVideo",&GodotYodo1Mas::showRewardedVideo);
	
	ADD_SIGNAL(MethodInfo("on_interstitial_not_loaded"));
    ADD_SIGNAL(MethodInfo("on_interstitial_opened"));
    ADD_SIGNAL(MethodInfo("on_interstitial_closed"));
	ADD_SIGNAL(MethodInfo("on_interstitial_error"));
	
	ADD_SIGNAL(MethodInfo("on_reward_video_not_loaded"));
    ADD_SIGNAL(MethodInfo("on_reward_video_opened"));
    ADD_SIGNAL(MethodInfo("on_reward_video_closed"));
	ADD_SIGNAL(MethodInfo("on_reward_video_earned"));
	ADD_SIGNAL(MethodInfo("on_reward_video_error"));

}
