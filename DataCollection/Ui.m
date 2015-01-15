//
//  Uimodel.m
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "Ui.h"

  static Ui *user = nil;
@implementation Ui
+(Ui *)share
{
    if(!user)
    {
        user = [[Ui alloc]init];

        
    }

    return user;
}
+(void)clear
{
    user = nil;
}
@end
