//
//  AMIndeterminateProgressIndicatorCell.h
//  IPICellTest
//
//  Created by Andreas on 23.01.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AMIndeterminateProgressIndicatorCell : NSCell {
	double doubleValue;
	NSTimeInterval animationDelay;
	BOOL displayedWhenStopped;
	BOOL spinning;
	NSColor *color;
	CGFloat redComponent;
	CGFloat greenComponent;
	CGFloat blueComponent;
}

- (NSColor *)color;
- (void)setColor:(NSColor *)value;

- (double)doubleValue;
- (void)setDoubleValue:(double)value;

- (NSTimeInterval)animationDelay;
- (void)setAnimationDelay:(NSTimeInterval)value;

- (BOOL)isDisplayedWhenStopped;
- (void)setDisplayedWhenStopped:(BOOL)value;

- (BOOL)isSpinning;
- (void)setSpinning:(BOOL)value;


@end
