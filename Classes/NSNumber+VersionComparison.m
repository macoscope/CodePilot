//
//  NSNumber+VersionComparison.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/19/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "NSNumber+VersionComparison.h"

@implementation NSNumber (VersionComparison)
+ (NSNumber *)numberWithVersionString:(NSString *)versionString
{
	NSArray *parts = [versionString componentsSeparatedByString:@"."];
  
	long bigNumber = 0;
	long powerOfTheMultiplier = 9;
  
	for (NSString *part in parts) {
		NSInteger partInt = [part integerValue];
    
		if (partInt > 0) {
			bigNumber += partInt * pow(10, powerOfTheMultiplier);
		}
    
		powerOfTheMultiplier -= 2;
	}
  
	return [NSNumber numberWithVersionLong:bigNumber];
}

+ (NSNumber *)numberWithVersionLong:(long)versionLong
{
	return [NSNumber numberWithLong:versionLong];
}

+ (NSNumber *)numberWithVersionInt:(NSInteger)versionInt
{
	return [NSNumber numberWithInt:versionInt];
}

+ (NSNumber *)numberWithVersionNumber:(NSNumber *)n
{
	return [NSNumber numberWithInt:[n intValue]];
}
@end
