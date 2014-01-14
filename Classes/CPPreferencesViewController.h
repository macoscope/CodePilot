//
//  CPPreferencesViewController.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 4/26/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPPreferencesView;

@interface CPPreferencesViewController : NSObject
@property (nonatomic, strong) CPPreferencesView *view;

- (void)setupFromDefaults;
- (void)applyChanges;
@end
