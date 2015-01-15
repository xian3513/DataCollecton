//
//  DataClick.m
//  DataCollection
//
//  Created by kt on 15/1/4.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "DataClick.h"

typedef enum {
    EventTypeUI = 0,
    EventTypeNetwork
}EventType;

@implementation DataClick

+ (void)startWithAppkey:(NSString *)key reportPolicy:(NSInteger)palicy channelId:(NSString *)ID
{
    [[DataCollectionController share] insertHardware];
}
+ (void)beginLogPageView:(NSString *)pageName
{
    [[DataCollectionController share] insertUi:pageName state:UiBegin];
}
+ (void)endLogPageView:(NSString *)pageName
{
     [[DataCollectionController share] insertUi:pageName state:UiEnd];
}
+ (void)UIEvent:(NSDictionary *)parameters
{
    [[DataCollectionController share] insertNetwork];
}
+ (void)eventType:(EventType)type parameters:(NSDictionary *)paramters {

}
+ (void)event:(NSString *)event attributes:(NSDictionary *)attribute
{
    
}
@end
