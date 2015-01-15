//
//  UserInformationController.h
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataCollectionRequest.h"
#import "CoreDataController.h"
#import "UIDevice-Hardware.h"
#import "Reachability.h"
#import "Hardware.h"
#import "Network.h"
#import "Ui.h"
typedef enum {
    UiBegin =0,
    UiEnd
} UiState;
@interface DataCollectionController : NSObject<MBORequestDelegate>
+(DataCollectionController *)share;
-(NSString *)getJSON:(CollectionModel *)model;
-(void)insertHardware;
-(void)insertNetwork;
-(void)insertUi:(NSString *)pageName state:(UiState)state;



@end
