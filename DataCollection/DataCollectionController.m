//
//  UserInformationController.m
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "DataCollectionController.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>


//@"i386"      on 32-bit Simulator
//@"x86_64"    on 64-bit Simulator
//@"iPod1,1"   on iPod Touch
//@"iPod2,1"   on iPod Touch Second Generation
//@"iPod3,1"   on iPod Touch Third Generation
//@"iPod4,1"   on iPod Touch Fourth Generation
//@"iPhone1,1" on iPhone
//@"iPhone1,2" on iPhone 3G
//@"iPhone2,1" on iPhone 3GS
//@"iPad1,1"   on iPad
//@"iPad2,1"   on iPad 2
//@"iPad3,1"   on 3rd Generation iPad
//@"iPhone3,1" on iPhone 4
//@"iPhone4,1" on iPhone 4S
//@"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
//@"iPhone5,2" on iPhone 5 (model A1429, everything else)
//@"iPad3,4" on 4th Generation iPad
//@"iPad2,5" on iPad Mini
//@"iPhone5,3" on iPhone 5c (model A1456, A1532 | GSM)
//@"iPhone5,4" on iPhone 5c (model A1507, A1516, A1526 (China), A1529 | Global)
//@"iPhone6,1" on iPhone 5s (model A1433, A1533 | GSM)
//@"iPhone6,2" on iPhone 5s (model A1457, A1518, A1528 (China), A1530 | Global)
//@"iPad4,1" on 5th Generation iPad (iPad Air) - Wifi
//@"iPad4,2" on 5th Generation iPad (iPad Air) - Cellular
//@"iPad4,4" on 2nd Generation iPad Mini - Wifi
//@"iPad4,5" on 2nd Generation iPad Mini - Cellular
//@"iPhone7,1" on iPhone 6 Plus
//@"iPhone7,2" on iPhone 6


@interface DataCollectionController()


@end
@implementation DataCollectionController
{
    NSArray *AttributeArray;
    NSTimer *UiTimer;
    NSTimeInterval times;
}

+(DataCollectionController *)share
{
    static DataCollectionController *singleton = nil;
    if(!singleton)
    {
        singleton = [[DataCollectionController alloc]init];
        
    }
    return singleton;
}
-(id)init
{
    if(self = [super init])
    {
        [self initUiTimer];
        [self addNetwork];
        [self addNotification];
        
        
       
    }
    return self;
}
#pragma notification
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(become:) name: UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backGround:) name:
     UIApplicationDidEnterBackgroundNotification object:nil];
   
}
-(void)become:(NSNotification *)n
{
    DataCollectionRequest *request = [DataCollectionRequest share];
   NSDictionary *dict = [self getRequestDictionaryFromCollection:[Ui share]];
    NSLog(@"dict:%@",dict);
    //request postURL:<#(NSURL *)#> headers:<#(NSDictionary *)#> body:<#(NSDictionary *)#> delegate:<#(id<MBORequestDelegate>)#>
    
}
-(void)backGround:(NSNotification *)n
{
   
}
-(void)dataCollectionSeccess:(DataCollectionRequest *)request data:(NSData *)data
{
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"result:%@",str);
}
#pragma Reachability
-(void)addNetwork
{
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}
- (void)reachabilityChanged: (NSNotification*)note {
    Reachability * reach = [note object];
    NetworkStatus status = [reach currentReachabilityStatus];
    Network *model = [Network share];
    switch (status) {
        case ReachableViaWiFi:
        {
            model.type = @"WiFi";
            NSLog(@"data wifi");
            break;
        }
            
        case  ReachableViaWWAN:
        {
            model.type = @"WWAN";
            NSLog(@"data wwan");
            break;
            
        }
        default:
        {
            model.type = @"other";
            NSLog(@"data other");
            break;
        }
    }
    
    
}
#pragma UiTimer
-(void)initUiTimer
{
    UiTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}
