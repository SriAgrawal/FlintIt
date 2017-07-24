//
//  SocialHelper.h
//  Mit Up App
//
//  Created by Mahak  Mittal on 15/04/16.
//  Copyright (c) 2014 Mobiloitte Technologies. All rights reserved.
//ht (c) 2014 Mobiloitte Technologies. All rights reserved.
//

#import "MacroFile.h"
#import "HeaderFile.h"
#import <Social/Social.h>
@class Reachability;

typedef void (^socialCompletionBlock)(NSDictionary* dict, NSString* error);

@interface SocialHelper : NSObject

+(SocialHelper*)sharedManager;

@property (strong, nonatomic) socialCompletionBlock completionBlock;

// facebook methods
-(void)getFacebookInfoWithCompletionHandler:(socialCompletionBlock)handler;

-(void)getAlbumInfoWithCompletionHandler:(socialCompletionBlock)handler;

@end
