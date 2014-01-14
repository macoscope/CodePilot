//
//  NSString+Abbreviation.m
//  Quark
//
//  Created by Daniel on 09-12-04.
//  Copyright 2009 Macosope. All rights reserved.
//

#import "NSString+Abbreviation.h"
#import "MCStringScoring.h"
#import "MCCommons.h"

// based on NSString_BLTRExtensions.h/m from quicksilver codebase
@implementation NSString (Abbreviation)
- (NSArray *)hitsForString:(NSString *)queryString
{
	const char *scoredString = [self cStringUsingEncoding:NSUTF8StringEncoding];
	const char *cQuery = [[queryString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] cStringUsingEncoding:NSUTF8StringEncoding];
  
	NSMutableArray *hitsArray = [NSMutableArray arrayWithCapacity:[self length]];
	int *indexesOfMatchedChars;
	int cQueryLength = strlen(cQuery);
	float finalScore;
  
	if (cQueryLength > 0) {
		int index;
		indexesOfMatchedChars = malloc(sizeof(int)*strlen(cQuery));
		memset(indexesOfMatchedChars, -1, sizeof(int)*strlen(cQuery));
    
		finalScore = MCStringScoring_scoreStringForQuery(scoredString, cQuery, indexesOfMatchedChars);
    
		if (-1.0 != finalScore) {
			for (index=0;index<cQueryLength;index++) {
				[hitsArray addObject:[NSNumber numberWithInt:indexesOfMatchedChars[index]]];
			}
		}
    
		free(indexesOfMatchedChars);
	}
  
	return hitsArray;
}

// precalculated query length is useful for optimizations, when we run the same query
// through lots and lots of strings
- (NSNumber *)scoreForQuery:(NSString *)query
{
	if (IsEmpty(query)) {
		return [NSNumber numberWithFloat:1.0];
	}
  
	const char *scoredString = [self cStringUsingEncoding:NSUTF8StringEncoding];
	const char *cQuery = [[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] cStringUsingEncoding:NSUTF8StringEncoding];
  
	int *indexesOfMatchedChars;
  float finalScore = -1.0;
	int cQueryLength = strlen(cQuery);
  
	if (cQueryLength > 0) {
		indexesOfMatchedChars = malloc(sizeof(int)*strlen(cQuery));
		memset(indexesOfMatchedChars, -1, sizeof(int)*strlen(cQuery));
    
		finalScore = MCStringScoring_scoreStringForQueryNEW(scoredString, cQuery, indexesOfMatchedChars);
		free(indexesOfMatchedChars);
	}
  
	if (-1.0 != finalScore) {
		return [NSNumber numberWithFloat:finalScore];
	} else {
		return nil;
	}
}


// fast, without scoring
- (BOOL)matchesFuzzyQuery:(NSString *)query
{
	NSString *comparedValue = self;
	int queryIndex = 0;
	int valueIndex = 0;
	int queryLength = [query length];
	int valueLength = [comparedValue length];
	BOOL wordMatches = YES;
  
	for (; queryIndex < queryLength; queryIndex++) {
		unichar queryChar = [query characterAtIndex:queryIndex];
		BOOL charFound = NO;
		for (; valueIndex < valueLength; valueIndex++) {
			unichar valueChar = [comparedValue characterAtIndex:valueIndex];
			// lowercase matches uppercase too. uppercase matches just uppercase.
			if (queryChar == valueChar ||
          (islower(queryChar) && toupper(queryChar) == valueChar)
          ) {
				charFound = YES;
				break;
			}
		}
    
		if (!charFound) {
			wordMatches = NO;
			break;
		}
    
		valueIndex++;
	}
  
	return wordMatches;
}
@end