//
//  Yodo1Mas.m
//  FBSDKCoreKit
//
//  Created by ZhouYuzhen on 2020/12/3.
//

#import "Yodo1Mas.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>
#import "Yodo1MasInitData.h"
#import "Yodo1MasAdapterBase.h"
#if defined(__IPHONE_14_0)
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#endif
#import <AdSupport/AdSupport.h>
#import "Yodo1SaManager.h"
#import "Yodo1AdsManager.h"
#import <UIKit/UIKit.h>

#define Yodo1MasGDPRUserConsent     @"Yodo1MasGDPRUserConsent"
#define Yodo1MasCOPPAAgeRestricted  @"Yodo1MasCOPPAAgeRestricted"
#define Yodo1MasCCPADoNotSell       @"Yodo1MasCCPADoNotSell"
#define kYodo1MasSdkVersion         @"Yodo1MasSdkVersion"
#define kYodo1MasSdkType            @"Yodo1MasSdkType"
#define kYodo1MasAppKey             @"Yodo1MasAppKey"
#define kYodo1MasAppVersion         @"Yodo1MasAppVersion"
#define kYodo1MasAppBundleId        @"Yodo1MasAppBundleId"
#define kYodo1MasIDFA               @"Yodo1MasIDFA"
#define kYodo1MasAdMobId            @"Yodo1MasAdMobId"
#define kYodo1MasTestMode           @"Yodo1MasTestMode"
#define kYodo1MasTestDevice         @"Yodo1MasTestDevice"
#define kYodo1MasInitStatus         @"Yodo1MasInitStatus"
#define kYodo1MasInitMsg            @"Yodo1MasInitMsg"
#define kYodo1MasInitTime           @"Yodo1MasInitTime"
#define kYodo1MasMaxBannerViewTag   10030

@interface Yodo1Mas()

@property (nonatomic, strong) Yodo1MasInitConfig *masInitConfig;
@property (nonatomic, strong) Yodo1MasNetworkConfig *masNetworkConfig;
@property (nonatomic, strong) NSMutableDictionary *mediations;
@property (nonatomic, strong) Yodo1MasAdapterBase *currentAdapter;
@property (nonatomic, assign) BOOL isInit;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) int test_mode;
@property (nonatomic, copy  ) Yodo1MasAdCallback adBlock;
@property (nonatomic, strong) NSMutableDictionary *appInfo;
@property (nonatomic, assign) BOOL currentIsAdaptiveBanner;
@property (nonatomic, assign) BOOL keepChecking;
@property (nonatomic, strong) NSDictionary * showObject;

@end

@implementation Yodo1Mas

+ (Yodo1Mas *)sharedInstance {
    static Yodo1Mas *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Yodo1Mas alloc] init];
    });
    return _instance;
}

+ (NSString *)sdkVersion {
    return @"4.2.0";
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mediations = [NSMutableDictionary dictionary];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id gdpr = [defaults objectForKey:Yodo1MasGDPRUserConsent];
        _isGDPRUserConsent =  gdpr != nil ? [gdpr boolValue] : YES;
        
        id coppa = [defaults objectForKey:Yodo1MasCOPPAAgeRestricted];
        _isCOPPAAgeRestricted = coppa != nil ? [coppa boolValue] : NO;
        
        id ccpa = [defaults objectForKey:Yodo1MasCCPADoNotSell];
        _isCCPADoNotSell = ccpa != nil ? [ccpa boolValue] : NO;
        
        _appInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)orientationDidChange:(NSNotification *)noti {
    UIViewController *controller = [Yodo1MasAdapterBase getTopViewController];
    UIView * container = nil;
    if (self.test_mode == 1) {
        container = [controller.view viewWithTag:131415];
        if (container) {
            [Yodo1MasBanner showBannerWithTag:131415 controller:controller object:self.showObject];
        }
        return;
    }
    NSInteger i = 10001;
    do {
        container = [controller.view viewWithTag:i];
    } while (!container && i++ < kYodo1MasMaxBannerViewTag);
    if (container) {
        [Yodo1MasBanner showBannerWithTag:i controller:controller object:self.showObject];
    }
}

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
    [self initWithAppKey:appId successful:successful fail:fail];
}

