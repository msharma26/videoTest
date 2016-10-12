//
//  MSHViewController.m
//  videoTest
//
//  Created by Manu Sharma on 4/22/14.
//  Copyright (c) 2014 WesterLime Inc. All rights reserved.
//

#import "MSHViewController.h"

#define kVideoURL @"http://manusharma.me/movie/testmovie.mp4"

@interface MSHViewController ()

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong ) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) AVPlayerItem *avPlayerItem;

// Flags
@property (nonatomic, readwrite) BOOL isPlaying;

@property (weak, nonatomic) IBOutlet UIButton *btnPause;
- (IBAction)btnPressPause:(id)sender;

 @end

@implementation MSHViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *videoURL = [NSURL URLWithString:kVideoURL];
    self.avPlayer = [AVPlayer playerWithURL:videoURL];
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
    self.avPlayerLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer: self.avPlayerLayer];
    
    [self.avPlayer play];
    
    
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    

    self.isPlaying = YES;

    
    //[self.avPlayer addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    
}

#pragma mark - video handlers

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    
    
}

# pragma Mark - Device Rotation

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.avPlayerLayer.frame = CGRectMake(0,-320,640, 960);
        //CGRectMake(0,0,320, 240);
    }
    else{
        self.avPlayerLayer.frame = self.view.frame;
    }
}


- (IBAction)btnPressPause:(id)sender {
    if(self.isPlaying){
    [self.avPlayer pause];
        self.isPlaying = NO;
    }
    else{
        [self.avPlayer play];
        self.isPlaying = YES;
    }
}
@end
