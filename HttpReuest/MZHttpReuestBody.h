//
//  MZHttpReuestBody.h
//  MZGogalApp
//
//  Created by li on 16/2/25.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MZHttpReuestBody : NSObject

@property (nonatomic,copy)   NSString *sData;       //业务
@property (nonatomic,copy)   NSString *sign;        //签名

/**
 * @brief 返回body信息字典
 */
-(NSMutableDictionary *)bodyInfoDic;



@end
