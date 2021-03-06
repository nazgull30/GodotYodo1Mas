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

#define Yodo1MasGDPRUserConsent     @"Yodo1MasGDPRUserConsent"
#define Yodo1MasCOPPAAgeRestricted  @"Yodo1MasCOPPAAgeRestricted"
#define Yodo1MasCCPADoNotSell       @"Yodo1MasCCPADoNotSell"

@interface Yodo1Mas()

@property (nonatomic, strong) Yodo1MasInitConfig *masInitConfig;
@property (nonatomic, strong) Yodo1MasNetworkConfig *masNetworkConfig;
@property (nonatomic, strong) NSMutableDictionary *mediations;
@property (nonatomic, strong) Yodo1MasAdapterBase *currentAdapter;
@property (nonatomic, assign) BOOL isInit;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, copy) Yodo1MasAdCallback adBlock;

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
    return @"4.0.1.1";
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
        
        NSLog(@"Yodo1MasCore Version - %@", [Yodo1Mas sdkVersion]);
    }
    return self;
}

- (void)initWithAppId:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
#if defined(__IPHONE_14_0)
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            
        }];
    }
#endif
    
    NSDictionary *yodo1Config = [[NSBundle mainBundle] infoDictionary][@"Yodo1MasConfig"];
    BOOL sensorsDebugEnv = yodo1Config[@"sensors_debug_env"] && [yodo1Config[@"sensors_debug_env"] boolValue];

    __weak __typeof(self)weakSelf = self;
    
    NSString *serverURL = @"https://sensors.yodo1api.com/sa?project=production";
    if (sensorsDebugEnv) {
        serverURL = @"https://sensors.yodo1api.com/sa?project=default";
    }
    //init Sa SDK,debugMode:0 close debug, 1 is debug,2 is debug and data import
    [Yodo1SaManager initializeSdkServerURL: serverURL debug:0];
    NSString* bundleId = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    [Yodo1SaManager registerSuperProperties:@{@"gameKey": appId,
                                              @"gameBundleId": bundleId,
                                              @"sdkType": @"mas_global",
                                              @"publishChannelCode": @"appstore",
                                              @"sdkVersion": [Yodo1Mas sdkVersion]}];
    [Yodo1SaManager track:@"adInit" properties:nil];
    
    [self doInit:appId successful:successful fail:fail];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (weakSelf.isInit) return;
        
        if (status == AFNetworkReachabilityStatusNotReachable) return;
        
        [weakSelf doInit:appId successful:successful fail:fail];
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)doInit:(NSString *)appId successful:(Yodo1MasInitSuccessful)successful fail:(Yodo1MasInitFail)fail {
    __weak __typeof(self)weakSelf = self;
    if (_isInit || ![AFNetworkReachabilityManager sharedManager].reachable || _isRequesting) {
        if (_isInit) {
            if (successful != nil) {
                successful();
            }
        } else {
            Yodo1MasError *error;
            if (_isRequesting) {
                error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigGet message:@"Initializing, please wait a moment"];
            } else {
                error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigNetwork message:@"Network is not visible"];
            }
            if (fail != nil) {
                fail(error);
            }
        }
        return;
    }
    
    NSDictionary *yodo1Config = [[NSBundle mainBundle] infoDictionary][@"Yodo1MasConfig"];
    BOOL debug = yodo1Config[@"Debug"] && [yodo1Config[@"Debug"] boolValue];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableString *url = [NSMutableString string];
    if (debug) {
        NSString *api = yodo1Config[@"Api"];
        if (api != nil && api.length > 0) {
            [url appendString:api];
        } else {
            [url appendString:@"https://rivendell-dev.explorer.yodo1.com/v1/init/"];
        }
        if (@available(iOS 10.0, *)) {
            parameters[@"country"] = [NSLocale currentLocale].countryCode;
        }
    } else {
        [url appendString:@"https://sdk.mas.yodo1.com/v1/init/"];
        //[url appendString:@"https://rivendell.explorer.yodo1.com/v1/init/"];
    }
    
    [url appendString:appId];
    
    NSLog(@"request - %@", url);
    
    _isRequesting = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url parameters:parameters headers:@{@"sdk-version" : [Yodo1Mas sdkVersion]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Yodo1MasInitData *data;
        if (debug && yodo1Config[@"Config"] != nil) {
            data = [Yodo1MasInitData yy_modelWithJSON:yodo1Config[@"Config"]];
        } else {
            data = [Yodo1MasInitData yy_modelWithJSON:responseObject];
        }
        if (data != nil) {
            weakSelf.masInitConfig = data.mas_init_config;
            weakSelf.masNetworkConfig = data.ad_network_config;
            if (data.mas_init_config && data.ad_network_config) {
                if (debug) {
                    NSLog(@"获取广告数据成功 - %@", responseObject);
                }
                [weakSelf doInitAdapter];
                weakSelf.isInit = YES;
                if (successful) {
                    successful();
                }
            } else {
                if (fail) {
                    fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigGet message:@"get config failed"]);
                }
            }
        } else {
            if (fail) {
                fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigServer message:@"get config failed"]);
            }
            NSLog(@"获取广告配置失败 - 解释配置数据失败");
        }
        
        weakSelf.isRequesting = NO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.isRequesting = NO;
        
        if (fail) {
            fail([[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeConfigServer message:error.localizedDescription]);
        }
        NSLog(@"获取广告配置失败 - %@", error.localizedDescription);
    }];
}

