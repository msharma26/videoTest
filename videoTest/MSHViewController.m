//
//  MSHViewController.m
//  VideoTest
//
//  Created by Manu Sharma on 4/24/14.
//  Copyright (c) 2014 Motorola Mobility. All rights reserved.
//

#import "MSHViewController.h"
#import <AVFoundation/AVFoundation.h>

#define videoURL @"http://manusharma.me/movie/testmovie.mp4"

@interface MSHViewController ()

// AVPlayer Properties
@property (nonatomic, strong) AVPlayer *vidPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


// IBOUtlets
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxTime;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;


// IBActions
- (IBAction)playButtonPress:(id)sender;

// Flags
@property (nonatomic, readwrite) id timeObserver;

@end

@implementation MSHViewController


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *myVideoURL = [NSURL URLWithString:videoURL];

    // Playing the video
    [self playVideoAtURL:myVideoURL];
    
    // Setting up buttons
    self.playButton.titleLabel.text = @"";
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Helper Methods
-(void) playVideoAtURL : (NSURL*) remoteVideoURL{
    
    AVPlayerItem *myMovie = [[AVPlayerItem alloc] initWithURL:remoteVideoURL];
    
    self.vidPlayer = [[AVPlayer alloc] initWithPlayerItem:myMovie];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.vidPlayer];
    self.playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer: self.playerLayer];
    
        [self.vidPlayer play];

    [self addObservers];
    
     }

- (void ) addObservers {
    
    __weak typeof (self) weakSelf = self;
    
    self.timeObserver = [self.vidPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.05f, NSEC_PER_SEC)
                                                                     queue:NULL
                                                                usingBlock:^(CMTime time) {
                                                                    
                                                                    [weakSelf syncProgressBar];
                                                                }];
}

-(void) removeObservers{
    [self.vidPlayer removeTimeObserver:self.timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.vidPlayer.currentItem];
}

-(void) syncProgressBar{
    
    NSInteger duration = CMTimeGetSeconds(self.vidPlayer.currentItem.duration);
    NSInteger currentTime = CMTimeGetSeconds(self.vidPlayer.currentItem.currentTime);
    
    self.progressSlider.maximumValue = duration;
    self.progressSlider.value = currentTime;

    self.lblCurrentTime.text = [NSString stringWithFormat:@"%ld", (long)currentTime];
    self.lblMaxTime.text = [NSString stringWithFormat:@"%ld", (long)duration];
    
    // progress is just duration.
    //float progress = (float) currentTime / duration;
    
    
    NSArray *loadedTimeRanges = [[self.vidPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    NSInteger loadedTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
    
    // progress is loaded time
    float progress = (float) loadedTime / duration;
     self.progressView.progress = progress;
    
    
    
    
    if (!self.vidPlayer.currentItem.isPlaybackLikelyToKeepUp){
        [self.loadingIndicator startAnimating];
    }
    else{
        [self.loadingIndicator stopAnimating];
    }
}



/* 
    Not being used right now. This method is here only for reference.
    http://stackoverflow.com/questions/7691854/avplayer-streaming-progress
 */
- (NSTimeInterval) availableDuration;
{
    NSArray *loadedTimeRanges = [[self.vidPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}


#pragma mark - IBActions
- (IBAction)playButtonPress:(id)sender {
    [self.vidPlayer play];
}
@end
