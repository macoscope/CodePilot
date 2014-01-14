//
//  NSMutableArray+MiscExtensions.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableArray (MiscExtensions)
- (NSArray *)arrayFilteredAndScoredWithFuzzyQuery:(NSString *)query forKey:(NSString *)key;
- (void)filterWithFuzzyQuery:(NSString *)query forKey:(NSString *)key;
@end