//
//  NSString+Abbreviation.h
//  Quark
//
//  Created by Daniel on 09-12-04.
//  Copyright 2009 Macosope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (Abbreviation)
- (NSArray *)hitsForString:(NSString *)testString;
- (NSNumber *)scoreForQuery:(NSString *)query;
- (BOOL)matchesFuzzyQuery:(NSString *)query;
@end
