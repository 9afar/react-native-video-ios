#import "RCTVideoPlayerViewController.h"
@import ProgrammaticAccessLibrary;

@interface RCTVideoPlayerViewController () <PALNonceLoaderDelegate>
/** The nonce loader to use for nonce requests. */
@property(nonatomic) PALNonceLoader *nonceLoader;
/** The nonce manager result from the last successful nonce request. */
@property(nonatomic) PALNonceManager *nonceManager;
@end

@implementation RCTVideoPlayerViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
  if(self.palSDKMetadata){
      self.nonceLoader = [[PALNonceLoader alloc] init];
      self.nonceLoader.delegate = self;
      [self requestNonceManager];
  }
}
- (BOOL)shouldAutorotate {

  if (self.autorotate || self.preferredOrientation.lowercaseString == nil || [self.preferredOrientation.lowercaseString isEqualToString:@"all"])
    return YES;
  
  return NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [_rctDelegate videoPlayerViewControllerWillDismiss:self];
  [_rctDelegate videoPlayerViewControllerDidDismiss:self];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
    if (@available(tvOS 13.0, *)) {
        self.userActivity = [[NSUserActivity alloc] initWithActivityType:@"net.mbc.shahid-iphone"];
        self.userActivity.targetContentIdentifier = self.contentId;
        [self.userActivity becomeCurrent];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self sendPlaybackEnd];
    [super viewWillDisappear:animated];
    [self.userActivity invalidate];
}

#if !TARGET_OS_TV
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  if ([self.preferredOrientation.lowercaseString isEqualToString:@"landscape"]) {
    return UIInterfaceOrientationLandscapeRight;
  }
  else if ([self.preferredOrientation.lowercaseString isEqualToString:@"portrait"]) {
    return UIInterfaceOrientationPortrait;
  }
  else { // default case
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return orientation;
  }
}
#endif


/** Reports the start of playback for the current content session. */
- (void)sendPlaybackStart {
    if(self.nonceManager){
        [self.nonceManager sendPlaybackStart];
    }
}

/** Reports the end of playback for the current content session. */
- (void)sendPlaybackEnd {
    if(self.nonceManager){
      [self.nonceManager sendPlaybackEnd];
    }
}

#pragma mark - UI Callback methods
/**
 * Requests a new nonce manager with a request containing arbitrary test values like a (sane) user
 * might supply. Displays the nonce or error on success. This should be called once per stream.
 */
- (void)requestNonceManager {
  PALNonceRequest *request = [[PALNonceRequest alloc] init];
  CGSize windowSize = self.view.frame.size;
    
  request.continuousPlayback = PALFlagOff;
  request.descriptionURL = [NSURL URLWithString:[self.palSDKMetadata objectForKey:@"descriptionURL"]];
  request.iconsSupported = YES;
  request.playerType = @"tvOS AVPlayer";
  request.playerVersion = @"5.1.25-sh4"; // tag
  request.PPID =[self.palSDKMetadata objectForKey:@"ppid"];
  request.sessionID = [self.palSDKMetadata objectForKey:@"sessionId"];
  request.videoPlayerHeight = windowSize.height;
  request.videoPlayerWidth =  windowSize.width;
  request.willAdAutoPlay = PALFlagOn;
  request.willAdPlayMuted = PALFlagOff;

  if (self.nonceManager) {
    // Detach the old nonce manager's gesture recognizer before destroying it.
    [self.view removeGestureRecognizer:self.nonceManager.gestureRecognizer];
    self.nonceManager = nil;
  }
  [self.nonceLoader loadNonceManagerWithRequest:request];
}

#pragma mark - PALNonceLoaderDelegate methods

- (void)nonceLoader:(PALNonceLoader *)nonceLoader
            withRequest:(PALNonceRequest *)request
    didLoadNonceManager:(PALNonceManager *)nonceManager {
    NSLog(@"Programmatic access nonce: %@", nonceManager.nonce);
    // Capture the created nonce manager and attach its gesture recognizer to the video view.
    self.nonceManager = nonceManager;
    [self.view addGestureRecognizer:self.nonceManager.gestureRecognizer];
}

- (void)nonceLoader:(PALNonceLoader *)nonceLoader
         withRequest:(PALNonceRequest *)request
    didFailWithError:(NSError *)error {
    NSLog(@"Error generating programmatic access nonce: %@", error);

}

@end
