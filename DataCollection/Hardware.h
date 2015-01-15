//
//  UserInformation.h
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "CollectionModel.h"

@interface Hardware : CollectionModel
//Hardware
@property(nonatomic, copy) NSString * identifierForVendor;
@property(nonatomic, copy) NSString * macAddress;
@property(nonatomic, copy) NSString * osVersion;
@property(nonatomic, copy) NSString * totalDiskSpace;
@property(nonatomic, copy) NSString * model;

+(Hardware *)share;

@end
