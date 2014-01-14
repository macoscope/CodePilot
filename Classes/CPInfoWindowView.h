//
//  CPInfoWindowView.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/11/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPHUDViewWithRoundCorners.h"
#import "CPStatusLabel.h"

@interface CPInfoWindowView : CPHUDViewWithRoundCorners
@property (nonatomic, strong) CPStatusLabel *infoLabel;
@property (nonatomic, strong) NSURL *clickUrl;

- (NSSize)windowFrameRequirements;
- (void)setupInfoLabel;
- (void)drawProductLogo;
@end