- (void)doInitAdapter {
    NSDictionary *mediations = @{
        @"ADMOB" : @"Yodo1MasAdMobMaxAdapter",
        @"APPLOVIN" : @"Yodo1MasAppLovinMaxAdapter",
        //@"FYBER" : @"Yodo1MasFyberAdapter",
        @"IRONSOURCE" : @"Yodo1MasIronSourceMaxAdapter"//,
        //@"YANDEX" : @"Yodo1MasYandexAdapter"
    };
    
    NSDictionary *networks = @{
        //@"adcolony" : @"Yodo1MasAdColonyAdapter",
        @"admob" : @"Yodo1MasAdMobAdapter",
        @"applovin" : @"Yodo1MasAppLovinAdapter",
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
                NSLog(@"Adapter初始化成功 - %@:%@", key, value);
            } fail:^(NSString *advertCode, NSError *error) {
                NSLog(@"Adapter初始化失败 - %@:%@, %@", key, value, error.description);
            }];
        } else {
            if (o == nil) {
                NSLog(@"未集成相应Adapter -  %@", value);
            } else {
                NSLog(@"Adapter未继承Yodo1MasAdapterBase - %@", key);
            }
        }
    } else {
        NSLog(@"初始化Adapter - 未找到指定Adapter,SDK版本过低: - %@", key);
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
        NSMutableArray<Yodo1MasAdapterBase *> *adapters = [self getAdapters:config];
        _adBlock = ^(Yodo1MasAdEvent *event) {
            switch (event.code) {
                case Yodo1MasAdEventCodeOpened: {
                    [adapters removeAllObjects];
                    [self callbackWithEvent:event];
                    break;
                }
                case Yodo1MasAdEventCodeError: {
                    if (adapters.count > 0) {
                        [adapters removeObjectAtIndex:0];
                    }
                    if (adapters.count > 0) {
                        _currentAdapter = adapters.firstObject;
                        [adapters.firstObject showAd:type callback:_adBlock object:object];
                    } else {
                        _adBlock = nil;
                        [self callbackWithEvent:event];
                    }
                    break;
                }
                default: {
                    [self callbackWithEvent:event];
                    break;
                }
            }
        };
        if (adapters.count > 0) {
            _currentAdapter = adapters.firstObject;
            [adapters.firstObject showAd:type callback:_adBlock object:object];
        } else {
            Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdAdapterNull message:@"ad adapters is null"];
            Yodo1MasAdEvent *event = [[Yodo1MasAdEvent alloc] initWithCode:Yodo1MasAdEventCodeError type:type message:@"" error:error];
            [self callbackWithEvent:event];
        }
    } else {
        Yodo1MasError *error = [[Yodo1MasError alloc] initWitCode:Yodo1MasErrorCodeAdConfigNull message:@"ad config is null"];
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
- (BOOL)isBannerAdLoaded {
    return [self isAdvertLoaded:self.masNetworkConfig.banner type:Yodo1MasAdTypeBanner];
}

- (void)loadBannerAdvert {
    [self loadAdvert:self.masNetworkConfig.banner type:Yodo1MasAdTypeBanner];
}

- (void)showBannerAd {
    [self showBannerAdWithPlacement:nil align:Yodo1MasAdBannerAlignBottom | Yodo1MasAdBannerAlignHorizontalCenter offset:CGPointZero];
}

- (void)showBannerAdWithPlacement:(NSString *)placement {
    [self showBannerAdWithPlacement:placement align:Yodo1MasAdBannerAlignBottom | Yodo1MasAdBannerAlignHorizontalCenter offset:CGPointZero];
}

- (void)showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align {
    [self showBannerAdWithPlacement:nil align:align offset:CGPointZero];
}

- (void)showBannerAdWithAlign:(Yodo1MasAdBannerAlign)align offset:(CGPoint)offset {
    [self showBannerAdWithPlacement:nil align:align offset:offset];
}

- (void)showBannerAdWithPlacement:(NSString *)placement align:(Yodo1MasAdBannerAlign)align offset:(CGPoint)offset {
    NSMutableDictionary *object = [NSMutableDictionary dictionary];
    if (placement != nil && placement.length > 0) {
        object[kArgumentPlacement] = placement;
    }
    object[kArgumentBannerAlign] = @(align);
    object[kArgumentBannerOffset] = [NSValue valueWithCGPoint:offset];
    [self showAdvert:Yodo1MasAdTypeBanner object:object];
}

- (void)dismissBannerAd {
    if (_currentAdapter != nil) {
        [_currentAdapter dismissBannerAd];
    }
}

- (void)dismissBannerAdWithDestroy:(BOOL)destroy {
    if (_currentAdapter != nil) {
        [_currentAdapter dismissBannerAdWithDestroy:destroy];
    }
}

@end
