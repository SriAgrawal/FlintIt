//
//  AudioPlayerVC.m
//  iOSBackendDevelopment
//
//  Created by Neha Chhabra on 19/08/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

#import "AudioPlayerVC.h"
#import <AVFoundation/AVFoundation.h>
#import "HeaderFile.h"

@interface AudioPlayerVC ()  <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    IBOutlet UIButton *deleteButton;
    IBOutlet UIButton *useButton;
    IBOutlet UIButton *recordButton;
    IBOutlet UIButton *playButton;
    IBOutlet UILabel *timerLabel;
    IBOutlet UIImageView *bgImgView;
    
    NSTimer *meterTimer;
    NSURL *soundFileUrl;
}

- (IBAction)recordButtonAction:(UIButton *)sender;
- (IBAction)playPauseButtonAction:(UIButton *)sender;
- (IBAction)deleteButtonAction:(UIButton *)sender;
- (IBAction)useButtonAction:(UIButton *)sender;
- (IBAction)crossButtonAction:(UIButton *)sender;

@end

@implementation AudioPlayerVC

#pragma mark - View Life Cycel
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customInit];
}

#pragma mark - Memory Management Methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helper Methods
-(void)customInit {
    
    [deleteButton setTitle:KNSLOCALIZEDSTRING(@"Delete") forState:UIControlStateNormal];
    [useButton setTitle:KNSLOCALIZEDSTRING(@"Use") forState:UIControlStateNormal];

    // Disable Stop/Play button when application launches
    bgImgView.image = _bgImg;
   [playButton setEnabled:NO];
}

-(void) recordWithPermission:(BOOL)setUp {
    AVAudioSession *session= [AVAudioSession sharedInstance ];
    // ios 8 and later
    if([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                NSLog(@"Permission to record granted");
                [self setSessionPlayAndRecord];
                if (setUp) {
                    [self setupRecorder];
                }
                [recorder record];
                meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioMeter:) userInfo:nil repeats:YES];
                  } else {
                NSLog(@"Permission to record not granted");
                  }
        }];
    } else {
        NSLog(@"requestRecordPermission unrecognized");
    }
}

-(void) setupRecorder {
    NSDateFormatter *format;
    format.dateFormat=@"yyyy-MM-dd-HH-mm-ss";
    NSString* currentFileName = @"recording-\(format.stringFromDate(NSDate())).m4a";
    NSLog(@"%@",currentFileName);
    NSURL *documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    soundFileUrl = [documentDirectory URLByAppendingPathComponent:currentFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundFileUrl.absoluteString]) {
        // probably won't happen. want to do something about it?
        NSLog(@"soundfile \(soundFileURL.absoluteString) exists");
    }
    NSError *err = nil;
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
     recorder = [[ AVAudioRecorder alloc] initWithURL:soundFileUrl settings:recordSetting error:&err];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder  prepareToRecord];// creates/overwrites the file at soundFileURL
}

-(void) setSessionPlayAndRecord{
     NSError *err = nil;
    AVAudioSession *session= [AVAudioSession sharedInstance ];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    [session setActive:YES error:&err];
   }

-(void) updateAudioMeter:(NSTimer *)timer {
    
    if (recorder != nil && recorder.recording) {
        NSInteger min = (recorder.currentTime / 60);
        NSInteger sec = trunc(recorder.currentTime - min * 60);
        NSString *s =[NSString stringWithFormat:@"%ld %ld",(long)min,(long)sec];
        timerLabel.text = s;
        [recorder updateMeters];
        // if you want to draw some graphics...
        //var apc0 = recorder.averagePowerForChannel(0)
        //var peak0 = recorder.peakPowerForChannel(0)
    } else if (player != nil && player.playing) {
        NSInteger min = (player.currentTime / 60);
        NSInteger sec = trunc(player.currentTime - min * 60);
        NSString *s =[NSString stringWithFormat:@"%ld %ld",(long)min,(long)sec];
        timerLabel.text = s;
        [player updateMeters];
        
    }
}

#pragma mark - AVFoundation Delegate Methods
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
//    print("finished recording \(flag)")
    playButton.enabled = YES;
    deleteButton.enabled = YES;
    useButton.enabled = YES;
}

// MARK: AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    recordButton.enabled = YES;
    [meterTimer invalidate];
}

#pragma mark - UIButton Action Methods
- (IBAction)recordButtonAction:(UIButton *)sender {
    recordButton.selected = !recordButton.selected;
    player.delegate = self;
    if (player != nil && player.playing) {
        [player stop];
    }
    if (recorder == nil) {
        playButton.enabled = NO;
        useButton.enabled = NO;
        deleteButton.enabled = NO;
        [self recordWithPermission:1];
        return;
    } else if ( recorder != nil && recorder.recording) {
        [recorder stop];
    } else {
        playButton.enabled = NO;
        useButton.enabled = NO;
        deleteButton.enabled = NO;
        [self recordWithPermission:1];
    }
}

- (IBAction)playPauseButtonAction:(UIButton *)sender {
//    playButton.enabled = YES;
    playButton.selected = !playButton.selected;
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        recordButton.enabled = NO;
    } else if (player.playing) {
        [meterTimer invalidate];
        timerLabel.text = @"00:00";
        meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateAudioMeter:) userInfo:nil repeats:YES];
    } else {
        [meterTimer invalidate];
    }
}

- (IBAction)deleteButtonAction:(UIButton *)sender {
    if (player != nil && !player.playing) {
         [player stop];
    } else if (recorder !=nil) {
        [recorder deleteRecording];
        playButton.enabled = NO;
        useButton.enabled = NO;
        deleteButton.enabled = NO;
    }
    recordButton.enabled = YES;
    recordButton.selected = NO;
    playButton.enabled = NO;
    useButton.enabled = NO;
    deleteButton.enabled = NO;
}

- (IBAction)useButtonAction:(UIButton *)sender {
    if(player !=nil && !player.playing) {
        [player stop];
    }
    [meterTimer invalidate];
    timerLabel.text = @"00:00";
    recordButton.enabled = YES;
    playButton.enabled = NO;
    useButton.enabled = NO;
    deleteButton.enabled = NO;
    [self.delegate getRecordedAudio:soundFileUrl];
      [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)crossButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
