//
//  CPPreferencesToolbarDelegate.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 4/23/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import "CPPreferencesToolbarDelegate.h"
#import "CPPreferencesViewController.h"
#import "CPPreferencesView.h"

static NSString * const SelectedItemIdentifierKeyPath = @"selectedItemIdentifier";

@interface CPPreferencesToolbarDelegate ()
@property (nonatomic, strong) IDEPreferencesController *originalDelegate;
@property (nonatomic, strong) NSToolbarItem *ourToolbarItem;
@property (nonatomic, strong) CPPreferencesViewController *ourViewController;

@property (nonatomic, assign) CGFloat previousReplacementViewHeight;
@property (nonatomic, strong) NSString *previousItemIdentifier;
@end

// this is kind of a proxy from IDEToolbar when used for preferences.
// it passes all the messages defined in toolbar protocol to proper
// object, adding custom items in the passing.
@implementation CPPreferencesToolbarDelegate

+ (CPPreferencesToolbarDelegate *)preferencesToolbarDelegateByInterceptingDelegateOfToolbar:(NSToolbar *)toolbar
{
  CPPreferencesToolbarDelegate *toolbarDelegate;
  IDEPreferencesController *originalToolbarDelegate = (IDEPreferencesController *)[toolbar delegate];
  
  toolbarDelegate = [[CPPreferencesToolbarDelegate alloc] initWithOriginalToolbarDelegate:originalToolbarDelegate toolbar:toolbar];
  
  [toolbar setDelegate:toolbarDelegate];
  [toolbar insertItemWithItemIdentifier:PREFERENCES_TOOLBAR_ITEM_IDENTIFIER atIndex:toolbar.items.count];
  
  return toolbarDelegate;
}

- (id)initWithOriginalToolbarDelegate:(IDEPreferencesController *)originalDelegate toolbar:(NSToolbar *)toolbar
{
  self = [super init];
  
  if (self) {
    self.originalDelegate = originalDelegate;
    
    [toolbar addObserver:self
              forKeyPath:SelectedItemIdentifierKeyPath
                 options:NSKeyValueObservingOptionInitial
                 context:nil];
    
    self.ourViewController = [[CPPreferencesViewController alloc] init];
    
    // apply changes in the controller
    [[NSNotificationCenter defaultCenter] addObserver:self.ourViewController
                                             selector:@selector(applyChanges)
                                                 name:NSWindowWillCloseNotification
                                               object:self.originalDelegate.paneReplacementView.window];
    
    [self prepareToolbarItem];
  }
  
  return self;
}

- (void)dealloc
{
  [[self.ourToolbarItem toolbar] removeObserver:self forKeyPath:SelectedItemIdentifierKeyPath];
  [[self.ourToolbarItem toolbar] setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self.ourViewController];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSToolbar *)toolbar change:(NSDictionary *)change context:(void *)context
{
  // bring back the original replacement view, once we're out of Code Pilot pref pane
  DVTReplacementView *replacementView = [self.originalDelegate paneReplacementView];
  NSWindow *window = [replacementView window];
  
  if ([replacementView isHidden]) {
    [self.ourViewController applyChanges];
    [self.ourViewController.view removeFromSuperview];
    
    // The automatic resizing is only applied when the DVTExtension changes
    if ([self.previousItemIdentifier isEqualToString:[toolbar selectedItemIdentifier]]) {
      CGRect newWindowFrame = window.frame;
      newWindowFrame.size.height += self.previousReplacementViewHeight - self.ourViewController.view.frame.size.height;
      newWindowFrame.origin.y -= self.previousReplacementViewHeight - self.ourViewController.view.frame.size.height;
      
      [window setFrame:newWindowFrame display:YES animate:YES];
      
      // To prevent the previous replacement subviews from being shown during the automatic resize animation
    } else {
      for (NSView *subview in [replacementView subviews]) {
        [subview removeFromSuperview];
      }
    }
    
    [replacementView setHidden:NO];
  }
  
  if (![[toolbar selectedItemIdentifier] isEqualToString:PREFERENCES_TOOLBAR_ITEM_IDENTIFIER]) {
    self.previousItemIdentifier = [toolbar selectedItemIdentifier];
  }
}

- (void)prepareToolbarItem
{
  self.ourToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PREFERENCES_TOOLBAR_ITEM_IDENTIFIER];
  NSString *iconPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"CodePilotIcon" ofType:@"icns"];
  NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
  
  [self.ourToolbarItem setImage:icon];
  [self.ourToolbarItem setLabel:PRODUCT_NAME];
  [self.ourToolbarItem setPaletteLabel:PRODUCT_NAME];
  [self.ourToolbarItem setEnabled:YES];
  [self.ourToolbarItem setToolTip:PRODUCT_NAME];
  [self.ourToolbarItem setTarget:self];
  [self.ourToolbarItem setAction:@selector(ourItemWasSelected:)];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  if ([itemIdentifier isEqualToString:[self.ourToolbarItem itemIdentifier]]) {
    return self.ourToolbarItem;
  }
  
  if (nil != self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:)]) {
    return [self.originalDelegate toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
  }
  
  return nil;
}

- (void)ourItemWasSelected:(id)sender
{
  DVTReplacementView *replacementView = [self.originalDelegate paneReplacementView];
  NSWindow *window = [replacementView window];
  
  self.previousReplacementViewHeight = replacementView.frame.size.height;
  
  CGRect newWindowFrame = window.frame;
  newWindowFrame.size.height -= replacementView.frame.size.height - self.ourViewController.view.frame.size.height;
  newWindowFrame.origin.y += replacementView.frame.size.height - self.ourViewController.view.frame.size.height;
  
  [window setTitle:PRODUCT_NAME];
  [window setFrame:newWindowFrame display:YES animate:YES];
  
  [replacementView setHidden:YES];
  [self.ourViewController.view setFrame:(CGRect) {replacementView.frame.origin, CGSizeMake(replacementView.frame.size.width, [CPPreferencesView preferredHeight])}];
  [[replacementView superview] addSubview:self.ourViewController.view];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  if (nil != self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(toolbarAllowedItemIdentifiers:)]) {
    NSArray *itemIdentifiers = [self.originalDelegate toolbarAllowedItemIdentifiers:toolbar];
    return [itemIdentifiers arrayByAddingObject:[self.ourToolbarItem itemIdentifier]];
  }
  
  return nil;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
  if (nil != self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(toolbarDefaultItemIdentifiers:)]) {
    NSArray *itemIdentifiers = [self.originalDelegate toolbarDefaultItemIdentifiers:toolbar];
    return [itemIdentifiers arrayByAddingObject:[self.ourToolbarItem itemIdentifier]];
  }
  
  return nil;
}


- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
  if (nil != self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(toolbarDidRemoveItem:)]) {
    [self.originalDelegate toolbarDidRemoveItem:notification];
  }
}


- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
  if (nil != self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(toolbarSelectableItemIdentifiers:)]) {
    NSArray *itemIdentifiers = [self.originalDelegate toolbarSelectableItemIdentifiers:toolbar];
    return [itemIdentifiers arrayByAddingObject:[self.ourToolbarItem itemIdentifier]];
  }
  
  return nil;
}


- (void)toolbarWillAddItem:(NSNotification *)notification
{
  if (nil != self.originalDelegate && [self.originalDelegate respondsToSelector:@selector(toolbarWillAddItem:)]) {
    [self.originalDelegate toolbarWillAddItem:notification];
  }
}
@end