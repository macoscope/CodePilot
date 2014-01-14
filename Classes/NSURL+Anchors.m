//
//  NSURL+Anchors.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 6/20/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import "NSURL+Anchors.h"

@implementation NSURL (Anchors)
- (NSString *)pathWithoutAnchor
{
  return [[[self path] componentsSeparatedByString:@"#"] objectAtIndex:0];
}
@end
