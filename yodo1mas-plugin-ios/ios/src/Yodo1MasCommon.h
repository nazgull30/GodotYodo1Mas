//
//  Yodo1MasCommon.h
//  Pods
//
//  Created by ZhouYuzhen on 2020/12/17.
//

#ifndef Yodo1MasCommon_h
#define Yodo1MasCommon_h

typedef enum {
    Yodo1MasAdTypeReward = 1,
    Yodo1MasAdTypeInterstitial = 2,
    Yodo1MasAdTypeBanner = 3
} Yodo1MasAdType;

typedef enum {
    Yodo1MasAdEventCodeError = -1,
    Yodo1MasAdEventCodeOpened = 1001,
    Yodo1MasAdEventCodeClosed = 1002,
    Yodo1MasAdEventCodeRewardEarned = 2001
} Yodo1MasAdEventCode;

typedef enum {
    Yodo1MasErrorCodeUnknown = -1,
    Yodo1MasErrorCodeConfigGet = -1000,
    Yodo1MasErrorCodeConfigNetwork = -1001,
    Yodo1MasErrorCodeConfigServer = -1002,
    Yodo1MasErrorCodeAdConfigNull = -2001, // ad adapter is null
    Yodo1MasErrorCodeAdAdapterNull = -2002, // ad adapter is null
    Yodo1MasErrorCodeAdUninitialized = -2003, // ad adapter uninitialized
    Yodo1MasErrorCodeAdNoLoaded = -2004, // ad no loaded
    Yodo1MasErrorCodeAdLoadFail = -2005, // ad load error
    Yodo1MasErrorCodeAdShowFail = -2006
} Yodo1MasErrorCode;

typedef enum {
    Yodo1MasAdBannerAlignLeft = 1,
    Yodo1MasAdBannerAlignHorizontalCenter = 1 << 1,
    Yodo1MasAdBannerAlignRight = 1 << 2,
    Yodo1MasAdBannerAlignTop = 1 << 3,
    Yodo1MasAdBannerAlignVerticalCenter = 1 << 4,
    Yodo1MasAdBannerAlignBottom = 1 << 5
} Yodo1MasAdBannerAlign;

#endif /* Yodo1MasCommon_h */
