//
//  MSHObservation2.m
//  VideoTest
//
//  Created by Manu Sharma on 4/27/14.
//  Copyright (c) 2014 Motorola Mobility. All rights reserved.
//

#import "MSHObservation2.h"


#define videoURL @"http://manusharma.me/movie/testmovie.mp4"

@interface MSHObservation2 ()

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
- (IBAction)btnActionAirplay:(id)sender;



// Flags
@property (nonatomic, readwrite) id timeObserver;


// Other IVars
@property (nonatomic, readwrite) CGFloat duration;
@property (nonatomic, readwrite) NSArray *loadedTimeRanges;

@end

@implementation MSHObservation2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *myVideoURL = [NSURL URLWithString:videoURL];
    
    // Setting up iVars
        self.duration = CMTimeGetSeconds(self.vidPlayer.currentItem.duration);
        self.loadedTimeRanges = [[self.vidPlayer currentItem] loadedTimeRanges];
    
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


#pragma mark - Helper methods

-(void) playVideoAtURL : (NSURL*) remoteVideoURL{
    
    AVPlayerItem *myMovie = [[AVPlayerItem alloc] initWithURL:remoteVideoURL];
    
    self.vidPlayer = [[AVPlayer alloc] initWithPlayerItem:myMovie];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.vidPlayer];
    self.playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer: self.playerLayer];
    
    [self.vidPlayer play];
       
    [NSTimer scheduledTimerWithTimeInterval:.1
                                     target:self
                                   selector:@selector(bufferVid)
                                   userInfo:nil
                                    repeats:NO];
    
    
    [self addObservers];
    
}


- (void) bufferVid{
    // ProgressBar View
    

    CMTimeRange timeRange = [[self.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
    NSInteger loadedTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
    
    // progress is loaded time
    float progress = (float) loadedTime / self.duration;
    self.progressView.progress = progress;
    

}


- (void ) addObservers {
    
    __weak typeof (self) weakSelf = self;
    
    self.timeObserver = [self.vidPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.05f, NSEC_PER_SEC)
                                                                     queue:NULL
                                                                usingBlock:^(CMTime time) {
                                                                    
                                                                    [weakSelf createObservations];
                                                                }];

   
}

-(void) removeObservers{
    [self.vidPlayer removeTimeObserver:self.timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.vidPlayer.currentItem];
}


-(void) createObservations{
    [self.vidPlayer.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.vidPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    
    // Setting up slider bar and labels
    
    self.duration = CMTimeGetSeconds(self.vidPlayer.currentItem.duration);
    NSInteger currentTime = CMTimeGetSeconds(self.vidPlayer.currentItem.currentTime);
    
    self.progressSlider.maximumValue = self.duration;
    self.progressSlider.value = currentTime;
    
    self.lblCurrentTime.text = [NSString stringWithFormat:@"%ld", (long)currentTime];
    self.lblMaxTime.text = [NSString stringWithFormat:@"%ld", (long)self.duration];
    
    
    
    
    
    if (!self.vidPlayer)
    {
        NSLog(@"Player fucked up. Exiting at Observation.");
        return;
    }
    
    else if (object == self.vidPlayer.currentItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.vidPlayer.currentItem.playbackBufferEmpty) {
            //Your code here
            [self.loadingIndicator startAnimating];
        }
    }
    
    else if (object == self.vidPlayer.currentItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (self.vidPlayer.currentItem.playbackLikelyToKeepUp)
        {
            //Your code here
            

            [self.loadingIndicator stopAnimating];
            [self.vidPlayer play];
            
            
            
        }
    }

    
    
}


- (void)checkForExistingScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1)
    {
        // Associate the window with the second screen.
        // The main screen is always at index 0.
        UIScreen*    secondScreen = [[UIScreen screens] objectAtIndex:1];
        CGRect        screenBounds = secondScreen.bounds;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.screen = secondScreen;
        
        // Add a white background to the window
        UIView*            whiteField = [[UIView alloc] initWithFrame:screenBounds];
        whiteField.backgroundColor = [UIColor whiteColor];
        
        [self.secondWindow addSubview:whiteField];

        
        // Center a label in the view.
        NSString*    noContentString = [NSString stringWithFormat:@"Manu's Video App"];
        CGSize        stringSize = [noContentString sizeWithFont:[UIFont systemFontOfSize:18]];
        
        CGRect        labelSize = CGRectMake((screenBounds.size.width - stringSize.width) / 2.0,
                                             (screenBounds.size.height - stringSize.height) / 2.0,
                                             stringSize.width, stringSize.height);
        
        UILabel*    noContentLabel = [[UILabel alloc] initWithFrame:labelSize];
        noContentLabel.text = noContentString;
        noContentLabel.font = [UIFont systemFontOfSize:18];
        [whiteField addSubview:noContentLabel];
        
        // Go ahead and show the window.
        self.secondWindow.hidden = NO;
        
        NSLog(@"New screen width: %f X %f", self.secondWindow.bounds.size.width, self.secondWindow.bounds.size.height);
        
        [whiteField.layer addSublayer:self.playerLayer];
    }
    else{
        NSLog(@"No External Screen.");
    }
}


#pragma mark - IBActions

- (IBAction)playButtonPress:(id)sender {
    [self.vidPlayer play];
}

- (IBAction)btnActionAirplay:(id)sender {
    [self checkForExistingScreenAndInitializeIfPresent];
}



@end
