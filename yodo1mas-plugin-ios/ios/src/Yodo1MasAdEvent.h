//
//  Yodo1MasAdEvent.h
//  AFNetworking
//
//  Created by ZhouYuzhen on 2020/12/16.
//

#import <Foundation/Foundation.h>
#import "Yodo1MasError.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1MasAdEvent : NSObject

@property (nonatomic, assign, readonly) Yodo1MasAdEventCode code;
@property (nonatomic, copy, readonly) NSString * _Nullable message;
@property (nonatomic, assign, readonly) Yodo1MasAdType type;
@property (nonatomic, strong, readonly) Yodo1MasError * _Nullable error;

- (instancetype)initWithCode:(Yodo1MasAdEventCode)code type:(Yodo1MasAdType)type;
- (instancetype)initWithCode:(Yodo1MasAdEventCode)code type:(Yodo1MasAdType)type error:(Yodo1MasError * _Nullable)error;
- (instancetype)initWithCode:(Yodo1MasAdEventCode)code type:(Yodo1MasAdType)type message:(NSString * _Nullable)message error:(Yodo1MasError * _Nullable)error;

- (NSDictionary *)getJsonObject;

@end

NS_ASSUME_NONNULL_END
