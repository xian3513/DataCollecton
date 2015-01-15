//
//  Uimodel.h
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "CollectionModel.h"

@interface Ui : CollectionModel
@property(nonatomic, copy) NSString * name;
@property(nonatomic, copy) NSString * length;
@property(nonatomic, copy) NSString * enterTime;
+(Ui *)share;
+(void)clear;
@end
