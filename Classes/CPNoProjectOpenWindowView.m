//
//  NoProjectOpenWindowView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/19/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPNoProjectOpenWindowView.h"
#import "CPCodePilotConfig.h"

@implementation CPNoProjectOpenWindowView
- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self.infoLabel setStringValue:NO_PROJECT_OPEN_INFO_STRING];
  }
  
  return self;
}
@end
