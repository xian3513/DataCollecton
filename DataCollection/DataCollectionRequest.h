//
//  MBORequest.h
//  MBOHttpRequest
//
//  Created by Alan Lu on 11/18/14.
//  Copyright (c) 2014 Duobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBORequestDelegate;
typedef enum {
    NetworkWiFi = 0,
    NetworkWWan,
    NetworkOther
} NetStatus;
@interface DataCollectionRequest : NSObject <NSURLConnectionDataDelegate> {
    id <MBORequestDelegate> _delegate;
    
    NSMutableData * chunkData;
    NSInteger statusCode;
    NSString * md5;
    NSNotificationCenter * notificationCenter;
    NSDate *startDate;
    NetStatus netState;
}
@property id <MBORequestDelegate> delegate;
+ (DataCollectionRequest *)share;
- (NSError *)getURL:(NSURL *)url headers:(NSDictionary *)headers delegate:(id <MBORequestDelegate>)delegate;
- (NSError *)postURL:(NSURL *)url headers:(NSDictionary *)headers body:(NSDictionary *)body delegate:(id <MBORequestDelegate>)delegate;

FOUNDATION_EXPORT NSString * const MBORequestNotificationAuthFailed;
FOUNDATION_EXPORT NSString * const MBORequestNotificationBeginRequesting;
FOUNDATION_EXPORT NSString * const MBORequestNotificationEndRequesting;
FOUNDATION_EXPORT NSString * const MBORequestNotificationNoConnection;
@end

@protocol MBORequestDelegate <NSObject>
- (void)dataCollectionSeccess:(DataCollectionRequest *)request data:(NSData *)data;
- (void)MBORequest:(DataCollectionRequest *)request okWithMD5:(NSString * const)md5 data:(NSData *)data;
- (void)MBORequest:(DataCollectionRequest *)request failedWithError:(NSError *)error statusCode:(const NSInteger)statusCode;

@optional
- (void)MBORequestAuthFailed:(DataCollectionRequest *)request;
- (void)MBORequestNotModified:(DataCollectionRequest *)request;
- (void)MBORequestLostConnection:(DataCollectionRequest *)request;
- (void)MBORequestTimeout:(DataCollectionRequest *)request;
@end

typedef enum : NSUInteger {
    MBORequestErrorCodeInvalidURL = 0,
    MBORequestErrorCodeNoConnection,
    MBORequestErrorCodeEmptyDelegate,
    MBORequestErrorCodeNotHttpScheme,
    MBORequestErrorCodeFailed,
    MBORequestErrorCodeTimeout,
} MBORequestErrorCode;