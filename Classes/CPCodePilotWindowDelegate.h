//
//  CPCodePilotWindowDelegate.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CPWindow;
@class CPSearchController;
@class CPSearchFieldTextView;

@interface CPCodePilotWindowDelegate : NSObject <NSWindowDelegate>
@property (nonatomic, strong) IBOutlet CPWindow *window;
@property (nonatomic, strong) IBOutlet CPSearchController *searchController;
@property (nonatomic, assign) BOOL ourWindowIsOpen;
@property (nonatomic, strong) CPSearchFieldTextView *searchFieldTextEditor;

- (id)initWithXcodeWrapper:(CPXcodeWrapper *)xcodeWrapper;

- (void)openWindow;
- (void)hideWindow;
- (void)openFirstRunWindow;
@end
