//
//  Yodo1Mas.h
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1MasAdEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^Yodo1MasInitSuccessful)(void);
typedef void (^Yodo1MasInitFail)(Yodo1MasError *);
typedef void (^Yodo1MasAdCallback) (Yodo1MasAdEvent *);

@protocol Yodo1MasAdDelegate <NSObject>

@optional
- (void)onAdOpened:(Yodo1MasAdEvent *)event;
- (void)onAdClosed:(Yodo1MasAdEvent *)event;
- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error;

@end

@protocol Yodo1MasRewardAdDelegate <NSObject, Yodo1MasAdDelegate>

@optional
- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event;

@end

@protocol Yodo1MasInterstitialAdDelegate <NSObject, Yodo1MasAdDelegate>

@end

@protocol Yodo1MasBannerAdDelegate <NSObject, Yodo1MasAdDelegate>

@end

@interface Yodo1Mas : NSObject

@property (nonatomic, assign) BOOL isGDPRUserConsent;
@property (nonatomic, assign) BOOL isCOPPAAgeRestricted;
@property (nonatomic, assign) BOOL isCCPADoNotSell;
@property (nonatomic, weak) id<Yodo1MasRewardAdDelegate> rewardAdDelegate;
@property (nonatomic, weak) id<Yodo1MasInterstitialAdDelegate> interstitialAdDelegate;
@property (nonatomic, weak) id<Yodo1MasBannerAdDelegate> bannerAdDelegate;

+ (Yodo1Mas *)sharedInstance;
+ (NSString *)sdkVersion;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail;

- (BOOL)isRewardAdLoaded;
- (void)showRewardAd;
- (void)showRewardAdWithPlacement:(NSString *)placement;
//- (void)dismissRewardAdvert;

- (BOOL)isInterstitialAdLoaded;
- (void)showInterstitialAd;
- (void)showInterstitialAdWithPlacement:(NSString *)placement;
//- (void)dismissInterstitialAd;

- (BOOL)isBannerAdLoaded;
- (void)showBannerAd;
- (void)showBannerAdWithPlacement:(NSString *)placement;
- (void)showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align;
- (void)showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align offset:(CGPoint)offset;
- (void)showBannerAdWithPlacement:(NSString *)placement align:(Yodo1MasAdBannerAlign)align offset:(CGPoint)offset;
- (void)dismissBannerAd;
- (void)dismissBannerAdWithDestroy:(BOOL)destroy;

@end

NS_ASSUME_NONNULL_END
