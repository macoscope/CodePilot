//
//  CPPreferencesViewController.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 4/26/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import "CPPreferencesViewController.h"
#import "CPPreferencesView.h"

@implementation CPPreferencesViewController
- (id)init
{
  self = [super init];
  
  if (self) {
    self.view = [[CPPreferencesView alloc] initWithPreferredFrame];
  }
  
  return self;
}

- (void)setupFromDefaults
{
}

- (void)applyChanges
{
  BOOL autocopySelectionValue = [self.view.autocopyingSelectionCheckbox state];
  [[NSUserDefaults standardUserDefaults] setBool:autocopySelectionValue forKey:DEFAULTS_AUTOCOPY_SELECTION_KEY];
}

@end