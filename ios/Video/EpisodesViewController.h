//
//  EpisodeViewController.h
//  react-native-video-tvOS
//
//  Created by Mahdi Hamdan on 13/10/2022.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import <React/RCTBridgeModule.h>

#import "RCTVideoPlayerViewController.h"


@interface EpisodesViewController : UICollectionViewController <UICollectionViewDataSource , UICollectionViewDelegate>
@property (nonatomic, copy) NSString *currentEpisodeId;
@property (nonatomic, copy) RCTVideoPlayerViewController *playerViewController;
@property (nonatomic, copy) RCTDirectEventBlock onEpisodeSelect;
- (void) setEpisodes :(NSArray *)episodes;

@end
