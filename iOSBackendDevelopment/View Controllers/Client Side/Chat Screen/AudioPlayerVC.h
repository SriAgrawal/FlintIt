//
//  AudioPlayerVC.h
//  iOSBackendDevelopment
//
//  Created by Neha Chhabra on 19/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol customAudioPlayerDelegate<NSObject>
-(void)getRecordedAudio:(NSURL*)soundFile;
@end

@interface AudioPlayerVC : UIViewController

@property (nonatomic, weak) id<customAudioPlayerDelegate> delegate;
@property (strong, nonatomic)  UIImage *bgImg;

@end