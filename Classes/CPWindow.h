//
//  SearchWindow.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/14/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CPSearchWindowView, CPNoProjectOpenWindowView, CPXcodeVersionUnsupportedWindowView, CPFirstRunWindowView;

@interface CPWindow : NSWindow
@property (nonatomic, strong) CPSearchWindowView *searchWindowView;
@property (nonatomic, strong) CPNoProjectOpenWindowView *noProjectOpenWindowView;
@property (nonatomic, strong) CPXcodeVersionUnsupportedWindowView *xcodeVersionUnsupportedWindowView;
@property (nonatomic, strong) CPFirstRunWindowView *firstRunWindowView;

- (void)updateFrameWithViewRequirementsWithAnimation:(BOOL)animation;
- (void)updateFrameWithViewRequirements;
- (id)initWithDefaultSettings;
- (void)firstRunOrderFront;
- (NSScreen *)destinationScreen;
@end