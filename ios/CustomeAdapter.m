//
//  CustomeAdapter.m
//  RCTVideo
//
//  Created by Muhammad Dwairi on 11/21/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "CustomeAdapter.h"
@implementation CustomAdapter

- (void)fireJoin {
    [super fireJoin:self.customArguments];
}

- (void)fireStart {
    [super fireStart:self.customArguments];
}

@end
