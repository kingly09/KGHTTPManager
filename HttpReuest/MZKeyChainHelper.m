//
//  MZKeyChainHelper.m
//  MZGogalApp
//
//  Created by li on 16/2/25.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import "MZKeyChainHelper.h"

@implementation MZKeyChainHelper


+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}


/**
 * @brief 保存Content到kechain中
 */
+ (void) saveContent:(NSString*)content
      contentService:(NSString*)contentService
{
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:contentService];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:content] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}


/**
 * @brief 根据contentService 从kechain中获取内容
 */
+ (NSString*) getContentWithService:(NSString*)contentService
{
    NSString* ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery:contentService];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
    {
        @try
        {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e)
        {
            NSLog(@"Unarchive of %@ failed: %@", contentService, e);
        }
        @finally
        {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}



@end
