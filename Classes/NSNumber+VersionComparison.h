//
//  NSNumber+VersionComparison.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/19/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSNumber (VersionComparison)
+ (NSNumber *)numberWithVersionString:(NSString *)versionString;
+ (NSNumber *)numberWithVersionInt:(NSInteger)versionInt;
+ (NSNumber *)numberWithVersionNumber:(NSNumber *)n;
+ (NSNumber *)numberWithVersionLong:(long)versionLong;
@end
