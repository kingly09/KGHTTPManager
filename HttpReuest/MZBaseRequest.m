//
//  MZBaseRequest.m
//  MZGogalApp
//
//  Created by li on 16/2/26.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import "MZBaseRequest.h"

static NSInteger globalRequestSeqID = 1;

@interface MZBaseRequest()

@property (nonatomic, strong)AFHTTPSessionManager *manager;
@property (nonatomic, strong)NSURLSessionTask *task;


/**
 *  成功回调
 */
@property (nonatomic, copy) RequestSuccess requestSuccess;
/**
 *  失败回调
 */
@property (nonatomic, copy) RequestFailed requestFailed;
/**
 *  请求 ID
 */
@property (nonatomic, assign) NSInteger requestSeqID;

@property (nonatomic, strong) NSMutableDictionary *paramsDic; // 提交的body参数

@end


@implementation MZBaseRequest


static MZBaseRequest *sharedBaseRequestObj = nil;
/**
 * @breif 获取实例
 */
+ (MZBaseRequest*) share
{
    @synchronized (self)
    {
        if (sharedBaseRequestObj == nil){
            sharedBaseRequestObj = [[self alloc] init];
        }
    }
    return sharedBaseRequestObj;
}


#pragma mark - Lifecycle
- (instancetype)init{
    self = [super init];
    if (self) {
        self.retryCount = 3;  //重试次数
        self.paramsDic = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 *  @brief 协议版本号，如果协议版本发生变化才改（慎重）
 **/
-(NSString *)getProtocolVersion{
    
    return @"1";
}

#pragma mark - Public
- (void)cancelAllOperations{
    [_manager.operationQueue cancelAllOperations];
}

- (void)cancel
{
    [self.task cancel];
    self.requestSuccess = nil;
    self.requestFailed = nil;
    self.task = nil;
}

/**
 * @brief 设置请求方式
 **/
- (HTTPRequestMethod )requestMethod{
    return HTTPRequestMethodPost;
}
- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}
/**
 * @brief 发起 HTTP 一个请求
 */
- (void)requestWithSuccess:(void(^)(MZHttpResponse *response,NSURLSessionTask *task))success
                   failure:(void(^)(NSError *error,NSURLSessionTask *task))failure{
    self.requestSeqID = globalRequestSeqID;
    globalRequestSeqID++;
    self.requestSuccess = success;
    self.requestFailed = failure;

    [self request];
}

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
               failure:(void(^)(NSError *error,NSURLSessionTask *task))failure{
    self.requestUrl = Url;
    self.parameters = parameters;
    self.requestSeqID = globalRequestSeqID;
    globalRequestSeqID++;
    self.requestSuccess = success;
    self.requestFailed = failure;
    
    [self request];
}


#pragma mark - Private
- (void)request{
    
    MZHttpReuestBody *reBody = [[MZHttpReuestBody alloc] init];
    reBody.sData =[_parameters jsonStringEncoded];
    
    self.paramsDic = [reBody bodyInfoDic];
    
    switch (self.requestMethod) {
        case HTTPRequestMethodGet:{
            
            //可以进行一些公共参数设置
        }
            break;
            
        case HTTPRequestMethodPost:{
            
            //可以进行一些公共参数设置
        }
            break;
    }
    
    NSLog(@" URL :%@",[self buildRequestUrl]);
    NSLog(@" parameters :%@",self.paramsDic);

    
    if (self.requestMethod==HTTPRequestMethodGet) {
        
        self.task=[self.manager GET:[self buildRequestUrl] parameters:self.paramsDic success:^(NSURLSessionDataTask *task, id responseObject){
            MZHttpResponse *response = [MZHttpResponse modelWithDictionary:responseObject];
            if(self.requestSuccess)
            {
                _requestSuccess(response,task);
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error){
            NSLog(@"Error: %@", error);
            if (self.requestFailed)
            {
                
                [self reRequestWithError:error task:task];
                
            }
            
        }];
        
    }else if (self.requestMethod==HTTPRequestMethodPost){
        
        
        if (!self.constructingBodyBlock) {
            
            self.task =
            [self.manager POST:[self buildRequestUrl] parameters:self.paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
//                NSLog(@"JSON: %@", responseObject);
                MZHttpResponse *response = [MZHttpResponse modelWithDictionary:responseObject];
                if(self.requestSuccess)
                {
                    _requestSuccess(response,task);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
                if (self.requestFailed)
                {
                    [self reRequestWithError:error task:task];
                    
                }
            }];
        }else{
            self.task =
            [self.manager POST:[self buildRequestUrl] parameters:self.paramsDic constructingBodyWithBlock:self.constructingBodyBlock success:^(NSURLSessionDataTask *task, id responseObject) {
                MZHttpResponse *response = [MZHttpResponse modelWithDictionary:responseObject];
                if(self.requestSuccess)
                {
                    _requestSuccess(response,nil);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                // NSLog(@"Error: %@", error);
                if (self.requestFailed)
                {
                    
                    [self reRequestWithError:error task:task];
                    
                }
            }];
        }
        
    }
    
}

/**
 * @brief 初始化AFHTTPSessionManager
 */
- (AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus==AFNetworkReachabilityStatusNotReachable) {
            _manager.requestSerializer.cachePolicy=NSURLRequestReturnCacheDataDontLoad;
            
        }else{
            _manager.requestSerializer.cachePolicy=NSURLRequestUseProtocolCachePolicy;
            
        }
    }
    return _manager;
}
/**
 * @brief 获取服务器的完成请求Url
 */
- (NSString *)buildRequestUrl{
    NSString *sUrl = [NSString stringWithFormat:@"%@v%@",_requestUrl,[self getProtocolVersion]];
    return sUrl;
}

/**
 *  @brief 请求失败 重试
 */
- (void)reRequestWithError:(NSError *)error task:(NSURLSessionTask *)task{
    
    if (_retryCount>0) {
        --_retryCount;
        _retryIndex++;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self request];
        });
    }else{
        _requestFailed(error,task);
    }
    
}










@end