- (void)initWithAppKey:(NSString *)appKey successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
    if (!appKey|| !appKey.length) {
        if (fail) {
            fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAppKeyIllegal message:@"Invalid AppKey or Wrong AppKey"]);
        }
        return;
    }

    NSDictionary *yodo1Config = [[NSBundle mainBundle] infoDictionary][@"Yodo1MasConfig"];
    BOOL sensorsDebugEnv = yodo1Config[@"sensors_debug_env"] && [yodo1Config[@"sensors_debug_env"] boolValue];
    
    __weak __typeof(self)weakSelf = self;
    
    // init sa sdk
    NSString *serverURL = @"https://sensors.yodo1api.com/sa?project=production";
    if (sensorsDebugEnv) {
        serverURL = @"https://sensors.yodo1api.com/sa?project=default";
    }
    //init Sa SDK,debugMode:0 close debug, 1 is debug,2 is debug and data import
    [Yodo1SaManager initializeSdkServerURL: serverURL debug:0];
    
    NSDictionary *sdkConfig = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"yodo1mas" withExtension:@"plist"]];
    
    NSString *sdkVersion = sdkConfig[@"sdkVersion"];
    if (!sdkVersion || !sdkVersion.length) {
        sdkVersion = [Yodo1Mas sdkVersion];
    }
    
    NSString *bundleId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    [Yodo1SaManager registerSuperProperties:@{@"gameKey": appKey,
                                              @"gameBundleId": bundleId,
                                              @"sdkType": @"mas_global",
                                              @"publishChannelCode": @"appstore",
                                              @"sdkVersion": sdkVersion}];
    //[Yodo1SaManager track:@"adInit" properties:nil];

    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            
        }];
    }
    // app info
    NSInteger sdkType = [sdkConfig[@"sdkTypeCode"] integerValue];
    [_appInfo setValue:sdkVersion forKey:kYodo1MasSdkVersion];
    switch (sdkType) {
        case 1:
            [_appInfo setValue:@"Full" forKey:kYodo1MasSdkType];
            break;
        case 2:
            [_appInfo setValue:@"Standrad" forKey:kYodo1MasSdkType];
            break;
        case 3:
            [_appInfo setValue:@"CN" forKey:kYodo1MasSdkType];
            break;
        default:
            break;
    }
    [_appInfo setValue:appKey forKey:kYodo1MasAppKey];
    [_appInfo setValue:[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:kYodo1MasAppVersion];
    [_appInfo setValue:[NSBundle.mainBundle objectForInfoDictionaryKey:@"GADApplicationIdentifier"] forKey:kYodo1MasAdMobId];
    [_appInfo setValue:bundleId forKey:kYodo1MasAppBundleId];
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    if (!idfa || !idfa.length || [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
//        idfa = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    }
    if (![@"00000000-0000-0000-0000-000000000000" isEqualToString:idfa]) {
        [_appInfo setValue:idfa forKey:kYodo1MasIDFA];
    }
    
    // request config
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (weakSelf.isInit) return;
        
        if (status == AFNetworkReachabilityStatusNotReachable) return;
        
        [weakSelf doInit:appKey successful:successful fail:fail];
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)doInit:(NSString *)appKey successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
    __weak __typeof(self)weakSelf = self;
    if (_isInit || ![AFNetworkReachabilityManager sharedManager].reachable || _isRequesting) {
        if (_isInit && successful != nil) {
            successful();
        }
        return;
    }
    
    NSDictionary *yodo1Config = [[NSBundle mainBundle] infoDictionary][@"Yodo1MasConfig"];
    BOOL debug = yodo1Config[@"Debug"] && [yodo1Config[@"Debug"] boolValue];
    
    NSMutableString *url = [NSMutableString string];
    if (debug) {
        NSString *api = yodo1Config[@"Api"];
        if (api != nil && api.length > 0) {
            [url appendString:api];
        } else {
            [url appendString:@"https://sdk.mas.yodo1.me/v1/init/"];
        }
    } else {
        [url appendString:@"https://sdk.mas.yodo1.com/v1/init/"];
    }
    
    [url appendString:appKey];
        
    if (@available(iOS 10.0, *)) {
        if (debug)[url appendFormat:@"?country=%@", [NSLocale currentLocale].countryCode];
    }
    
    NSLog(@"request - %@", url);
    
    _isRequesting = YES;
    
    NSDictionary *headers = @{@"sdk-version" : _appInfo[kYodo1MasSdkVersion]};
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:_appInfo[kYodo1MasSdkVersion] forKey:@"sdk_version"];
    [parameters setValue:_appInfo[kYodo1MasAppVersion] forKey:@"app_version"];
    if (_appInfo[kYodo1MasIDFA]) {
        [parameters setValue:_appInfo[kYodo1MasIDFA] forKey:@"idfa"];
    }
    
    [self trackInitStart];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:url parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf trackInitEnd:YES];
        Yodo1MasInitData *data;
        if (debug && yodo1Config[@"Config"] != nil) {
            data = [Yodo1MasInitData yy_modelWithJSON:yodo1Config[@"Config"]];
        } else {
            data = [Yodo1MasInitData yy_modelWithJSON:responseObject];
        }
        if (data != nil && data.mas_init_config != nil && data.ad_network_config != nil) {
            if (debug) {
                NSLog(@"get config successful - %@", responseObject);
            }
            
            if ([@"null" isEqualToString:data.bundle_id] || [weakSelf.appInfo[kYodo1MasAppBundleId] isEqualToString:data.bundle_id]) {
                // 如果不需要匹配BundleId或者BundleId匹配成功
                weakSelf.masInitConfig = data.mas_init_config;
                weakSelf.masNetworkConfig = data.ad_network_config;
                weakSelf.test_mode = data.test_mode;
                
                if (data.test_mode == 1) {
                    [Yodo1AdsManager.sharedInstance initAdvert];
                    [weakSelf.appInfo setValue:@"On" forKey:kYodo1MasTestMode];
                    [weakSelf.appInfo setValue:@"On" forKey:kYodo1MasTestDevice];
                } else {
                    [weakSelf.appInfo setValue:@"Off" forKey:kYodo1MasTestMode];
                    [weakSelf.appInfo setValue:@"Off" forKey:kYodo1MasTestDevice];
                }
                [weakSelf doInitAdapter];
                weakSelf.isInit = YES;
                [weakSelf.appInfo setValue:@(YES) forKey:kYodo1MasInitStatus];
                [weakSelf.appInfo setValue:@"Init successfully (AppKey & Bundle ID Verified)" forKey:kYodo1MasInitMsg];
                if (weakSelf.keepChecking) {
                    [weakSelf showAdvert:Yodo1MasAdTypeBanner object:weakSelf.showObject];
                }
                if (successful) {
                    successful();
                }
            } else {
                [weakSelf.appInfo setValue:@(NO) forKey:kYodo1MasInitStatus];
                NSString *msg = [NSString stringWithFormat:@"Init failed (Error Code: %@, AppKey Bundle ID Admob ID not match please check your app profile)", @(Yodo1MasErrorCodeAppKeyUnverified)];
                [weakSelf.appInfo setValue:msg forKey:kYodo1MasInitMsg];
                if (fail) {
                    fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAppKeyIllegal message:msg]);
                }
            }
        } else {
            if (fail) {
                fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigGet message:@"Data parsing failed"]);
            }
            [weakSelf.appInfo setValue:@(NO) forKey:kYodo1MasInitStatus];
            [weakSelf.appInfo setValue:[NSString stringWithFormat:@"Init failed(Error Code:%@,Data parsing failed)", @(Yodo1MasErrorCodeConfigGet)] forKey:kYodo1MasInitMsg];
        }
        
        [weakSelf printInitLog];
        weakSelf.isRequesting = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.isRequesting = NO;
        [weakSelf trackInitEnd:NO];
        if (fail) {
            fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigNetwork message:error.localizedDescription]);
        }
        
        [weakSelf.appInfo setValue:@(NO) forKey:kYodo1MasInitStatus];
        [weakSelf.appInfo setValue:[NSString stringWithFormat:@"Init failed(Error Code:%@,%@)", @(Yodo1MasErrorCodeConfigNetwork), error.localizedDescription] forKey:kYodo1MasInitMsg];
        [weakSelf printInitLog];
    }];
}

