//
//  CPPreferencesToolbarDelegate.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 4/23/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEPreferencesController, CPPreferencesViewController;

@interface CPPreferencesToolbarDelegate : NSObject<NSToolbarDelegate>
+ (CPPreferencesToolbarDelegate *)preferencesToolbarDelegateByInterceptingDelegateOfToolbar:(NSToolbar *)toolbar;

- (id)initWithOriginalToolbarDelegate:(IDEPreferencesController *)_originalDelegate toolbar:(NSToolbar *)toolbar;
- (void)prepareToolbarItem;
- (void)ourItemWasSelected:(id)sender;
@end
