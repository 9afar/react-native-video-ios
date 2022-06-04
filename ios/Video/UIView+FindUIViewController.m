//  Source: http://stackoverflow.com/a/3732812/1123156

#import "UIView+FindUIViewController.h"

@implementation UIView (FindUIViewController)
AVPlayerItem *_playerItem;
NSArray *_interstitialWatched;
NSArray *_interstitialCompleted;
bool _adsRunning;

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
- (void) setAdsRunning:(bool)adsRunning {
    _adsRunning = adsRunning;
}
- (void) setInterstitialWatched:(NSArray *)interstitialWatched {
    _interstitialWatched = interstitialWatched;
}
- (void) setInterstitialCompleted:(NSArray *)interstitialCompleted {
    _interstitialCompleted = interstitialCompleted;
}

- (CMTime)playerViewController:(AVPlayerViewController *)playerViewController
timeToSeekAfterUserNavigatedFromTime:(CMTime)oldTime
                        toTime:(CMTime)targetTime{
    if(_adsRunning){
        return oldTime;
    }
    if(CMTimeCompare(oldTime,targetTime)== 1)  {
         return targetTime;
     }
    if(_playerItem.interstitialTimeRanges){
        CMTimeRange seekRange = CMTimeRangeFromTimeToTime(oldTime, targetTime);
        for (AVInterstitialTimeRange *interstitialRange in _playerItem.interstitialTimeRanges) {
            if (CMTimeRangeContainsTimeRange(seekRange , interstitialRange.timeRange)){
                if (_interstitialCompleted && [_interstitialCompleted containsObject: interstitialRange]) {
                    return targetTime;
                }
                return interstitialRange.timeRange.start;
            }
        }
    }
    return targetTime;

}
@end
