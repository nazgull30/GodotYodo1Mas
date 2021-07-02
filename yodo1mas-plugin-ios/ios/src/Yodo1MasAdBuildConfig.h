//
//  Yodo1MasBannerConfig.h
//  Yodo1MasCore
//
//  Created by yanpeng on 2021/5/7.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasAdBuildConfig : NSObject

@property (nonatomic, assign) BOOL enableAdaptiveBanner;

+(instancetype)instance;
+(instancetype)new __attribute__((unavailable("use class method [Yodo1MasAdBuildConfig instance] instead")));
-(instancetype)init __attribute__((unavailable("use class method [Yodo1MasAdBuildConfig instance] instead")));
@end

NS_ASSUME_NONNULL_END
