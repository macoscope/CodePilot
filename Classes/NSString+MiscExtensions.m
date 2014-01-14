//
//  NSString+MiscExtensions.m
//  Quark
//
//  Created by Daniel on 09-12-10.
//  Copyright 2009 Macosope. All rights reserved.
//

#import "NSString+MiscExtensions.h"
#import <openssl/sha.h>

@implementation NSString (MiscExtensions)
- (BOOL)isBlank
{
  NSRange spaceRange = [self rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]];
  return spaceRange.length == 0;
}

- (NSRange)completeRange
{
  return NSMakeRange(0, [self length]);
}

- (NSString *)hexString
{
  char hexbuf[100];
  const char *selfString = [self UTF8String];
  
  memset(hexbuf, 0, 100);
  
  for (int i = 0; i < [self length] && i < 100; i++) {
    sprintf((char *)&(hexbuf[i*2]),"%02x",selfString[i]);
	}
  
  return [NSString stringWithCString:hexbuf encoding:NSUTF8StringEncoding];
}

// this just handles singular/plural distinction in a stupid way
+ (NSString *)nounWithCount:(NSInteger)count forNoun:(NSString *)noun
{
	NSString *format;
  
	if (abs(count) != 1) {
		// s, z, x, sh, and ch
		if ([noun hasSuffix:@"s"] ||
				[noun hasSuffix:@"z"] ||
				[noun hasSuffix:@"x"] ||
				[noun hasSuffix:@"sh"] ||
				[noun hasSuffix:@"ch"]) {
			format = @"%d %@es";
		} else {
			format = @"%d %@s";
		}
	} else {
		format = @"%d %@";
	}
  
	return [NSString stringWithFormat:format, count, noun];
}
@end