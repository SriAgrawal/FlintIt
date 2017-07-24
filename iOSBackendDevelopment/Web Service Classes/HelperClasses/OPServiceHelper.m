//
//  OPServiceHelper.m
//  Openia
//
//  Created by Sunil Verma on 25/03/16.
//  Copyright © 2016 Mobiloitte Inc. All rights reserved.
//

#import "OPServiceHelper.h"
#import "HeaderFile.h"


#import<CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>





static NSString *BASE_URL_PHP =  @"http://ec2-52-1-133-240.compute-1.amazonaws.com/PROJECTS/IosBackendDevlopment/trunk/index.php/api/";

static NSString *SERVICE_BASE_URL_MONGODATABASE      =  @"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/";


@interface OPServiceHelper()<NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    NSUInteger responseCode;
    NSURLSession *getRequestSession;
    NSURLSession *postRequestSession;
    
    
}
@property (nonatomic, strong)     NSURLConnection *connection;
@property (nonatomic, strong)    NSMutableData		   *downLoadedData;

@end

static OPServiceHelper *serviceHelper = nil;

@implementation OPServiceHelper



+(id)sharedServiceHelper
{
    
    if (!serviceHelper) {
        
        serviceHelper = [[OPServiceHelper alloc] init];
    }
    
    return serviceHelper;
}


-(void)cancelGetRequestSession
{
    [getRequestSession invalidateAndCancel];
}

-(void)cancelPostRequestSession
{
    [postRequestSession invalidateAndCancel];
}

-(NSString *)getAuthHeader
{
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", @"iosback", @"@ios123#back"] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    
    return [NSString stringWithFormat:@"Basic %@", base64AuthCredentials];
}

-(NSString *)getCountryDialingCode
{
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"DiallingCodes" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = info.subscriberCellularProvider;
    
    NSString *code =[dict objectForKey:carrier.isoCountryCode];
    
    return code.length> 0? code:@"91";
}


-(NSString *)getBaseURL:(NSString *)apiName
{
    if ([apiName containsString:@"blockeduserlist"] || [apiName containsString:@"chatUserList"] || [apiName containsString:@"deleteChat"] || [apiName containsString:@"blockuser"] || [apiName containsString:@"chatHistory"] || [apiName containsString:@"lastSeen"] || [apiName containsString:@"unblockuser"] || [apiName containsString:@"updatePushStatus"] || [apiName containsString:@"unreadMessage"] || [apiName containsString:@"registerDevice"] || [apiName containsString:@"removeToken"]) {
        
        return  SERVICE_BASE_URL_MONGODATABASE;
    }else
    {
        return BASE_URL_PHP;
    }
}

-(void)GetAPICallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName   WithComptionBlock:(RequestComplitopnBlock)block
{
    
    RequestComplitopnBlock completionBlock = [block copy];
    
    if(![APPDELEGATE isReachable])
    {
        //  [OPRequestTimeOutView showWithMessage:NO_INTERNATE_CONNECTION forTime:3.0];
        
        // completionBlock(nil, cached, [NSError errorWithDomain:@"com.thirtysix" code:100 userInfo:nil]);
        
        
        return;
    }
    
    
    NSMutableString *urlString = [NSMutableString stringWithString:[self getBaseURL:apiName]];
    
    [urlString appendFormat:@"%@",apiName];
    
    BOOL isFirst = YES;
    
    for (NSString *key in [parameterDict allKeys]) {
        
        id object = parameterDict[key];
        if ([object isKindOfClass:[NSArray class]]) {
            
            for (id eachObject in object) {
                [urlString appendString: [NSString stringWithFormat:@"%@%@=%@", isFirst ? @"?": @"&", key, eachObject]];
                isFirst = NO;
            }
        }
        else{
            [urlString appendString: [NSString stringWithFormat:@"%@%@=%@", isFirst ? @"?": @"&", key, parameterDict[key]]];
        }
        
        isFirst = NO;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //   [request setValue:[self getAuthHeader] forHTTPHeaderField:@"Authorization"];
    
    
    NSLog(@"Request URL :%@   Params:  %@",urlString,parameterDict);
    
    if (!getRequestSession) {
        NSURLSessionConfiguration *sessionConfig =  [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setTimeoutIntervalForRequest:20.0];
        
        getRequestSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }
    
    [[getRequestSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            // success response
            id result = [NSDictionary dictionaryWithContentsOfJSONURLData:data];
            NSLogInfo(@"Response:  %@",result);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result, error);
                
            });
            
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(data, error);
                
            });        }
    }] resume];
    
}