- (void)trackInitStart {
    long long start = [NSDate date].timeIntervalSince1970;
    [_appInfo setValue:@(start) forKey:kYodo1MasInitTime];
    //[Yodo1SaManager track:@"adInit" properties:@{@"initAction": @"request"}];
}

- (void)trackInitEnd:(BOOL)successful {
    long long start = [_appInfo[kYodo1MasInitTime] longLongValue];
    long long end = [NSDate date].timeIntervalSince1970;
    [Yodo1SaManager track:@"adInit" properties:@{@"initAction": successful ? @"response" : @"error", @"initDuration" : @(end - start)}];
}

- (void)printInitLog {
    NSMutableString *ms = [NSMutableString string];
    [ms appendString:@"******************************************\n"];
    [ms appendString:@"Yodo1MasSdk\n"];
    
    NSString *version = _appInfo[kYodo1MasSdkVersion];
    if (_appInfo[kYodo1MasSdkType]) {
        version = [version stringByAppendingFormat:@"-%@", _appInfo[kYodo1MasSdkType]];
    }
    [ms appendFormat:@"MAS SDK Version: %@\n", version];
    [ms appendFormat:@"AppKey: %@ \n", _appInfo[kYodo1MasAppKey]];
    [ms appendFormat:@"Bundle ID: %@ \n", _appInfo[kYodo1MasAppBundleId]];
    if (_appInfo[kYodo1MasInitStatus]) {
        [ms appendFormat:@"Init Status: %@\n", _appInfo[kYodo1MasInitMsg]];
    } else {
        [ms appendString:@"Init Status: None\n"];
    }
    
    if (_appInfo[kYodo1MasIDFA]) {
        [ms appendFormat:@"IDFA is: %@（use this for  test devices）\n", _appInfo[kYodo1MasIDFA]];
    } else {
        [ms appendString:@"IDFA is: Get IDFA failed(Unauthorized)\n"];
    }
    
    if (_appInfo[kYodo1MasAdMobId]) {
        [ms appendFormat:@"AdMob ID is: %@\n", _appInfo[kYodo1MasAdMobId]];
    } else {
        [ms appendString:@"AdMob ID is: None（please fill correct  AppKey）\n"];
    }
    
    if (_appInfo[kYodo1MasTestMode]) {
        [ms appendFormat:@"Test Device: %@\n", _appInfo[kYodo1MasTestMode]];
    } else {
        [ms appendString:@"Test Device: None\n"];
    }
    
    if (_appInfo[kYodo1MasTestDevice]) {
        [ms appendFormat:@"Test Ad: %@\n", _appInfo[kYodo1MasTestDevice]];
    } else {
        [ms appendString:@"Test Ad: None\n"];
    }
    
    
    [ms appendString:@"******************************************"];
    NSLog(@"[Yodo1Mas]:\n%@", ms);
}

