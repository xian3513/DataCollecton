//
//  CoreDataController.h
//  DataCollection
//
//  Created by kt on 15/1/3.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Hardware.h"
#import "Network.h"
#import "Ui.h"
#import <objc/runtime.h>

@interface CoreDataController : NSObject
+(CoreDataController *)share;
-(NSArray *)readDataCollectionFromTable:(CollectionModel *)model;
-(BOOL)insertDataCollectionToTable:(CollectionModel *)model;
-(BOOL)deleteFromTable:(CollectionModel *)model;

-(NSArray *)RequestFromTable:(CollectionModel *)model;
@end
