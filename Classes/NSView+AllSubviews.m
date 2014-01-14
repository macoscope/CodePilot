//
//  NSView+AllSubviews.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/23/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "NSView+AllSubviews.h"

@implementation NSView (AllSubviews)
- (NSArray *)allSubviews
{
	NSMutableArray *mySubviews = [NSMutableArray new];
  
	for (NSView *view in [self subviews]) {
		if ([[view subviews] count] > 0) {
			[mySubviews addObjectsFromArray:[view allSubviews]];
		}
    
		[mySubviews addObject:view];
	}
  
	return mySubviews;
}

- (NSArray *)allSubviewsOfClass:(Class)klass
{
	NSArray *allSubviews = [self allSubviews];
	NSMutableArray *subviewsOfClass = [NSMutableArray new];
  
	for (NSView *subview in allSubviews) {
		if ([subview isKindOfClass:klass]) {
			[subviewsOfClass addObject:subview];
		}
	}
  
	return subviewsOfClass;
}
@end