- (void)doInitAdapter {
    NSDictionary *mediations = @{
        @"ADMOB" : @"Yodo1MasAdMobMaxAdapter",
        @"APPLOVIN" : @"Yodo1MasAppLovinMaxAdapter",
        @"IRONSOURCE" : @"Yodo1MasIronSourceMaxAdapter"
    };
    
    NSDictionary *networks = @{
        //@"adcolony" : @"Yodo1MasAdColonyAdapter",
        @"admob" : @"Yodo1MasAdMobAdapter",
        @"applovin" : @"Yodo1MasAppLovinAdapter",
        @"baidu" : @"Yodo1MasBaiduAdapter",
        @"facebook" : @"Yodo1MasFacebookAdapter",
        //@"fyber" : @"Yodo1MasFyberAdapter",
        @"inmobi" : @"Yodo1MasInMobiAdapter",
        @"ironsource" : @"Yodo1MasIronSourceAdapter",
        //@"mintegral" : @"Yodo1MasMintegralAdapter",
        @"mytarget" : @"Yodo1MasMyTargetAdapter",
        //@"pangle" : @"Yodo1MasPangleAdapter",
        @"tapjoy" : @"Yodo1MasTapjoyAdapter",
        //@"tencent" : @"Yodo1MasTencentAdapter",
        @"unity" : @"Yodo1MasUnityAdsAdapter",
        @"vungle" : @"Yodo1MasVungleAdapter",
        @"yandex" : @"Yodo1MasYandexAdapter"
    };
    
    if (self.masInitConfig.mediation_list != nil && self.masInitConfig.mediation_list.count > 0) {
        for (Yodo1MasInitMediationInfo *info in self.masInitConfig.mediation_list) {
            NSString *key = info.name;
            NSString *value = mediations[key];
            [self doInitAdapter:key value:value appId:info.app_id appKey:info.app_key];
        }
    }
    
    if (self.masInitConfig.ad_network_list != nil && self.masInitConfig.ad_network_list.count > 0) {
        for (Yodo1MasInitNetworkInfo *info in self.masInitConfig.ad_network_list) {
            NSString *key = info.ad_network_name;
            NSString *value = networks[key];
            [self doInitAdapter:key value:value appId:info.ad_network_app_id appKey:info.ad_network_app_key];
        }
    }
    if (self.masNetworkConfig.banner) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    if (self.test_mode == 1) {
        [Yodo1AdsManager.sharedInstance bannerCallback:^(YODO1BannerState state) {
            switch (state) {
                case kYODO1BannerStateFail:
                {
                    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:@"load of error!"];
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:Yodo1MasAdTypeBanner message:@"" error:error];
                    if ([self.bannerAdDelegate respondsToSelector:@selector(onAdError:error:)]) {
                        [self.bannerAdDelegate onAdError:event error:error];
                    }
                }
                    break;
                case kYODO1BannerStateShow:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
                    if ([self.bannerAdDelegate respondsToSelector:@selector(onAdOpened:)]) {
                        [self.bannerAdDelegate onAdOpened:event];
                    }
                }
                    break;
                case kYODO1BannerStateClose:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeBanner];
                    if ([self.bannerAdDelegate respondsToSelector:@selector(onAdClosed:)]) {
                        [self.bannerAdDelegate onAdClosed:event];
                    }
                }
                    break;
                default:
                    break;
            }
        }];
        [Yodo1AdsManager.sharedInstance videoCallback:^(YODO1VideoState state) {
            
            switch (state) {
                case kYODO1VideoStateFail:
                {
                    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:@"load of error!"];
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:Yodo1MasAdTypeReward message:@"" error:error];
                    if ([self.rewardAdDelegate respondsToSelector:@selector(onAdError:error:)]) {
                        [self.rewardAdDelegate onAdError:event error:error];
                    }
                }
                    break;
                case kYODO1VideoStateFinished:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeRewardEarned type:Yodo1MasAdTypeReward];
                    if ([self.rewardAdDelegate respondsToSelector:@selector(onAdRewardEarned:)]) {
                        [self.rewardAdDelegate onAdRewardEarned:event];
                    }
                }
                    break;
                case kYODO1VideoStateShow:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeReward];
                    if ([self.rewardAdDelegate respondsToSelector:@selector(onAdOpened:)]) {
                        [self.rewardAdDelegate onAdOpened:event];
                    }
                }
                    break;
                case kYODO1VideoStateClose:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeReward];
                    if ([self.rewardAdDelegate respondsToSelector:@selector(onAdClosed:)]) {
                        [self.rewardAdDelegate onAdClosed:event];
                    }
                }
                    break;
                default:
                    break;
            }
        }];
        [Yodo1AdsManager.sharedInstance intersCallback:^(YODO1InterstitialState state) {
            switch (state) {
                case kYODO1InterstitialStateFail:
                {
                    
                    Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdLoadFail message:@"load of error!"];
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:Yodo1MasAdTypeInterstitial message:@"" error:error];
                    if ([self.interstitialAdDelegate respondsToSelector:@selector(onAdError:error:)]) {
                        [self.interstitialAdDelegate onAdError:event error:error];
                    }
                }
                    break;
                case kYODO1InterstitialStateShow:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeInterstitial];
                    if ([self.interstitialAdDelegate respondsToSelector:@selector(onAdOpened:)]) {
                        [self.interstitialAdDelegate onAdOpened:event];
                    }
                }
                    break;
                case kYODO1InterstitialStateClose:
                {
                    Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeClosed type:Yodo1MasAdTypeInterstitial];
                    if ([self.interstitialAdDelegate respondsToSelector:@selector(onAdClosed:)]) {
                        [self.interstitialAdDelegate onAdClosed:event];
                    }
                }
                    break;
                default:
                    break;
            }
        }];
        UIViewController* controller = [Yodo1MasAdapterBase getTopViewController];
        [Yodo1MasBanner addBanner:Yodo1AdsManager.sharedInstance.bannerView tag:131415 controller:controller];
    }
}

