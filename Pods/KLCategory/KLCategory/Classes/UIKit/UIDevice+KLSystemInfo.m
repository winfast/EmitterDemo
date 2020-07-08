//
//  UIDevice+KLExtension.m
//  KLCategory
//
//  Created by Logic on 2019/12/14.
//

#import "UIDevice+KLSystemInfo.h"
#include <spawn.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation UIDevice (KLSystemInfo)

+ (NSString *)kl_systemVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [UIDevice currentDevice].systemVersion;

#else
    return nil;
#endif
}

+ (NSString *)kl_OSVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];

#else
    return nil;
#endif
}

+ (NSString *)kl_OSLanguage {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];

    return preferredLang;
}

+ (NSString *)kl_appDisplayName {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    static NSString *__appName = nil;

    if (nil == __appName) {
        __appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }

    return __appName;

#else
    return nil;
#endif
}

+ (NSString *)kl_appBuildVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    NSString *value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    if ((nil == value) || (0 == value.length)) {
        value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }

    return value;

#else
    return nil;
#endif
}

+ (NSString *)kl_appShortVersion {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    NSString *value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    if ((nil == value) || (0 == value.length)) {
        value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }

    return value;

#else
    return nil;
#endif
}

+ (NSString *)kl_appIdentifier {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    static NSString *__identifier = nil;

    if (nil == __identifier) {
        __identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    }

    return __identifier;

#else
    return @"";
#endif
}

+ (NSString *)kl_deviceModel {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    return [UIDevice currentDevice].model;

#else
    return nil;
#endif
}

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
static const char *__jb_app = NULL;
#endif

+ (BOOL)kl_isJailBroken NS_AVAILABLE_IOS(4_0) {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    static const char *__jb_apps[] = {
        "/Application/Cydia.app",
        "/Application/limera1n.app",
        "/Application/greenpois0n.app",
        "/Application/blackra1n.app",
        "/Application/blacksn0w.app",
        "/Application/redsn0w.app",
        NULL
    };

    __jb_app = NULL;

    // method 1
    for (int i = 0; __jb_apps[i]; ++i) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:__jb_apps[i]]]) {
            __jb_app = __jb_apps[i];
            return YES;
        }
    }

    // method 2
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"]) {
        return YES;
    }

    // method 3
    char *const args[] = {"ls", "-la", NULL};
    int err;

    err = posix_spawn(NULL, "/bin/ls", NULL, NULL, args, NULL);

    if (err != 0) {
        return YES;
    }
#endif

    return NO;
}

+ (NSString *)kl_jailBreaker NS_AVAILABLE_IOS(4_0) {
#if (TARGET_OS_IPHONE)
    if (__jb_app) {
        return [NSString stringWithUTF8String:__jb_app];
    }
#endif
    return @"";
}

+ (NSString *)kl_carrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc]init];
    CTCarrier *carrier = [info subscriberCellularProvider];

    return carrier.carrierName;
}

+ (NSString *)kl_mobileNetworkCode {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc]init];
    CTCarrier *carrier = [info subscriberCellularProvider];

    return carrier.mobileNetworkCode;
}

@end
