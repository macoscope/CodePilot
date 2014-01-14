//
//  NSArray+MiscExtensions.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSArray (MiscExtensions)
- (NSArray *)arrayScoresWithFuzzyQuery:(NSString *)query forKey:(NSString *)key;
- (NSArray *)arrayWithoutElementsHavingNilOrEmptyValueForKey:(NSString *)key;
@end
