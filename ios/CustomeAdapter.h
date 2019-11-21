//
//  CustomeAdapter.h
//  RCTVideo
//
//  Created by Muhammad Dwairi on 11/21/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YouboraAVPlayerAdapter/YBAVPlayerAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomAdapter : YBAVPlayerAdapter

@property NSDictionary *customArguments;

@end

NS_ASSUME_NONNULL_END
