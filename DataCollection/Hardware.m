//
//  UserInformation.m
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "Hardware.h"

@implementation Hardware
{
    
}
+(Hardware *)share
{
    static Hardware *user = nil;
    if(!user)
    {
        user = [[Hardware alloc]init];
        
    }
    return user;
}

@end
