//
//  ZHCModelData.m
//  ZHChat
//
//  Created by aimoke on 16/8/10.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import "ZHCModelData.h"
#import "ZHUseFDModel.h"
#import "ZHCMessagesCommonParameter.h"
#import "ZHCPhotoMediaItem.h"
#import "ZHCLocationMediaItem.h"
#import "ZHCVideoMediaItem.h"
#import "ZHCAudioMediaItem.h"
#import "ChatHistoryModel.h"


@implementation ZHCModelData{
    NSMutableDictionary *dictUserInfo;
    RowDataModal *userProfileDetail;;
}

- (instancetype)initWithUserInfo:(RowDataModal*)userInfo WithChatHistory:(NSMutableArray *)chatHistory
{
    self = [super init];
    if (self) {
        self.messages = [NSMutableArray new];
        userProfileDetail = userInfo;
        //Initializing inital chat view.
           [self initializeInitialChatView];
        //Loading user chat history.
        if (chatHistory.count) {
             [self loadUserChatHistory:chatHistory];
        }
    }
    
    return self;
}

-(void)initializeInitialChatView{
    /**
     *  Create avatar images once.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     *  If you are not using avatars, ignore this.
     */
    //Let's find current logged in user profile data.
    
    @try {
        if ([NSUSERDEFAULT boolForKey:@"isClientSide"]) {
            dictUserInfo = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ClientUserInfoDictionary"]];
        }else{
            dictUserInfo = [NSMutableDictionary dictionaryWithDictionary:[NSUSERDEFAULT valueForKey:@"ServiceUserInfoDictionary"]];
        }
        
        ZHCMessagesAvatarImageFactory *avatarFactory = [[ZHCMessagesAvatarImageFactory alloc] initWithDiameter:kZHCMessagesTableViewCellAvatarSizeDefault];
        
        
        UIImageView *imgView = [[UIImageView alloc] init];
        
        // This is used to download image if not downloaded ealier
        [imgView sd_setImageWithURL:[NSURL URLWithString:[dictUserInfo valueForKey:@"profileimage"]] placeholderImage:[UIImage imageNamed:@"user_icon"]];
        
        if ([[SDImageCache sharedImageCache] imageFromCacheForKey:userProfileDetail.userImage]) {
            NSLog(@"From Cache----Image");
        }
        else{
            
            NSLog(@"None Cache----Image");
        }
        UIImage * otherUserImg = [[SDImageCache sharedImageCache] imageFromCacheForKey:userProfileDetail.userImage] ? [[SDImageCache sharedImageCache] imageFromCacheForKey:userProfileDetail.userImage] : [UIImage imageNamed:@"user_icon"];
        
        UIImage * loginUserImg = [[SDImageCache sharedImageCache] imageFromCacheForKey:[dictUserInfo valueForKey:@"profileimage"]]?[[SDImageCache sharedImageCache] imageFromCacheForKey:[dictUserInfo valueForKey:@"profileimage"]]:[UIImage imageNamed:@"user_icon"];
        
        
        ZHCMessagesAvatarImage *otherUserImage = [avatarFactory avatarImageWithImage:otherUserImg];
        
        ZHCMessagesAvatarImage *loggedInUserImage = [avatarFactory avatarImageWithImage:loginUserImg];
        self.avatars = [NSMutableDictionary dictionary];
        self.users = [NSMutableDictionary dictionary];
        
        [self.avatars setValue:otherUserImage forKey:userProfileDetail.userID];
        [self.avatars setValue:loggedInUserImage forKey:[NSUSERDEFAULT valueForKey:@"userID"]];

        // self.avatars = @{userProfileDetail.userID : otherUserImage};
        
        [self.users setValue:[dictUserInfo valueForKey:@"username"] forKey:[NSUSERDEFAULT valueForKey:@"userID"]];
        [self.users setValue:userProfileDetail.userName forKey:userProfileDetail.userID];

//        self.avatars = @{userProfileDetail.userID : otherUserImage,[NSUSERDEFAULT valueForKey:@"userID"] : loggedInUserImage};
//        
//        
//        // self.avatars = @{userProfileDetail.userID : otherUserImage};
//        self.users = @{ [NSUSERDEFAULT valueForKey:@"userID"] : [dictUserInfo valueForKey:@"username"],
//                        userProfileDetail.userID : userProfileDetail.userName};
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        ZHCMessagesBubbleImageFactory *bubbleFactory = [[ZHCMessagesBubbleImageFactory alloc] init];
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor zhc_messagesBubbleBlueColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor zhc_messagesBubbleGreenColor]];

    } @catch (NSException *exception) {
        
        [[AlertView sharedManager] displayInformativeAlertwithTitle:@"" andMessage:[exception description] onController:[APPDELEGATE navController]];
    } @finally {
        
    }
}


