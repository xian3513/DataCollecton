//
//  NetworkModel.h
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "CollectionModel.h"

@interface Network : CollectionModel
@property(nonatomic, copy) NSString * type;
@property(nonatomic, copy) NSString * target;
@property(nonatomic, copy) NSString * time;
+(Network *)share;
+(void)clear;
@end
