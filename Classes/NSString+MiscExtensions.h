//
//  NSString+MiscExtensions.h
//  CodePilot
//
//  Created by Daniel on 09-12-10.
//  Copyright 2009 Macosope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MC_SED(string, pattern, replacement) [string replaceOccurrencesOfString:pattern withString:replacement options:0 range:NSMakeRange(0, [string length])]

@interface NSString(MiscExtensions)
- (BOOL)isBlank;
- (NSRange)completeRange;
- (NSString *)hexString;
+ (NSString *)nounWithCount:(NSInteger)count forNoun:(NSString *)noun;
@end