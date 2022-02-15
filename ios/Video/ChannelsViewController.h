//
//  ChannelsViewController.h
//  Pods
//
//  Created by Mahdi Hamdan on 13/02/2022.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import <React/RCTBridgeModule.h>
@interface ChannelsViewController : UICollectionViewController <UICollectionViewDataSource , UICollectionViewDelegate>
@property (nonatomic, copy) NSArray *channels;
@property (nonatomic, copy) NSString *currentChannelId;
@property (nonatomic, copy) RCTDirectEventBlock onChannelSelect;
@end
