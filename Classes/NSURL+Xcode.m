//
//  NSURL+Xcode.m
//  CodePilot
//
//  Created by Fjölnir Ásgeirsson on 2/2/14.
//  Copyright (c) 2014 Macoscope. All rights reserved.
//

#import "NSURL+Xcode.h"

@implementation NSURL (Xcode)

- (BOOL)cp_opensInXcode
{
  NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:self];
  if(appURL) {
    NSBundle *appBundle   = [NSBundle bundleWithURL:appURL];
    NSBundle *xcodeBundle = [NSBundle mainBundle];
    return [appBundle.bundleIdentifier isEqualToString:xcodeBundle.bundleIdentifier];
  }
  return NO;
}
@end
