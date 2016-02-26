//
//  MZKeyChainHelper.h
//  MZGogalApp
//
//  Created by li on 16/2/25.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKeyChainHelper : NSObject

/**
 * @brief  保存Content到kechain中
 */
+ (void) saveContent:(NSString*)content
      contentService:(NSString*)contentService;

/**
 * @brief 根据contentService 从kechain中获取内容
 */
+ (NSString*) getContentWithService:(NSString*)contentService;

@end