-(void)PostAPICallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName    WithComptionBlock:(RequestComplitopnBlock)block
{
    
    // for php
    RequestComplitopnBlock completionBlock = [block copy];
    
    if(![APPDELEGATE isReachable])
    {
        
        //    [OPRequestTimeOutView showWithMessage:NO_INTERNATE_CONNECTION forTime:3.0];
        //    completionBlock(nil, cached, [NSError errorWithDomain:@"com.thirtysix" code:100 userInfo:nil]);
        
        return;
    }
    
    [parameterDict setValue:[AppUtilityFile getTimeZone] forKey:@"time_zone"];

    NSMutableString *urlString = [NSMutableString stringWithString:[self getBaseURL:apiName]];
    
    [urlString appendFormat:@"%@",apiName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[self getAuthHeader] forHTTPHeaderField:@"Authorization"];

    NSLogInfo(@"Request URL :%@   Params:  %@",urlString,[[NSString alloc] initWithData:[parameterDict toJSON] encoding:NSUTF8StringEncoding]);
    
    
//    if ([apiName isEqualToString:@"login"] || [apiName isEqualToString:@"signUp"]) {
//        
//    }else
//    {
//        [parameterDict setObject:[NSUSERDEFAULT objectForKey:pUserID] forKey:pUserID];
//    }
    
    
    [request setHTTPBody:[parameterDict toJSON]];
    
    ;
    
    //  NSLogInfo(@">>>>>111>  %@",sessionConfig.identifier);
    
    if (!postRequestSession) {
        NSURLSessionConfiguration *sessionConfig =  [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setTimeoutIntervalForRequest:30.0];
        postRequestSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
    }
    
    
    [[postRequestSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            // success response
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
               NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            id result = [NSDictionary dictionaryWithContentsOfJSONURLData:data];
            
            NSLogInfo(@" error : %@   Code: %ld  ResponseStr......   %@    ...  %@  ",error,(long)[res statusCode],result,responseStr);

            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([[result objectForKeyNotNull:pResponseCode expectedObj:@"0"] intValue] == 200) {
                    completionBlock(result, error);
                }else if([[result objectForKeyNotNull:pResponseCode expectedObj:@"0"] intValue] == 401 || [[result objectForKeyNotNull:pResponseCode expectedObj:@"0"] intValue] == 404)
                {

                    [APPDELEGATE navigateToLoginWhenSessionOut:[result objectForKeyNotNull:pResponseMsg expectedObj:@""]];

                }else if([[result objectForKeyNotNull:pResponseCode expectedObj:@"0"] intValue] == 402){
                    NSLog(@"%@",apiName);
                    
//                    [[AlertView sharedManager] displayInformativeAlertwithTitle:@"api name" andMessage:[NSString stringWithFormat:@"%@",apiName] onController:[APPDELEGATE navController]];
                    [APPDELEGATE navigateToLoginWhenSessionOutDevice:[result objectForKeyNotNull:pResponseMsg expectedObj:@""]];
 
                }
                else {
                    completionBlock(result, [NSError errorWithDomain:@"com.mobiloitte" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[result objectForKeyNotNull:pResponseMsg expectedObj:@"0"],NSLocalizedDescriptionKey, nil]]);
 
                }

            });
            
        }else{
            NSLogInfo(@"Error %@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(data, error);
                
            });
        }
    }] resume];
    
}

-(void)multipartApiCallWithParameter:(NSMutableDictionary *)parameterDict apiName:(NSString *)apiName  WithComptionBlock:(RequestComplitopnBlock)block
{
    [parameterDict setValue:[AppUtilityFile getTimeZone] forKey:@"time_zone"];

    NSMutableString *urlString = [NSMutableString stringWithString:[self getBaseURL:apiName]];
    
    [urlString appendFormat:@"%@",apiName];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[self getAuthHeader] forHTTPHeaderField:@"Authorization"];

    NSLog(@"URL   %@    %@",urlString, parameterDict);
  
    
    NSString *boundary = @"14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    
    [parameterDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[NSData class]]) {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            // NSString *fileName = [NSString stringWithFormat:@"%@.%@",[parameterDict objectForKey:pLocalMessageID],[parameterDict objectForKey:pMessageMediaExt]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\"\r\n",key,@"file.png"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:obj];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        }else
        {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",obj] dataUsingEncoding:NSUTF8StringEncoding]];
 
        }
        
    }];
    

    
    [request setHTTPBody:body];
    
  
    RequestComplitopnBlock completionBlock = [block copy];
    
    if(![APPDELEGATE isReachable])
    {
        
        // [OPRequestTimeOutView showWithMessage:NO_INTERNATE_CONNECTION forTime:3.0];
        block(nil,  [NSError errorWithDomain:@"com.thirtysix" code:100 userInfo:nil]);
        
        return;
    }
    
   
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
                                                   };
    
  
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        

        if (!error) {
            // success response
            
            NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
            
            //  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            id result = [NSDictionary dictionaryWithContentsOfJSONURLData:data];
            
            NSLogInfo(@" error : %@   Code: %ld  ResponseStr......   %@     ",error,(long)[res statusCode],result);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result, error);
                
            });
            
            
        }
    }];
    [uploadTask resume];
    

    
}



-(NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    //    const char swf[3] = {'F', 'W', 'S'};
    //    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};
    
    
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }
    
    return @"application/octet-stream"; // default type
    
}




#pragma mark NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error
{
    NSLogInfo(@"");
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    NSLogInfo(@"");
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLogInfo(@"");
    
}


#pragma mark NSURLSessionTaskDelegate


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    NSLogInfo(@"");
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    NSLogInfo(@"");
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * __nullable bodyStream))completionHandler
{
    NSLogInfo(@"");
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLogInfo(@"");
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLogInfo(@"");
    
}





@end
