//
//  NSView+AllSubviews.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/23/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (AllSubviews)
- (NSArray *)allSubviews;
- (NSArray *)allSubviewsOfClass:(Class)klass;
@end
