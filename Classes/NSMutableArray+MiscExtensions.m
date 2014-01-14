//
//  NSMutableArray+MiscExtensions.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "NSArray+MiscExtensions.h"
#import "NSMutableArray+MiscExtensions.h"
#import "NSString+Abbreviation.h"

@implementation NSMutableArray (MiscExtensions)
// filters entries not matching to the query
// and returns score table for what's left
- (NSArray *)arrayFilteredAndScoredWithFuzzyQuery:(NSString *)query forKey:(NSString *)key
{
	NSMutableArray *scores = [[self arrayScoresWithFuzzyQuery:query forKey:key] mutableCopy];
	NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet new];
  
	for (NSInteger i = 0; i < [self count]; i++) {
		if ([NSNull null] == [scores objectAtIndex:i]) {
			[indexesToRemove addIndex:i];
		}
	}
  
	[self removeObjectsAtIndexes:indexesToRemove];
	[scores removeObjectsAtIndexes:indexesToRemove];
  
	return scores;
}

// simpler/faster implementation when you don't need scoring
- (void)filterWithFuzzyQuery:(NSString *)query forKey:(NSString *)key
{
	NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet new];
  
	for (NSInteger i = 0; i < [self count]; i++) {
		id obj = [self objectAtIndex:i];
		if (![[obj valueForKey:key] matchesFuzzyQuery:query]) {
			[indexesToRemove addIndex:i];
		}
	}
  
	[self removeObjectsAtIndexes:indexesToRemove];
}
@end