//
//  MZHttpReuestBody.m
//  MZGogalApp
//
//  Created by li on 16/2/25.
//  Copyright © 2016年 美知互动科技. All rights reserved.
//

#import "MZHttpReuestBody.h"
#import "MZKeyChainHelper.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NSObject+YYAdd.h"
#import "MZUserHandle.h"
/**
 http的body参数
 
 deviceId（设备ID，用于统计终端量）
 platform(android，iOS)
 clientVer(版本名）
 osVer(操作系统版本）
 userToken（登录态，没有登录时没有）
 sign(签名，没有登录时没有，按照字符串顺序排序 ，签名所有参数）
 networkType（网络类型：wifi，2G，3G，4G）
 channel（渠道号）
 buildId（构建号）
 data (业务数据，JSON格式)
 
 sign=sha1(userSecret+sort(deviceId=x&platform=x&clientVer=x&osVer=x&userToken=x&networkType=x&channel=x&buildId=x&data=x))
 sign参数拼接时不需要=和&
 
 **/

@interface MZHttpReuestBody ()

@property (nonatomic,copy)   NSString *sDeviceId;    //设备ID，用于统计终端量
@property (nonatomic,copy)   NSString *sPlatform;    //软件平台 android、iOS、web
@property (nonatomic,copy)   NSString *sClientVer;   //客户端版本号
@property (nonatomic,copy)   NSString *sOsVer;       //操作系统版本
@property (nonatomic,copy)   NSString *sUserToken;   //登录态
@property (nonatomic,copy)   NSString *sNetworkType;//网络类型
@property (nonatomic,copy)   NSString *sChannel;    //渠道号
@property (nonatomic,copy)   NSString *sBuildId;    //构建号


@end

@implementation MZHttpReuestBody


-(instancetype)init
{
    if (self = [super init]) {
        [self setClienInfo];
    }
    return self;
}


/**
 * 登录态
 */
-(NSString *)getUserToken{
    self.sUserToken = @"ddd";
    return self.sUserToken;
}

-(NSString *)getNetworkType{
    
    self.sNetworkType = [MZCommon getNetWorkStates];
    
    return self.sNetworkType;
}

/**
 * @brief 初始化相关信息
 */
-(void)setClienInfo
{
    
    self.sDeviceId  = [self getUUIDString];
    self.sClientVer = [MZCommon clientVersion];
    

    if (kIsSimulator) {
        self.sPlatform = @"IOS Simulator";
        self.sOsVer    = @"8.3";
    }else{

        self.sPlatform = [MZCommon platformName];
        self.sOsVer = [[UIDevice currentDevice] systemVersion];
    }
    
    self.sUserToken = [self getUserToken];
    self.sNetworkType = [self getNetworkType];
    
    self.sChannel   = @"App store";
    self.sBuildId   = [MZCommon buildVersion];

}

-(NSMutableDictionary *)bodyInfoDic
{
    NSMutableDictionary *clientInfoDic = [NSMutableDictionary dictionary];
    [clientInfoDic setObject:self.sDeviceId forKey:@"deviceId"];
    [clientInfoDic setObject:self.sPlatform forKey:@"platform"];
    [clientInfoDic setObject:self.sClientVer forKey:@"clientVer"];
    [clientInfoDic setObject:self.sOsVer forKey:@"osVer"];
    if ([[MZUserHandle sharedInstance] isUserLogin] == YES) {
        [clientInfoDic setObject:self.sUserToken forKey:@"userToken"];
        [clientInfoDic setObject:_sign forKey:@"sign"];
    }
    [clientInfoDic setObject:self.sNetworkType forKey:@"networkType"];
    [clientInfoDic setObject:self.sChannel forKey:@"channel"];
    [clientInfoDic setObject:self.sBuildId forKey:@"buildId"];

    [clientInfoDic setObject:self.sData forKey:@"data"];

    return clientInfoDic;
}


/**
 * @brief 获取设备唯一标示符：UUID
 * C178E9D0-EA7C-425F-A08A-0619A3774890
 */
-(NSString *)getUUIDString
{
    NSString *uuidString;//设备唯一标示符UUID
    
    uuidString = [MZKeyChainHelper getContentWithService:k_UUID_nameServer];
    if (uuidString.length == 0){
        uuidString = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [MZKeyChainHelper saveContent:uuidString contentService:k_UUID_nameServer];
    }
    return uuidString;
}






@end
