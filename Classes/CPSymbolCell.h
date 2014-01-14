//
//  CPSymbolCell.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPResultCell.h"

@class CPSymbol;

@interface CPSymbolCell : CPResultCell
@property (nonatomic, strong, readonly) CPSymbol *cpSymbol;

- (NSUInteger)requiredHeight;
- (NSColor *)symbolNameForegroundColor;
- (void)drawSymbolNameWithFrame:(NSRect)cellFrame;
- (void)drawSourceFileNameWithFrame:(NSRect)cellFrame;
- (NSColor *)symbolCategoryNameForegroundColor;
- (NSColor *)symbolNameForegroundColorWithoutHighlight;
- (NSColor *)symbolNameForegroundColorWithHighlight;
@end