//
//  NetworkModel.m
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "Network.h"

@implementation Network

static Network *singleton = nil;
+(Network *)share
{
   @synchronized (self)
    {
        if(!singleton)
        {
            singleton = [[Network alloc]init];
            
        }
    }
     return singleton;
}
+(void)clear
{
    singleton.time = nil;
}
@end