- (void)doInitAdapter:(NSString *)key value:(NSString *)value appId:(NSString *)appId appKey:(NSString *)appKey {
    if (value && value.length > 0) {
        Class c = NSClassFromString(value);
        NSObject *o = c != nil ? [[c alloc] init] : nil;
        if (o != nil && [o isKindOfClass:[Yodo1MasAdapterBase class]]) {
            Yodo1MasAdapterConfig *config = [[Yodo1MasAdapterConfig alloc] init];
            config.name = key;
            config.appId = appId;
            config.appKey = appKey;
            Yodo1MasAdapterBase *adapter = (Yodo1MasAdapterBase *)o;
            self.mediations[key] = adapter;
            [self doInitAdvert: key];
            
            [adapter initWithConfig:config successful:^(NSString *advertCode) {
                NSLog(@"Adapter init successful - %@:%@", key, value);
            } fail:^(NSString *advertCode, NSError *error) {
                NSLog(@"Adapter init failed - %@:%@, %@", key, value, error.description);
            }];
        } else {
            if (o == nil) {
                NSLog(@"The adapter is not integrated -  %@", value);
            } else {
                NSLog(@"The adapter is not Yodo1MasAdapterBase subclass - %@", key);
            }
        }
    } else {
        NSLog(@"Adapter Init - the adapter does not found or SDK verson is too low: - %@", key);
    }
}

- (void)doInitAdvert:(NSString *)key {
    if (self.masNetworkConfig.reward != nil) {
        [self doInitAdvert:self.masNetworkConfig.reward type:Yodo1MasAdTypeReward key:(NSString *)key];
    }
    if (self.masNetworkConfig.interstitial != nil) {
        [self doInitAdvert:self.masNetworkConfig.interstitial type:Yodo1MasAdTypeInterstitial key:(NSString *)key];
    }
    if (self.masNetworkConfig.banner != nil) {
        [self doInitAdvert:self.masNetworkConfig.banner type:Yodo1MasAdTypeBanner key:(NSString *)key];
    }
}

