//
//  CPFirstRunWindowView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/19/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPFirstRunWindowView.h"
#import "CPCodePilotConfig.h"

@implementation CPFirstRunWindowView
- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
  
	if (self) {
		[self.infoLabel setStringValue:FIRST_RUN_INFO_STRING];
	}
  
	return self;
}
@end
