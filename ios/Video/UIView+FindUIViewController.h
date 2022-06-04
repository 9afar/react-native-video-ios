//
//  UIView+FindUIViewController.h
//  RCTVideo
//
//  Created by Stanisław Chmiela on 31.03.2016.
//  Copyright © 2016 Facebook. All rights reserved.
//
//  Source: http://stackoverflow.com/a/3732812/1123156

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
@interface UIView (FindUIViewController)
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
- (void) setPlayerItemForInterstitial :(AVPlayerItem*)playerItem;
- (void) setInterstitialWatched :(NSArray *)interstitialWatched;
- (void) setInterstitialCompleted :(NSArray *)interstitialCompleted;
- (void) setAdsRunning :(BOOL)adsRunning;
@end