- (void)doInitAdvert:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdType)type key:(NSString *)key {
    if (config.mediation_list != nil && config.mediation_list.count > 0) {
        for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
            NSString *mediationName = mediation.name;
            NSString *unitId = mediation.unit_id;
            if (mediationName != nil && unitId != nil && [mediationName isEqualToString:key]) {
                Yodo1MasAdapterBase *adapter = _mediations[mediationName];
                if (adapter != nil) {
                    switch (type) {
                        case Yodo1MasAdTypeReward: {
                            [adapter.rewardAdIds removeAllObjects];
                            [adapter.rewardAdIds addObject:[[Yodo1MasAdId alloc]initWitId:unitId object:nil]];
                            break;
                        }
                        case Yodo1MasAdTypeInterstitial: {
                            [adapter.interstitialAdIds removeAllObjects];
                            [adapter.interstitialAdIds addObject:[[Yodo1MasAdId alloc]initWitId:unitId object:nil]];
                            break;
                        }
                        case Yodo1MasAdTypeBanner: {
                            [adapter.bannerAdIds removeAllObjects];
                            [adapter.bannerAdIds addObject:[[Yodo1MasAdId alloc]initWitId:unitId object:nil]];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    if (config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
        for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
            NSArray<Yodo1MasNetworkPlacement *> *placements = waterfall.placements;
            NSString *networkName = waterfall.network;
            if (networkName != nil && networkName.length > 0 && placements != nil && placements.count > 0  && [networkName isEqualToString:key]) {
                Yodo1MasAdapterBase *adapter = _mediations[networkName];
                if (adapter != nil) {
                    switch (type) {
                        case Yodo1MasAdTypeReward: {
                            [adapter.rewardAdIds removeAllObjects];
                            for (Yodo1MasNetworkPlacement *placement in placements) {
                                [adapter.rewardAdIds addObject:[[Yodo1MasAdId alloc] initWitId:placement.network_code object:placement]];
                            }
                            break;
                        }
                        case Yodo1MasAdTypeInterstitial: {
                            [adapter.interstitialAdIds removeAllObjects];
                            for (Yodo1MasNetworkPlacement *placement in placements) {
                                [adapter.interstitialAdIds addObject:[[Yodo1MasAdId alloc] initWitId:placement.network_code object:placement]];
                            }
                            break;
                        }
                        case Yodo1MasAdTypeBanner: {
                            [adapter.bannerAdIds removeAllObjects];
                            for (Yodo1MasNetworkPlacement *placement in placements) {
                                [adapter.bannerAdIds addObject:[[Yodo1MasAdId alloc] initWitId:placement.network_code object:placement]];
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
}

- (void)setIsGDPRUserConsent:(BOOL)isGDPRUserConsent {
    if (isGDPRUserConsent != _isGDPRUserConsent) {
        _isGDPRUserConsent = isGDPRUserConsent;
        [[NSUserDefaults standardUserDefaults] setBool:_isGDPRUserConsent forKey:Yodo1MasGDPRUserConsent];
        
        for (Yodo1MasAdapterBase *adapter in _mediations.allValues) {
            [adapter updatePrivacy];
        }
    }
}

- (void)setIsCOPPAAgeRestricted:(BOOL)isCOPPAAgeRestricted {
    if (isCOPPAAgeRestricted != _isCOPPAAgeRestricted) {
        _isCOPPAAgeRestricted = isCOPPAAgeRestricted;
        [[NSUserDefaults standardUserDefaults] setBool:_isCOPPAAgeRestricted forKey:Yodo1MasCOPPAAgeRestricted];
        
        for (Yodo1MasAdapterBase *adapter in _mediations.allValues) {
            [adapter updatePrivacy];
        }
    }
}

- (void)setIsCCPADoNotSell:(BOOL)isCCPADoNotSell {
    if (isCCPADoNotSell != _isCCPADoNotSell) {
        _isCCPADoNotSell = isCCPADoNotSell;
        [[NSUserDefaults standardUserDefaults] setBool:_isCCPADoNotSell forKey:Yodo1MasCCPADoNotSell];
        
        for (Yodo1MasAdapterBase *adapter in _mediations.allValues) {
            [adapter updatePrivacy];
        }
    }
}

- (BOOL)isAdvertLoaded:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdType)type {
    BOOL isLoaded = NO;
    if (self.test_mode == 1) {
        switch (type) {
            case Yodo1MasAdTypeReward:
                isLoaded = [Yodo1AdsManager.sharedInstance isVideoReady];
                break;
            case Yodo1MasAdTypeInterstitial:
                isLoaded = [Yodo1AdsManager.sharedInstance isInterstitialReady];
                break;
            case Yodo1MasAdTypeBanner:
                isLoaded = [Yodo1AdsManager.sharedInstance isBannerReady];
                break;
        }
        return isLoaded;
    }
    
    if (config != nil) {
        if (config.mediation_list != nil && config.mediation_list.count > 0) {
            for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
                NSString *name = mediation.name;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        isLoaded = [adapter isAdLoaded:type];
                    }
                }
            }
        }
        
        if (!isLoaded && config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
            for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
                NSString *name = waterfall.network;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        isLoaded = [adapter isAdLoaded:type];
                    }
                }
                if (isLoaded) break;
            }
        }
    }
    return isLoaded;
}

- (void)loadAdvert:(Yodo1MasNetworkAdvert *)config type:(Yodo1MasAdType)type {
    if (config != nil) {
        if (config.mediation_list != nil && config.mediation_list.count > 0) {
            for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
                NSString *name = mediation.name;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        [adapter loadAd:type];
                    }
                }
            }
        }
        
        if (config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
            for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
                NSString *name = waterfall.network;
                if (name != nil && name.length > 0) {
                    Yodo1MasAdapterBase *adapter = self.mediations[name];
                    if (adapter != nil) {
                        [adapter loadAd:type];
                    }
                }
            }
        }
    }
}

- (NSMutableArray<Yodo1MasAdapterBase *> *)getAdapters:(Yodo1MasNetworkAdvert *)config {
    NSMutableArray<Yodo1MasAdapterBase *> *adapters = [NSMutableArray array];
    if (config.mediation_list != nil && config.mediation_list.count > 0) {
        for (Yodo1MasNetworkMediation *mediation in config.mediation_list) {
            NSString *name = mediation.name;
            if (name != nil && name.length > 0) {
                Yodo1MasAdapterBase *adapter = self.mediations[name];
                if (adapter != nil && ![adapters containsObject:adapter]) {
                    [adapters addObject:adapter];
                }
            }
        }
    }
    
    if (config.fallback_waterfall != nil && config.fallback_waterfall.count > 0) {
        for (Yodo1MasNetworkWaterfall *waterfall in config.fallback_waterfall) {
            NSString *name = waterfall.network;
            if (name != nil && name.length > 0) {
                Yodo1MasAdapterBase *adapter = self.mediations[name];
                if (adapter != nil && ![adapters containsObject:adapter]) {
                    [adapters addObject:adapter];
                }
            }
        }
    }
    return adapters;
}

- (void)showAdvert:(Yodo1MasAdType)type {
    [self showAdvert:type object:nil];
}

