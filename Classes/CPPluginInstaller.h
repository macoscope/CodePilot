//
//  CPPluginInstaller.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/23/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPCodePilotPlugin, SUUpdater, CPPreferencesToolbarDelegate;

@interface CPPluginInstaller : NSObject
@property (nonatomic, strong) CPCodePilotPlugin *installedPlugin;
@property (nonatomic, strong) NSMenuItem *menuItem;
@property (nonatomic, strong) CPPreferencesToolbarDelegate *toolbarDelegate;

- (void)installPlugin:(CPCodePilotPlugin *)plugin;

- (void)installKeyBinding;
- (void)installMenuItem;

- (void)preferencesDidChange;

- (IDEKeyBinding *)currentUserCPKeyBinding;
- (void)keyBindingsHaveChanged:(NSNotification *)notification;
- (void)installNotificationListeners;
- (void)removeNotificationListeners;
- (void)setupKeyBindingsIfNeeded;
- (NSString *)keyBindingFromUserDefaults;
- (IDEKeyboardShortcut *)keyboardShortcutFromUserDefaults;
- (void)saveKeyBindingToUserDefaults:(NSString *)keyBinding forKey:(NSString *)defaultsKey;
- (void)updateMenuItem:(NSMenuItem *)menuItem withShortcut:(IDEKeyboardShortcut *)keyboardShortcut;
- (void)installPreferencePaneInToolbar:(NSToolbar *)toolbar;

- (void)installStandardKeyBinding;
- (IDEKeyBinding *)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName;
- (void)updateKeyBinding:(IDEKeyBinding *)keyBinding forMenuItem:(NSMenuItem *)_menuItem defaultsKey:(NSString *)defaultsKey;
@end