-(void)loadUserChatHistory:(NSMutableArray*)chatHistory
{
    //Getting chat data one by one.
    for (ChatHistoryModel *model in chatHistory) {
        //Getting chat owner info.
        NSString *avatarId = nil;
        NSString *displayName = nil;
        if ([[model valueForKey:@"senderId"] isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]]) {
            avatarId = [NSUSERDEFAULT valueForKey:@"userID"];
            displayName = [dictUserInfo valueForKey:@"username"];
        }else{
            avatarId = userProfileDetail.userID;
            displayName = userProfileDetail.userName;
        }
        //Checking chat type and allocating chat model object.
        if ([[model valueForKey:@"messageType"]isEqualToString:@"message"]) {
            //Text
            ZHCMessage *message = [[ZHCMessage alloc]initWithSenderId:avatarId senderDisplayName:displayName date:[self convertStringToData:model.time] text:[model valueForKey:@"message"] messageReadStatus:[model valueForKey:@"flag"]];
            [self.messages addObject:message];
        }else if ([[model valueForKey:@"messageType"]isEqualToString:@"audio"]){
            //Audio
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/%@",[model valueForKey:@"fileUrl"]]];
            ZHCAudioMediaItem *audioItem = [[ZHCAudioMediaItem alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
            if ([[model valueForKey:@"senderId"] isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]]) {
                audioItem.appliesMediaViewMaskAsOutgoing = YES;
            }else{
                audioItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            ZHCMessage *audioMessage = [ZHCMessage messageWithSenderId:avatarId displayName:displayName media:audioItem readStatus:[model valueForKey:@"flag"]];
            [self.messages addObject:audioMessage];
        }else if ([[model valueForKey:@"messageType"]isEqualToString:@"media"]){
            //Media,Images
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-52-76-162-65.ap-southeast-1.compute.amazonaws.com:1415/%@",[model valueForKey:@"fileUrl"]]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            ZHCPhotoMediaItem *photoItem = [[ZHCPhotoMediaItem alloc]initWithImage:image];
            if ([[model valueForKey:@"senderId"] isEqualToString:[NSUSERDEFAULT valueForKey:@"userID"]]) {
                photoItem.appliesMediaViewMaskAsOutgoing = YES;
            }else{
                photoItem.appliesMediaViewMaskAsOutgoing = NO;
            }
            ZHCMessage *photoMessage = [ZHCMessage messageWithSenderId:avatarId displayName:displayName  media:photoItem readStatus:[model valueForKey:@"flag"]];
            [self.messages addObject:photoMessage];
        }else if ([[model valueForKey:@"messageType"]isEqualToString:@"location"]){
            //Location data
            RowDataModal *tempObj = [[RowDataModal alloc] init];
            tempObj.userLatitute = model.latitude;
            tempObj.userLongitute = model.longitude;
            tempObj.userName = displayName;
            tempObj.userID = avatarId;
            [self addLocationMediaMessageOfOtherUserWithCompletion:^{
                
            }WithInfo:tempObj MessageReadStatus:[model valueForKey:@"flag"]];
        }
    }
    
}


-(void)addPhotoMediaMessage:(UIImage*)image
{
    ZHCPhotoMediaItem *photoItem = [[ZHCPhotoMediaItem alloc]initWithImage:image];
//    photoItem.appliesMediaViewMaskAsOutgoing = NO;
    ZHCMessage *photoMessage = [ZHCMessage messageWithSenderId:[NSUSERDEFAULT valueForKey:@"userID"] displayName:[dictUserInfo valueForKey:@"username"]  media:photoItem readStatus:@"unread"];
    [self.messages addObject:photoMessage];
}

- (void)addLocationMediaMessageCompletion:(ZHCLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:[APPDELEGATE latitude].doubleValue longitude:[APPDELEGATE longitude].doubleValue];
    
    ZHCLocationMediaItem *locationItem = [[ZHCLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    locationItem.appliesMediaViewMaskAsOutgoing = YES;
    
    ZHCMessage *locationMessage = [ZHCMessage messageWithSenderId:[NSUSERDEFAULT valueForKey:@"userID"]
                                                      displayName:[dictUserInfo valueForKey:@"username"]
                                                            media:locationItem readStatus:@"unread"];
    [self.messages addObject:locationMessage];
}

- (void)addLocationMediaMessageOfOtherUserWithCompletion:(ZHCLocationMediaItemCompletionBlock)completion WithInfo:(RowDataModal*)info MessageReadStatus:(NSString*)status
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:info.userLatitute.doubleValue longitude:info.userLongitute.doubleValue];
    
    ZHCLocationMediaItem *locationItem = [[ZHCLocationMediaItem alloc] init];
    [locationItem setLocation:location withCompletionHandler:completion];
   locationItem.appliesMediaViewMaskAsOutgoing = NO;
    ZHCMessage *locationMessage = [ZHCMessage messageWithSenderId:info.userID
                                                      displayName:info.userName
          
                                                            media:locationItem readStatus:status];
   
    if (info.index) {
        [self.messages insertObject:locationMessage atIndex:info.index];
    }else
    {
        [self.messages addObject:locationMessage];
    }
}

- (void)addVideoMediaMessage
{
    // don't have a real video, just pretending
//    NSURL *videoURL = [NSURL URLWithString:@"file://"];
//    
//    ZHCVideoMediaItem *videoItem = [[ZHCVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
//    videoItem.appliesMediaViewMaskAsOutgoing = YES;
//    ZHCMessage *videoMessage = [ZHCMessage messageWithSenderId:[NSUSERDEFAULT valueForKey:@"userID"]
//                                                   displayName:[dictUserInfo valueForKey:@"username"]
//                                                         media:videoItem];
//    [self.messages addObject:videoMessage];
}

- (void)addAudioMediaMessage
{
    NSString * sample = [[NSBundle mainBundle] pathForResource:@"zhc_messages_sample" ofType:@"m4a"];
    
    NSData * audioData = [NSData dataWithContentsOfFile:sample];
    ZHCAudioMediaItem *audioItem = [[ZHCAudioMediaItem alloc] initWithData:audioData];
    audioItem.appliesMediaViewMaskAsOutgoing = NO;
    ZHCMessage *audioMessage = [ZHCMessage messageWithSenderId:userProfileDetail.userID
                                                   displayName:userProfileDetail.userName
                                                         media:audioItem readStatus:@"unread"];
    [self.messages addObject:audioMessage];
}

#pragma mark - Formatting Date

-(NSDate*)convertStringToData:(NSString *)dateStr{
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    return date;
    
}


@end
