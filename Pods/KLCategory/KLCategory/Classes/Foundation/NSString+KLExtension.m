//
//  NSString+KLExtension.m
//  KLCategory
//
//  Created by Logic on 2019/12/16.
//

#import "NSString+KLExtension.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (KLExtension)

// 正则表达式验证
- (BOOL)kl_evaluateWithRegular:(NSString *)regular
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regular];
    return [pre evaluateWithObject:self];
}

- (instancetype)kl_reverseString
{
    NSMutableString *string = [NSMutableString stringWithCapacity:self.length];
    for (NSInteger i = self.length-1; i >= 0; i--) {
        [string appendString:[self substringWithRange:NSMakeRange(i, 1)]];
    }
    return string;
}

- (instancetype)kl_chinessToPinyin
{
    // 将NSString装换成NSMutableString
    NSMutableString *pinyin = [self mutableCopy];
    // 将汉字转换为拼音(带音标)
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    // 去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    // 返回最近结果
    return pinyin;
}

- (BOOL)kl_isContainChinese
{
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}

+ (instancetype)kl_documentPathWithFileName:(NSString *)fileName
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [document stringByAppendingPathComponent:fileName];
}

+ (instancetype)kl_cachePathWithFileName:(NSString *)fileName
{
    NSString *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    return [cache stringByAppendingPathComponent:fileName];
}

+ (instancetype)kl_temptPathWithFileName:(NSString *)fileName
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

- (NSString *)kl_stringWithURLEncoding
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self kl_decodeURLEncoding],
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,/?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)kl_stringWithURLEncodingPath
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)[self kl_decodeURLEncoding],
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\();:@&=+$,?%#[] ",
                                                                                 kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSString *)kl_decodeURLEncoding
{
    NSString *result = [self stringByRemovingPercentEncoding];
    return result?result:self;
}

@end
