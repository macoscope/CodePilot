//
//  CPCodePilotWindowDelegate.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPCodePilotWindowDelegate.h"
#import "CPXcodeWrapper.h"
#import "CPSearchController.h"
#import "CPResultTableView.h"
#import "CPWindow.h"
#import "CPSearchWindowView.h"
#import "CPCodePilotConfig.h"
#import "CPStatusLabel.h"
#import "CPSearchField.h"
#import "CPSearchFieldTextView.h"

@implementation CPCodePilotWindowDelegate
- (id)initWithXcodeWrapper:(CPXcodeWrapper *)xcodeWrapper
{
	self = [super init];
  
  if (self) {
    self.ourWindowIsOpen = NO;
    
    self.searchController = [CPSearchController new];
    [self.searchController setXcodeWrapper:xcodeWrapper];
    
    self.window = [[CPWindow alloc] initWithDefaultSettings];
    [self.window setDelegate:self];
    
    [self.searchController setSearchField:[self.window.searchWindowView searchField]];
    [[self.window.searchWindowView searchField] setDelegate:self.searchController];
    
    [self.searchController setIndexingProgressIndicator:[self.window.searchWindowView indexingProgressIndicator]];
    [self.searchController setUpperStatusLabel:[self.window.searchWindowView upperStatusLabel]];
    [self.searchController setLowerStatusLabel:[self.window.searchWindowView lowerStatusLabel]];
    [self.searchController setInfoStatusLabel:[self.window.searchWindowView infoStatusLabel]];
    
    [self.searchController setTableView:[self.window.searchWindowView resultTableView]];
    [[self.window.searchWindowView resultTableView] setDataSource:self.searchController];
    [[self.window.searchWindowView resultTableView] setDelegate:self.searchController];
	}
  
	return self;
}

- (void)openFirstRunWindow
{
	[self.window firstRunOrderFront];
	[self.window makeKeyWindow];
	self.ourWindowIsOpen = YES;
}

- (void)openWindow
{
	if (self.ourWindowIsOpen) {
		return;
	}
  
	[self.searchController windowWillBecomeActive];
	[self.window orderFront:self];
	[self.window makeKeyWindow];
	[self.searchController windowDidBecomeActive];
	self.ourWindowIsOpen = YES;
}

- (void)hideWindow
{
	[self.window orderOut:self];
	self.ourWindowIsOpen = NO;
}

// we need custom field editor in order to work with search field the way we want
- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
	if ([anObject isKindOfClass:[CPSearchField class]]) {
		if (!self.searchFieldTextEditor) {
			self.searchFieldTextEditor = [[CPSearchFieldTextView alloc] init];
			[self.searchFieldTextEditor setFieldEditor:YES];
		}
		return self.searchFieldTextEditor;
	}
	return nil;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	[self hideWindow];
}

- (void)windowDidResignMain:(NSNotification *)notification
{
}

- (void)windowWillClose:(NSNotification *)notification
{
}
@end