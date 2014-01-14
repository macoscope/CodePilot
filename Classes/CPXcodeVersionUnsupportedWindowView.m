//
//  XcodeVersionUnsupportedWindowView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/19/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPXcodeVersionUnsupportedWindowView.h"
#import "CPCodePilotConfig.h"

@implementation CPXcodeVersionUnsupportedWindowView
- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    self.infoLabel.stringValue = CURRENT_XCODE_VERSION_UNSUPPORTED_INFO_STRING;
    self.infoLabel.clickUrl = [NSURL URLWithString:PRODUCT_BUY_LINK];
    self.clickUrl = [NSURL URLWithString:PRODUCT_BUY_LINK];
  }
  
  return self;
}
@end
