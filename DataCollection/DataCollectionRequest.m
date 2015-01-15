//
//  MBORequest.m
//  MBOHttpRequest
//
//  Created by Alan Lu on 11/18/14.
//  Copyright (c) 2014 Duobao. All rights reserved.
//

#import "DataCollectionRequest.h"
#import "Reachability.h"
#import "Network.h"
//#import <NSString+UrlEncode.h>
//#import <MobClick.h>

NSString * const MBORequestNotificationAuthFailed = @"MBORequestNotificationAuthFailed";
NSString * const MBORequestNotificationBeginRequesting = @"MBORequestNotificationBeginRequesting";
NSString * const MBORequestNotificationEndRequesting = @"MBORequestNotificationEndRequesting";
NSString * const MBORequestNotificationNoConnection = @"MBORequestNotificationNoConnection";

@implementation DataCollectionRequest

#pragma mark - NSObject
- (id)init {
    self = [super init];
    if (self) {
        notificationCenter = [NSNotificationCenter defaultCenter];
        chunkData = [NSMutableData data];
    }
    
    return self;
}
+(DataCollectionRequest *)share
{
    DataCollectionRequest *singleton = [[DataCollectionRequest alloc]init];
    return singleton;
}
-(void)addNetwork
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}
- (void)reachabilityChanged: (NSNotification*)note {
    Reachability * reach = [note object];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    switch (status) {
        case ReachableViaWiFi:
        {
            netState = NetworkWiFi;
            NSLog(@"data wifi");
            break;
        }
            
        case  ReachableViaWWAN:
        {
            netState = NetworkWWan;
            NSLog(@"data wwan");
            break;
            
        }
        default:
        {
            netState = NetworkOther;
            NSLog(@"data other");
            break;
        }
    }
    
    
}

