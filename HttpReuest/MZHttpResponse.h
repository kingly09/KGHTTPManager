//
//  MZHttpResponse.h
//  MZGogalApp
//
//  Created by li on 16/2/26.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZHttpResponse : NSObject


@property (nonatomic,assign)   int code; //请求返回码
@property (nonatomic,copy)     NSString *msg; //请求描述
@property (nonatomic,strong)   NSDictionary *data; //业务数据

@end
