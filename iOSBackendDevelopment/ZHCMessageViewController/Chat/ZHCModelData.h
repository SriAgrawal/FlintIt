//
//  ZHCModelData.h
//  ZHChat
//
//  Created by aimoke on 16/8/10.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHCMessages.h"
#import "ZHCLocationMediaItem.h"
#import "MacroFile.h"
@class ZHCPhotoMediaItem;
@class RowDataModal;


//static NSString * const kZHCDemoAvatarDisplayNameCook = @"Tim Cook";
//static NSString * const kZHCDemoAvatarDisplayNameJobs = @"Jobs";

//static NSString * const kZHCDemoAvatarIdCook = @"468-768355-23123";
//static NSString * const kZHCDemoAvatarIdJobs = @"707-8956784-57";


@interface ZHCModelData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) NSMutableDictionary *users;

@property (strong, nonatomic) ZHCMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) ZHCMessagesBubbleImage *incomingBubbleImageData;



- (void)addPhotoMediaMessage:(UIImage*)image;
- (void)addLocationMediaMessageCompletion:(ZHCLocationMediaItemCompletionBlock)completion;

- (void)addLocationMediaMessageOfOtherUserWithCompletion:(ZHCLocationMediaItemCompletionBlock)completion WithInfo:(RowDataModal*)info MessageReadStatus:(NSString*)status;

- (void)addVideoMediaMessage;
- (void)addAudioMediaMessage;
- (instancetype)initWithUserInfo:(RowDataModal*)userInfo WithChatHistory:(NSMutableArray*)chatHistory;
@end