-(void)beginUiTimer
{
    times = 0;
    [UiTimer fire];
}
-(void)endUiTimer
{
    [UiTimer invalidate];
    
}
-(void)timerFired
{
    times++;
}

#pragma core data
-(void)insertHardware
{
    Hardware *model = [self dataOfHardware];
    [[CoreDataController share] insertDataCollectionToTable:model];
}
-(void)insertNetwork
{
    Network *model = [self dataOfNetwork];
    [[CoreDataController share] insertDataCollectionToTable:model];
    [Network clear];
}
-(void)insertUi:(NSString *)pageName state:(UiState)state
{
    Ui *model = [self dataOfUi:pageName state:state];
    [[CoreDataController share] insertDataCollectionToTable:model];
    
    if(state == UiEnd)
    {
        //request
         [Ui clear];
    }
  
}
#pragma handle data
-(Hardware *)dataOfHardware
{
    Hardware *modelHard = [Hardware share];
    modelHard.model = [self userModel];
    modelHard.osVersion = [self userOSVersion];
    modelHard.totalDiskSpace = [self userTotalDiskSpace];
    modelHard.identifierForVendor = [self userIdentifierForVendor];
    modelHard.macAddress = [self userMacAddress];
   // NSLog(@"modle:%@,osVersion:%@,space:%@,identifier:%@,mac:%@",modelHard.model,modelHard.osVersion,modelHard.totalDiskSpace,modelHard.identifierForVendor,modelHard.macAddress);
    return modelHard;
}
-(Network *)dataOfNetwork
{
    Network *model = [Network share];
    return model;
}
-(Ui *)dataOfUi:(NSString *)pageName state:(UiState)state
{
    Ui *model = [Ui share];
    switch (state) {
        case UiBegin:
        {
            NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *  dateString = [dateformatter stringFromDate:[NSDate date]];
            [self beginUiTimer];
            model.name = pageName;
            model.enterTime = dateString;
            break;
        }
        case UiEnd:
        {
            [self endUiTimer];
            model.length = [NSString stringWithFormat:@"%f",times];
           
            break;
        }
    }
    return model;
}
#pragma get json
-(NSString *)getJSON:(CollectionModel *)model
{
    AttributeArray = [self filterPropertys:[model class]];
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc]initWithCapacity:0];
    for(NSString *name in AttributeArray)
    {
        if([model valueForKey:name] == nil)
        {
            [model setValue:@"" forKey:name];
        }
        [userDict setObject:[model valueForKey:name] forKey:name];
    }
     NSError *error;
    if ([NSJSONSerialization isValidJSONObject:userDict])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json:%@",json);
        return json;
    }
    else
    {
        NSLog(@"error:%@",error);
    }
    return nil;
}
-(NSDictionary *)getRequestDictionaryFromCollection:(CollectionModel *)model
{
    NSMutableArray *marr = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *arr = [[CoreDataController share] RequestFromTable:model];
    for(CollectionModel *temp in arr)
    {
       [marr addObject:[self getJSON:temp]];
    }
    
    NSDictionary *dict = @{@"id":@"",@"context":marr};//
    return dict;
}
#pragma get Hardware
-(NSString*)userModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
   
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}
-(NSString *)userOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}
//-(NSString *)userResolution
//{
//    CGRect rect_screen = [[UIScreen mainScreen]bounds];
//    CGSize size_screen = rect_screen.size;
//    CGFloat scale_screen = [UIScreen mainScreen].scale;
//    return [NSString stringWithFormat:@"%0fx%0f",size_screen.width*scale_screen,size_screen.height*scale_screen];
//}
-(NSString *)userTotalDiskSpace
{
    UIDevice *device = [[UIDevice alloc]init];
    return [NSString stringWithFormat:@"%@",[device totalDiskSpace]];//字节
}
-(NSString *)userIdentifierForVendor
{
     return  [NSString stringWithFormat:@"%@",[[UIDevice currentDevice]identifierForVendor]];
}
- (NSString *)userMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
   // NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}
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