- (void)showAdvert:(Yodo1MasAdType)type object:(NSDictionary *)object {
    if (self.test_mode == 1) {
        switch (type) {
            case Yodo1MasAdTypeReward:
            {
                [Yodo1AdsManager.sharedInstance showVideo:[Yodo1MasAdapterBase getTopViewController]];
            }
                break;
            case Yodo1MasAdTypeInterstitial:
            {
                [Yodo1AdsManager.sharedInstance showInterstitial:[Yodo1MasAdapterBase getTopViewController]];
            }
                break;
            case Yodo1MasAdTypeBanner:
            {
                UIViewController *controller = [Yodo1MasAdapterBase getTopViewController];
                [Yodo1MasBanner showBanner:Yodo1AdsManager.sharedInstance.bannerView tag:131415 controller:controller object:object];
                Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeOpened type:Yodo1MasAdTypeBanner];
                if ([self.bannerAdDelegate respondsToSelector:@selector(onAdOpened:)]) {
                    [self.bannerAdDelegate onAdOpened:event];
                }
            }
                break;
        }
        return;
    }
    Yodo1MasNetworkAdvert *config = nil;
    switch (type) {
        case Yodo1MasAdTypeReward:
            config = self.masNetworkConfig != nil ? self.masNetworkConfig.reward : nil;
            break;
        case Yodo1MasAdTypeInterstitial:
            config = self.masNetworkConfig != nil ? self.masNetworkConfig.interstitial : nil;
            break;
        case Yodo1MasAdTypeBanner:
            config = self.masNetworkConfig != nil ? self.masNetworkConfig.banner : nil;
            break;
    }
    
    
    if (config != nil) {
        _currentAdapter = nil;
        __weak __typeof(self)weakSelf = self;
        NSMutableArray<Yodo1MasAdapterBase *> *adapters = [self getAdapters:config];
        _adBlock = ^(Yodo1MasAdEvent *event) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            switch (event.code) {
                case Yodo1MasAdEventCodeOpened: {
                    [adapters removeAllObjects];
                    [strongSelf callbackWithEvent:event];
                    break;
                }
                case Yodo1MasAdEventCodeLoaded: {
                    [adapters removeAllObjects];
                    if (event.type == Yodo1MasAdTypeBanner && self.keepChecking) {
                        [strongSelf showAdvert:Yodo1MasAdTypeBanner object:object];
                        strongSelf.keepChecking = NO;
                    }
                    break;
                }
                case Yodo1MasAdEventCodeError: {
                    if (adapters.count > 0) {
                        [adapters removeObjectAtIndex:0];
                    }
                    if (adapters.count > 0) {
                        strongSelf.currentAdapter = adapters.firstObject;
                        [adapters.firstObject showAd:type callback:weakSelf.adBlock object:object];
                    } else {
                        strongSelf.adBlock = nil;
                        [strongSelf callbackWithEvent:event];
                    }
                    break;
                }
                default: {
                    [strongSelf callbackWithEvent:event];
                    break;
                }
            }
        };
        if (adapters.count > 0) {
            _currentAdapter = adapters.firstObject;
            [adapters.firstObject showAd:type callback:_adBlock object:object];
        } else {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdUninitialized message:@"ad adapters is null"];
            Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:type message:@"" error:error];
            [self callbackWithEvent:event];
        }
    } else {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdConfigNull message:@"Wrong ad type call.Please check your app profile on MAS to ensure you have selected the correct ad type."];
        Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:type message:@"" error:error];
        [self callbackWithEvent:event];
    }
}