#pragma mark - Base
- (NSError *)getURL:(NSURL *)url headers:(NSDictionary *)headers delegate:(id <MBORequestDelegate>)delegate {
    NSError * error = [self validURL:url];
    if (error) {
        return error;
    }
    
    error = [self validDelegate:delegate];
    if (error) {
        return error;
    }
    _delegate = delegate;
    
    error = [self reachableNetwork];
    if (error) {
        return error;
    }
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30];
    [request setHTTPMethod:@"GET"];
    
    // Header
    for (id key in headers) {
        [request addValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
    
    NSURLConnection * connection = [NSURLConnection connectionWithRequest:request
                                                                 delegate:self];
    [connection start];
    startDate = [NSDate date];
    [notificationCenter postNotificationName:MBORequestNotificationBeginRequesting
                                      object:nil];
    
    
    return nil;
}

- (NSError *)postURL:(NSURL *)url headers:(NSDictionary *)headers body:(NSDictionary *)body delegate:(id <MBORequestDelegate>)delegate {
    NSError * error = [self validURL:url];
    if (error) {
        return error;
    }
    
    error = [self validDelegate:delegate];
    if (error) {
        return error;
    }
    _delegate = delegate;
    
    error = [self reachableNetwork];
    if (error) {
        return error;
    }
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // Header
    for (id key in headers) {
        [request addValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
    
    // Body
    NSMutableArray * bodySlice = [NSMutableArray array];
    for (NSString * key in body) {
        id value = [body objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray * valueSlice = (NSArray *)value;
            for (NSString * value2 in valueSlice) {
                [bodySlice addObject:[NSString stringWithFormat:@"%@=%@", key, value2]];
            }
        } else {
            [bodySlice addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }
    if ([bodySlice count] > 0) {
        NSString * bodyStr = [bodySlice componentsJoinedByString:@"&"];
        [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSURLConnection * connection = [NSURLConnection connectionWithRequest:request
                                                                 delegate:self];
    [connection start];
    startDate = [NSDate date];
    [notificationCenter postNotificationName:MBORequestNotificationBeginRequesting
                                      object:nil];
    
    return nil;
}

- (NSError *)validURL:(NSURL *)url {
    NSString * const class = NSStringFromClass([self class]);
    NSDictionary * userInfo = nil;
    if (!url) {
        userInfo = [NSDictionary dictionaryWithObject:@"Empty url."
                                               forKey:@"message"];
        return [NSError errorWithDomain:class
                                   code:MBORequestErrorCodeInvalidURL
                               userInfo:userInfo];
    }
    
    if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) {
        userInfo = [NSDictionary dictionaryWithObject:@"Not a http scheme"
                                               forKey:@"message"];
        return [NSError errorWithDomain:class
                                   code:MBORequestErrorCodeNotHttpScheme
                               userInfo:userInfo];
    }
    
    return nil;
}


- (NSError *)validDelegate:(id <MBORequestDelegate>)delegate {
    if (!delegate) {
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"Empty delegate."
                                                              forKey:@"message"];
        return [NSError errorWithDomain:NSStringFromClass([self class])
                                   code:MBORequestErrorCodeEmptyDelegate
                               userInfo:userInfo];
    }
    
    return nil;
}

- (NSError *)reachableNetwork {
    if(netState == NetworkOther)
    {
        NSDictionary *userinfo = [NSDictionary dictionaryWithObject:@"No reachable networks" forKey:@"message"];
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:MBORequestErrorCodeNoConnection userInfo:userinfo];
        return error;
    }
   
    return nil;
}

- (void)ok {
    if ([_delegate respondsToSelector:@selector(MBORequest:okWithMD5:data:)]) {
        [_delegate MBORequest:self okWithMD5:md5 data:chunkData];
    }
}

- (void)notModified {
    if ([_delegate respondsToSelector:@selector(MBORequestNotModified:)]) {
        [_delegate MBORequestNotModified:self];
    }
}

- (void)failed {
    if ([_delegate respondsToSelector:@selector(MBORequest:failedWithError:statusCode:)]) {
        NSString * message = @"";
        if (chunkData) {
            NSError * error = nil;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:chunkData
                                                                  options:NSJSONReadingMutableLeaves
                                                                    error:&error];
            message = [json objectForKey:@"message"];
            if (!message) {
                message = @"";
            }
        }
        
        NSDictionary * userInfo = [NSDictionary dictionaryWithObject:message
                                                              forKey:@"message"];
        NSError * error = [NSError errorWithDomain:NSStringFromClass([self class])
                                              code:MBORequestErrorCodeFailed
                                          userInfo:userInfo];
        
        [_delegate MBORequest:self failedWithError:error statusCode:statusCode];
    }
}

- (void)authFailed {
    [notificationCenter postNotificationName:MBORequestNotificationAuthFailed
                                      object:nil];
    
    if ([_delegate respondsToSelector:@selector(MBORequestAuthFailed:)]) {
        [_delegate MBORequestAuthFailed:self];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [chunkData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    statusCode = [response statusCode];
    if (statusCode == 200) {
        md5 = [[response allHeaderFields] objectForKey:@"Content-Md5"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if([self respondsToSelector:@selector(dataCollectionSeccess:data:)])
    {
        [self.delegate dataCollectionSeccess:self data:chunkData];
    }
    [notificationCenter postNotificationName:MBORequestNotificationEndRequesting
                                      object:nil];
    
    if (statusCode == 200 || statusCode == 304) {
        [self logRequest:connection onSuccess:YES];
    } else {
        [self logRequest:connection onSuccess:NO];
    }
    
    switch (statusCode) {
        case 200:
            [self ok];
            break;
        case 304:
            [self notModified];
            break;
        case 401:
            [self authFailed];
            break;
        default:
            [self failed];
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self logRequest:connection onSuccess:NO];
    [notificationCenter postNotificationName:MBORequestNotificationEndRequesting
                                      object:nil];
    statusCode = MBORequestErrorCodeTimeout;
    [self failed];
   
}

- (void)logRequest:(NSURLConnection *)connection onSuccess:(BOOL)isSuccess {
//    NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *  dateString = [dateformatter stringFromDate:[NSDate date]];
//    
//    NSString *strUrl = [NSString stringWithFormat:@"%@", connection.originalRequest.URL];
//    NSString *methodName = [[strUrl componentsSeparatedByString:@"?"] objectAtIndex:1];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
    [Network share].time = [NSString stringWithFormat:@"%f",interval];
    
}
@end