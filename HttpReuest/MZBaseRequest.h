//
//  MZBaseRequest.h
//  MZGogalApp
//
//  Created by li on 16/2/26.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>
#import <YYKit/NSObject+YYModel.h>
#import <YYKit/NSDictionary+YYAdd.h>
#import <YYKit/NSString+YYAdd.h>
#import "MZHttpReuestBody.h"
#import "MZHttpResponse.h"


typedef NS_ENUM(NSUInteger,HTTPRequestMethod){
    HTTPRequestMethodGet = 0,
    HTTPRequestMethodPost
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^ RequestSuccess)(MZHttpResponse *response,NSURLSessionTask *task);
typedef void (^ RequestFailed)(NSError *error,NSURLSessionTask *task);

@interface MZBaseRequest : NSObject

@property (nonatomic, strong) NSString     *requestUrl;     //请求的业务指令 URL
@property (nonatomic, strong) NSDictionary *parameters; //请求业务参数
@property (nonatomic, assign) NSInteger retryCount; //重试次数 默认为0
@property (nonatomic, assign) NSInteger retryIndex; // 正在重试第几次


/**
 * @breif 获取实例
 */
+ (MZBaseRequest *) share;

/**
 *  @brief 数据请求方法
 *
 *  @param success 成功的回调
 *  @param failure 错误的回调
 */
- (void)requestWithSuccess:(void(^)(MZHttpResponse *response,NSURLSessionTask *task))success
                   failure:(void(^)(NSError *error,NSURLSessionTask *task))failure;

/**
 *  @brief 数据请求方法
 *  @param Url 请求Url
 *  @param parameters 请求的参数
 *  @param success 成功的回调
 *  @param failure 错误的回调
 */
- (void)requestWithUrl:(NSString *)Url
        withParameters:(NSDictionary *)parameters
               success:(void(^)(MZHttpResponse *response,NSURLSessionTask *task))success
               failure:(void(^)(NSError *error,NSURLSessionTask *task))failure;
/**
 * @brief 请求的方式
 */
- (HTTPRequestMethod )requestMethod;
/**
 * @brief 当POST的内容带有文件时使用
 */
- (AFConstructingBlock)constructingBodyBlock;
/**
 *  cancel HTTP
 */
- (void)cancel;


@end
