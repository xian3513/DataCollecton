//
//  CoreDataController.m
//  DataCollection
//
//  Created by kt on 15/1/3.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "CoreDataController.h"

@implementation CoreDataController
{
    NSManagedObjectContext *context;
    Hardware *modelHard;
    Network *modelNet;
    Ui *modelUi;
    NSArray *AttributeArray;
}
+(CoreDataController *)share
{
    static CoreDataController *singleton = nil;
    if(!singleton)
    {
        singleton = [[CoreDataController alloc]init];
    }
    return singleton;
}

-(id)init
{
    if(self = [super init])
    {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        context = app.managedObjectContext;
        modelHard = [Hardware share];
        modelNet = [Network share];
        modelUi = [Ui share];
        
        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Hardware"];
//        NSArray *array =  [context executeFetchRequest:request error:nil];
//        for(NSManagedObject *object in array)
//        {
//            NSLog(@"model:%@",[object valueForKey:@"model"]);
//            
//        }
    }
    return self;
}
-(NSArray *)readDataCollectionFromTable:(CollectionModel *)model
{
    
    AttributeArray = [self filterPropertys:[model class]];
    NSString *tableName = NSStringFromClass([model class]);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:tableName];
    NSArray *array =  [context executeFetchRequest:request error:nil];
    
    //..................测试数据............................................
    NSInteger i = 0;
    for(NSManagedObject *object in array)
    {
        i++;
        for(NSString *name in AttributeArray)
        {
            
                 NSLog(@"%ld,%@:%@",(long)i,name,[object valueForKey:name]);
            
           
        }
        
    }
    NSLog(@"............");
    //..................................................................
    return array;
    
}
-(NSArray *)RequestFromTable:(CollectionModel *)model
{
//    id obj = nil;
//    if([[model class]isSubclassOfClass:[Hardware class]])
//    {
//        obj = (Hardware *)model;
//    }
//    else if ([[model class]isSubclassOfClass:[Network class]])
//    {
//        obj = (Network *)model;
//    }
//    else
//    {
//        obj = (Ui *)model;
//    }
     AttributeArray = [self filterPropertys:[model class]];
    NSMutableArray *marr = [[NSMutableArray alloc]initWithCapacity:0];
    NSArray *array = [self readDataCollectionFromTable:model];
    for(NSManagedObject *object in array)
    {
        CollectionModel *temp = [[[model class] alloc]init];
        for(NSString *name in AttributeArray)
        {
            [temp setValue:[object valueForKey:name] forKey:name] ;
        }
        [marr addObject:temp];
        
    }
    return marr;
}
-(BOOL)deleteFromTable:(CollectionModel *)model
{
    
    NSArray *array = [self readDataCollectionFromTable:model];
    for(NSManagedObject *object in array)
    {
        [context deleteObject:object];
        [context save:nil];
    }
    return YES;
}
//-(BOOL)insertDataCollectionToUiModel:(UiModel *)model state:(UiState)state
//{
//    switch (state) {
//        case UiBegin:
//        {
//            AttributeArray = [self filterPropertys:[model class]];
//            NSString *tableName = NSStringFromClass([model class]);
//            
//            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
//             break;
//        }
//           
//        case UiEnd:
//        {
//            break;
//        }
//       
//    }
//    return YES;
//}
-(BOOL)insertDataCollectionToTable:(CollectionModel *)model
{
    AttributeArray = [self filterPropertys:[model class]];

    NSString *tableName = NSStringFromClass([model class]);
//    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
    for(NSString *name in AttributeArray)
    {
       
        if([model valueForKey:name] != nil)
        {
           [object setValue:[model valueForKey:name] forKey:name];
        }
        
    }
//..................测试 删除data....................................
   if([context save:nil])
   {
       //[self deleteFromTable:model];
   }
//......................................................
    return YES;
}
//-(BOOL)insertDataCollectionToTable:(CollectionModel *)model attribute:(NSString *)attribute
//{
//    AttributeArray = [self filterPropertys:[model class]];
//    
//    BOOL isAttribute = NO;
//    for(NSString *name in AttributeArray)
//    {
//        if([name isEqualToString:attribute])
//        {
//            isAttribute = YES;
//            break;
//        }
//    }
//    if(isAttribute)
//    {
//        NSString *tableName = NSStringFromClass([model class]);
//        NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
//        [object setValue:[model valueForKey:attribute] forKey:attribute];
//    }
//    return isAttribute;
//}
- (NSArray *)filterPropertys:(Class)class
{
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i<outCount; i++)
    {
        
        const char* char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
       
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}
@end
