//
//  AMIndeterminateProgressIndicatorCell.m
//  IPICellTest
//
//  Created by Andreas on 23.01.07.
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

//	2007-03-10	Andreas Mayer
//	- removed -keyEquivalent and -keyEquivalentModifierMask methods
//		(I thought those were required by NSTableView/Column. They are not.
//		Instead I was using NSButtons as a container for the cells in the demo project.
//		Replacing those with plain NSControls did fix the problem.)
//	2007-03-24	Andreas Mayer
//	- will now spin in the same direction in flipped and not flipped views
//	2008-09-03	Andreas Mayer
//	- restore default settings for NSBezierPath after drawing
//	- instead of the saturation, we now modify the lines' opacity; does look better on colored
//		backgrounds

#import "AMIndeterminateProgressIndicatorCell.h"

#define ConvertAngle(a) (fmod((90.0-(a)), 360.0))

#define DEG2RAD  0.017453292519943295

@implementation AMIndeterminateProgressIndicatorCell

- (id)init
{
	if ((self = [super initImageCell:nil])) {
		[self setAnimationDelay:5.0/60.0];
		[self setDisplayedWhenStopped:YES];
		[self setDoubleValue:0.0];
		[self setColor:[NSColor greenColor]];
	}
	return self;
}


- (NSColor *)color
{
	return color;
}

- (void)setColor:(NSColor *)value
{
	CGFloat alphaComponent;
	if (color != value) {
		color = value;
		[[color colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"] getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent];
//		NSAssert((alphaComponent > 0.999), @"color must be opaque"); // gives a warning in xcode4
	}
}

- (double)doubleValue
{
	return doubleValue;
}

- (void)setDoubleValue:(double)value
{
	if (doubleValue != value) {
		doubleValue = value;
		if (doubleValue > 1.0) {
			doubleValue = 1.0;
		} else if (doubleValue < 0.0) {
			doubleValue = 0.0;
		}
	}
}

- (NSTimeInterval)animationDelay
{
	return animationDelay;
}

- (void)setAnimationDelay:(NSTimeInterval)value
{
	if (animationDelay != value) {
		animationDelay = value;
	}
}

- (BOOL)isDisplayedWhenStopped
{
	return displayedWhenStopped;
}

- (void)setDisplayedWhenStopped:(BOOL)value
{
	if (displayedWhenStopped != value) {
		displayedWhenStopped = value;
	}
}

- (BOOL)isSpinning
{
	return spinning;
}

- (void)setSpinning:(BOOL)value
{
	if (spinning != value) {
		spinning = value;
	}
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// cell has no border
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//NSLog(@"cellFrame: %f %f %f %f", cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height);
	if ([self isSpinning] || [self isDisplayedWhenStopped]) {
		float flipFactor = ([controlView isFlipped] ? 1.0 : -1.0);
		int step = round([self doubleValue]/(5.0/60.0));
		float cellSize = MIN(cellFrame.size.width, cellFrame.size.height);
		NSPoint center = cellFrame.origin;
		center.x += cellSize/2.0;
		center.y += cellFrame.size.height/2.0;
		float outerRadius;
		float innerRadius;
		float strokeWidth = cellSize*0.08;
		if (cellSize >= 32.0) {
			outerRadius = cellSize*0.38;
			innerRadius = cellSize*0.23;
		} else {
			outerRadius = cellSize*0.48;
			innerRadius = cellSize*0.27;
		}
		float a; // angle
		NSPoint inner;
		NSPoint outer;
		// remember defaults
		NSLineCapStyle previousLineCapStyle = [NSBezierPath defaultLineCapStyle];
		float previousLineWidth = [NSBezierPath defaultLineWidth];
		// new defaults for our loop
		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
		[NSBezierPath setDefaultLineWidth:strokeWidth];
		if ([self isSpinning]) {
			a = (270+(step* 30))*DEG2RAD;
		} else {
			a = 270*DEG2RAD;
		}
		a = flipFactor*a;
		int i;
		for (i = 0; i < 12; i++) {
//			[[NSColor colorWithCalibratedWhite:MIN(sqrt(i)*0.25, 0.8) alpha:1.0] set];
//			[[NSColor colorWithCalibratedWhite:0.0 alpha:1.0-sqrt(i)*0.25] set];
			[[NSColor colorWithCalibratedRed:redComponent green:greenComponent blue:blueComponent alpha:1.0-sqrt(i)*0.25] set];
//			[[NSColor colorWithCalibratedRed:1.0 green:0 blue:0 alpha:1.0-sqrt(i)*0.25] set];
			outer = NSMakePoint(center.x+cos(a)*outerRadius, center.y+sin(a)*outerRadius);
			inner = NSMakePoint(center.x+cos(a)*innerRadius, center.y+sin(a)*innerRadius);
			[NSBezierPath strokeLineFromPoint:inner toPoint:outer];
			a -= flipFactor*30*DEG2RAD;
		}
		// restore previous defaults
		[NSBezierPath setDefaultLineCapStyle:previousLineCapStyle];
		[NSBezierPath setDefaultLineWidth:previousLineWidth];
	}
}

- (void)setObjectValue:(id)value
{
	if ([value respondsToSelector:@selector(boolValue)]) {
		[self setSpinning:[value boolValue]];
	} else {
		[self setSpinning:NO];
	}
}


@end
