//
//  HUDViewWithRoundCorners.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/11/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPHUDViewWithRoundCorners : NSView
@property (nonatomic, assign) NSUInteger cornerRadius;
@property (nonatomic, strong) NSColor *backgroundColor;
@end
