//
//  RCTVideoPlayerViewController.h
//  RCTVideo
//
//  Created by Stanisław Chmiela on 31.03.2016.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "RCTVideo.h"
#import "RCTVideoPlayerViewControllerDelegate.h"
@interface RCTVideoPlayerViewController : AVPlayerViewController <AVPlayerViewControllerDelegate>
@property (nonatomic, weak) id<RCTVideoPlayerViewControllerDelegate> rctDelegate;

// Optional paramters
@property (nonatomic, weak) NSString* preferredOrientation;
@property (nonatomic, weak) NSString* contentId;
@property (nonatomic) BOOL autorotate;
@end
