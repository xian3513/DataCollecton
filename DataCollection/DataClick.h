//
//  DataClick.h
//  DataCollection
//
//  Created by kt on 15/1/4.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataCollectionController.h"
@interface DataClick : NSObject

+ (void)startWithAppkey:(NSString *)key reportPolicy:(NSInteger)palicy channelId:(NSString *)ID;
//+ (void)event:(NSString *)event attributes:(NSDictionary *)attribute;
+ (void)UIEvent:(NSDictionary *)parameters;
//+ (void)NetworkEvent:(NSDictionary *)parameters;
+ (void)beginLogPageView:(NSString *)pageName;// page name;
+ (void)endLogPageView:(NSString *)pageName;
@end
