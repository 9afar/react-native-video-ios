//  Source: http://stackoverflow.com/a/3732812/1123156

#import "UIView+FindUIViewController.h"

@implementation UIView (FindUIViewController)
AVPlayerItem *_playerItem;
AVPlayer *_player;
NSMutableArray *interstitialWatched;
AVInterstitialTimeRange *_selectedInterstitialCW;
float _pendingSeekTime;

- (UIViewController *) firstAvailableUIViewController{
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
- (void) setPlayerItemForInterstitial:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
}
- (void) resetInterstitialParam{
    interstitialWatched= nil;
    _playerItem= nil;
    _player =nil;
    _selectedInterstitialCW= nil;
    _pendingSeekTime = 0;
}
- (void) setPendingSeek:(float)time{
    _pendingSeekTime= time;
}
- (void) setPlayerForInterstitial:(AVPlayer *)player{
    _player= player;
}
- (void) setSelectedInterstitialCW:(AVInterstitialTimeRange *)interstitial{
    _selectedInterstitialCW= interstitial;
}
#pragma mark - AVPlayerViewControllerDelegate
-(void)playerViewController:(AVPlayerViewController *)playerViewController willPresentInterstitialTimeRange:(AVInterstitialTimeRange *)interstitial{
    if(!interstitialWatched){
        interstitialWatched = [NSMutableArray array];
    }
    if([interstitialWatched containsObject: interstitial]){
        if(_selectedInterstitialCW == interstitial && _pendingSeekTime > 0){
            CMTime cmSeekTime = CMTimeMakeWithSeconds(_pendingSeekTime, 1000);
            [_player seekToTime:cmSeekTime completionHandler:^(BOOL finished) {
                _selectedInterstitialCW = nil;
                _pendingSeekTime = 0;
            }];
        }
    }else {
        [interstitialWatched addObject:interstitial];
        playerViewController.requiresLinearPlayback = true;
    }

    if (@available(tvOS 15.0, *)) {
        [playerViewController setTransportBarIncludesTitleView: false ];
    }
}
- (void)playerViewController:(AVPlayerViewController *)playerViewController didPresentInterstitialTimeRange:(AVInterstitialTimeRange *)interstitial{

    playerViewController.requiresLinearPlayback = false;
    if (@available(tvOS 15.0, *)) {
        [playerViewController setTransportBarIncludesTitleView: true ];
    }
    if(_selectedInterstitialCW == interstitial && _pendingSeekTime > 0){
        CMTime cmSeekTime = CMTimeMakeWithSeconds(_pendingSeekTime, 1000);
        [_player seekToTime:cmSeekTime completionHandler:^(BOOL finished) {
            _selectedInterstitialCW = nil;
            _pendingSeekTime = 0;
        }];
    }
}

- (CMTime)playerViewController:(AVPlayerViewController *)playerViewController
timeToSeekAfterUserNavigatedFromTime:(CMTime)oldTime
                        toTime:(CMTime)targetTime{
    // only to foward
    if(CMTimeCompare(oldTime,targetTime)== 1)  {
        return targetTime;
    }
    if(_playerItem.interstitialTimeRanges){
        CMTimeRange seekRange = CMTimeRangeMake(oldTime, targetTime);
        for (AVInterstitialTimeRange *interstitialRange in _playerItem.interstitialTimeRanges) {
            if (CMTimeRangeContainsTime(seekRange , interstitialRange.timeRange.start)){
                if (interstitialWatched && [interstitialWatched containsObject: interstitialRange]) {
                    return targetTime;
                }
                return interstitialRange.timeRange.start;
            }
        }
    }
    return targetTime;

}
@end