- (void)callbackWithEvent:(Yodo1MasAdEvent *)event {
    switch (event.type) {
        case Yodo1MasAdTypeReward: {
            id<Yodo1MasRewardAdDelegate> delegate = self.rewardAdDelegate;
            if (delegate != nil) {
                switch (event.code) {
                    case Yodo1MasAdEventCodeOpened: {
                        if ([delegate respondsToSelector:@selector(onAdOpened:)]) {
                            [delegate onAdOpened:event];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeClosed: {
                        if ([delegate respondsToSelector:@selector(onAdClosed:)]) {
                            [delegate onAdClosed:event];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeError: {
                        if ([delegate respondsToSelector:@selector(onAdError:error:)]) {
                            [delegate onAdError:event error:event.error];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeRewardEarned: {
                        if ([delegate respondsToSelector:@selector(onAdRewardEarned:)]) {
                            [delegate onAdRewardEarned:event];
                        }
                        break;
                    }
                    default:break;
                }
            }
            break;
        }
            
        case Yodo1MasAdTypeInterstitial: {
            id delegate = self.interstitialAdDelegate;
            if (delegate != nil) {
                switch (event.code) {
                    case Yodo1MasAdEventCodeOpened: {
                        if ([delegate respondsToSelector:@selector(onAdOpened:)]) {
                            [delegate onAdOpened:event];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeClosed: {
                        if ([delegate respondsToSelector:@selector(onAdClosed:)]) {
                            [delegate onAdClosed:event];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeError: {
                        if ([delegate respondsToSelector:@selector(onAdError:error:)]) {
                            [delegate onAdError:event error:event.error];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeRewardEarned: {
                        
                        break;
                    }
                    default:break;
                }
            }
            break;
        }
        case Yodo1MasAdTypeBanner: {
            id delegate = self.bannerAdDelegate;
            if (delegate != nil) {
                switch (event.code) {
                    case Yodo1MasAdEventCodeOpened: {
                        if ([delegate respondsToSelector:@selector(onAdOpened:)]) {
                            [delegate onAdOpened:event];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeClosed: {
                        if ([delegate respondsToSelector:@selector(onAdClosed:)]) {
                            [delegate onAdClosed:event];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeError: {
                        if ([delegate respondsToSelector:@selector(onAdError:error:)]) {
                            [delegate onAdError:event error:event.error];
                        }
                        break;
                    }
                    case Yodo1MasAdEventCodeRewardEarned: {
                        
                        break;
                    }
                    default:break;
                }
            }
            break;
        }
    }
}

#pragma mark - 激励广告
- (BOOL)isRewardAdLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.reward type:Yodo1MasAdTypeReward];
}

- (void)loadRewardAdvert {
    [self loadAdvert:self.masNetworkConfig.reward type:Yodo1MasAdTypeReward];
}

- (void)showRewardAd {
    [self showAdvert:Yodo1MasAdTypeReward];
}

- (void)showRewardAdWithPlacement:(NSString *)placement {
    NSMutableDictionary *object = [NSMutableDictionary dictionary];
    if (placement != nil && placement.length > 0) {
        object[kArgumentPlacement] = placement;
    }
    [self showAdvert:Yodo1MasAdTypeReward object:object];
}

- (void)dismissRewardAdvert {
    if (_currentAdapter != nil) {
        [_currentAdapter dismissRewardAd];
    }
}

#pragma mark - 插屏广告
- (BOOL)isInterstitialAdLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.interstitial type:Yodo1MasAdTypeInterstitial];
}

- (void)loadInterstitialAdvert {
    [self loadAdvert:self.masNetworkConfig.interstitial type:Yodo1MasAdTypeInterstitial];
}

- (void)showInterstitialAd {
    [self showAdvert:Yodo1MasAdTypeInterstitial];
}

- (void)showInterstitialAdWithPlacement:(NSString *)placement {
    NSMutableDictionary *object = [NSMutableDictionary dictionary];
    if (placement != nil && placement.length > 0) {
        object[kArgumentPlacement] = placement;
    }
    [self showAdvert:Yodo1MasAdTypeInterstitial object:object];
}

- (void)dismissInterstitialAd {
    if (_currentAdapter != nil) {
        [_currentAdapter dismissInterstitialAd];
    }
}

#pragma mark - 横幅广告
- (void)setAdBuildConfig:(Yodo1MasAdBuildConfig *)buildConfig {
    if (self.currentIsAdaptiveBanner == buildConfig.enableAdaptiveBanner) {return;}
    self.currentIsAdaptiveBanner = buildConfig.enableAdaptiveBanner;
    if ([self isInit]) {
        [self dismissBannerAdWithDestroy:YES];
        [self loadBannerAdvert];
    }
}

- (BOOL)isBannerAdLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.banner type:Yodo1MasAdTypeBanner];
}

- (void)loadBannerAdvert {
    [self loadAdvert:self.masNetworkConfig.banner type:Yodo1MasAdTypeBanner];
}

- (void)showBannerAd {
    [self showBannerAdWithPlacement:nil align:Yodo1MasAdBannerAlignBottom | Yodo1MasAdBannerAlignHorizontalCenter offset:CGPointZero];
}

- (void)showBannerAdWithPlacement:(NSString * __nullable)placement {
    [self showBannerAdWithPlacement:placement align:Yodo1MasAdBannerAlignBottom | Yodo1MasAdBannerAlignHorizontalCenter offset:CGPointZero];
}

- (void)showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align {
    [self showBannerAdWithPlacement:nil align:align offset:CGPointZero];
}

- (void)showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align offset:(CGPoint)offset {
    [self showBannerAdWithPlacement:nil align:align offset:offset];
}

- (void)showBannerAdWithPlacement:(NSString * __nullable)placement align:(Yodo1MasAdBannerAlign)align offset:(CGPoint)offset {
    NSMutableDictionary *object = [NSMutableDictionary dictionary];
    if (placement != nil && placement.length > 0) {
        object[kArgumentPlacement] = placement;
    }
    object[kArgumentBannerAlign] = @(align);
    object[kArgumentBannerOffset] = [NSValue valueWithCGPoint:offset];
    
    self.keepChecking = YES;
    self.showObject = object;
    if (self.masNetworkConfig.banner) {
        [self showAdvert:Yodo1MasAdTypeBanner object:object];
    }
}

- (void)dismissBannerAd {
    self.keepChecking = NO;

    if (self.test_mode == 1) {
        [Yodo1MasBanner removeBanner:Yodo1AdsManager.sharedInstance.bannerView tag:131415 destroy:NO];
    }
    if (_currentAdapter != nil) {
        [_currentAdapter dismissBannerAd];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    self.keepChecking = NO;
    
    if (self.test_mode == 1) {
        [Yodo1MasBanner removeBanner:Yodo1AdsManager.sharedInstance.bannerView tag:131415 destroy:NO];
    }
    if (_currentAdapter != nil) {
        [_currentAdapter dismissBannerAdWithDestroy:destroy];
    }
}

@end
