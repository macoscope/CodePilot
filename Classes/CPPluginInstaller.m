//
//  CPPluginInstaller.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/23/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import "CPPluginInstaller.h"
#import "CPCodePilotPlugin.h"
#import "CPPreferencesToolbarDelegate.h"

static NSString * const IDEKeyBindingSetDidActivateNotification = @"IDEKeyBindingSetDidActivateNotification";

@implementation CPPluginInstaller
- (void)installPlugin:(CPCodePilotPlugin *)plugin
{
  self.installedPlugin = plugin;
  
  [self installKeyBinding];
  [self installMenuItem];
  
  LOG(@"%@ %@ Plugin successfully installed.", PRODUCT_NAME, PRODUCT_CURRENT_VERSION);
}

- (id)init
{
  self = [super init];
  
  if (self) {
    [self setupKeyBindingsIfNeeded];
    [self installNotificationListeners];
  }
  
  return self;
}

- (void)installNotificationListeners
{
  // listen for preferences editing FIXME/TODO - find some less insane method.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyBindingsHaveChanged:)
                                               name:IDEKeyBindingSetDidActivateNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowDidBecomeKey:)
                                               name:NSWindowDidBecomeKeyNotification
                                             object:nil];
}

- (void)removeNotificationListeners
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
  NSWindow *window = [notification object];
  
  if (nil != [window toolbar] && nil != [[window toolbar] delegate] && [[[window toolbar] delegate] isKindOfClass:[IDEPreferencesController class]]) {
    [self installPreferencePaneInToolbar:[window toolbar]];
  }
}

- (void)installPreferencePaneInToolbar:(NSToolbar *)toolbar
{
  self.toolbarDelegate = [CPPreferencesToolbarDelegate preferencesToolbarDelegateByInterceptingDelegateOfToolbar:toolbar];
}

- (void)setupKeyBindingsIfNeeded
{
  // this saves default shortcut into preferences if it's the first run and nothing is defined
  if (IsEmpty([self keyBindingFromUserDefaults])) {
    [self saveKeyBindingToUserDefaults:CP_DEFAULT_SHORTCUT forKey:DEFAULTS_KEY_BINDING];
  }
}

- (NSString *)keyBindingFromUserDefaults
{
  return [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_KEY_BINDING];
}

- (void)saveKeyBindingToUserDefaults:(NSString *)keyBinding forKey:(NSString *)defaultsKey
{
  [[NSUserDefaults standardUserDefaults] setObject:keyBinding forKey:defaultsKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

// Okay, this is lame.
// Since I couldn't figure out a way to create a proper extension points with
// proper plugin structure - we're just adding a new option called "Code Pilot"
// to the menu key bindings. Then we listen for any change that might have happened
// with IDEKeyBindingSetDidActivateNotification notification and re-read it from
// user's keybindings, to save it to NSUserDefaults where we will look to find
// a custom setup to use in Code Pilot's NSMenuItem.
//
// The right way to fix it is to find a way to use .ideplugin structure, or
// plugin plist definition (.xcplugindata or whatever it will be called) and define
// proper extension points there along with whole menu/keybinding infrastructure.
- (void)installKeyBinding
{
  [self installStandardKeyBinding];
}

- (void)installStandardKeyBinding
{
  IDEKeyBindingPreferenceSet *currentPreferenceSet = [[IDEKeyBindingPreferenceSet preferenceSetsManager] currentPreferenceSet];
  IDEMenuKeyBindingSet *menuKeyBindingSet = [currentPreferenceSet menuKeyBindingSet];
  
  IDEKeyboardShortcut *defaultShortcut = [IDEKeyboardShortcut keyboardShortcutFromStringRepresentation:[self keyBindingFromUserDefaults]];
  
  IDEMenuKeyBinding *cpKeyBinding;
  
  // older versions of Xcode 4 support another way of creating menukeybinding:
  if ([IDEMenuKeyBinding respondsToSelector:@selector(keyBindingWithTitle:group:actions:keyboardShortcuts:)]) {
    cpKeyBinding = [IDEMenuKeyBinding keyBindingWithTitle:CP_MENU_ITEM_TITLE
                                                    group:CP_KEY_BINDING_MENU_NAME
                                                  actions:[NSArray arrayWithObject:@"whatever:"]
                                        keyboardShortcuts:[NSArray arrayWithObject:defaultShortcut]];
  } else {
    cpKeyBinding = [IDEMenuKeyBinding keyBindingWithTitle:CP_MENU_ITEM_TITLE
                                              parentTitle:@"foo"
                                                    group:CP_KEY_BINDING_MENU_NAME
                                                  actions:[NSArray arrayWithObject:@"whatever:"]
                                        keyboardShortcuts:[NSArray arrayWithObject:defaultShortcut]];
  }
  
  [cpKeyBinding setCommandIdentifier:@"foo"];
  
  [menuKeyBindingSet insertObject:cpKeyBinding inKeyBindingsAtIndex:0];
  [menuKeyBindingSet updateDictionary];
}

- (IDEKeyboardShortcut *)keyboardShortcutFromUserDefaults
{
  return [IDEKeyboardShortcut keyboardShortcutFromStringRepresentation:[self keyBindingFromUserDefaults]];
}

- (void)keyBindingsHaveChanged:(NSNotification *)notification
{
  [self updateKeyBinding:[self currentUserCPKeyBinding] forMenuItem:self.menuItem defaultsKey:DEFAULTS_KEY_BINDING];
}

- (void)updateKeyBinding:(IDEKeyBinding *)keyBinding forMenuItem:(NSMenuItem *)menuItem defaultsKey:(NSString *)defaultsKey
{
  if ([[keyBinding keyboardShortcuts] count] > 0) {
    IDEKeyboardShortcut *keyboardShortcut = [[keyBinding keyboardShortcuts] objectAtIndex:0];
    [self saveKeyBindingToUserDefaults:[keyboardShortcut stringRepresentation] forKey:defaultsKey];
    [self updateMenuItem:menuItem withShortcut:keyboardShortcut];
  }
}

- (void)updateMenuItem:(NSMenuItem *)menuItem withShortcut:(IDEKeyboardShortcut *)keyboardShortcut
{
  [menuItem setKeyEquivalent:[keyboardShortcut keyEquivalent]];
  [menuItem setKeyEquivalentModifierMask:[keyboardShortcut modifierMask]];
}

// returns current key binding if it was customized by the user
- (IDEKeyBinding *)currentUserCPKeyBinding
{
  return [self menuKeyBindingWithItemTitle:CP_MENU_ITEM_TITLE underMenuCalled:CP_KEY_BINDING_MENU_NAME];
}

- (IDEKeyBinding *)menuKeyBindingWithItemTitle:(NSString *)itemTitle underMenuCalled:(NSString *)menuName
{
  IDEKeyBindingPreferenceSet *currentPreferenceSet = [[IDEKeyBindingPreferenceSet preferenceSetsManager] currentPreferenceSet];
  IDEMenuKeyBindingSet *menuKeyBindingSet = [currentPreferenceSet menuKeyBindingSet];
  
  for (IDEMenuKeyBinding *keyBinding in [menuKeyBindingSet keyBindings]) {
    if ([[keyBinding group] isEqualToString:menuName] && [[keyBinding title] isEqualToString:itemTitle]) {
      return keyBinding;
    }
  }
  
  return nil;
}

// installs "Code Pilot" menu item in "File" menu,
// setting target and action on code pilot's window delegate
- (void)installMenuItem
{
  NSMenu *fileMenu = [[[[NSApp mainMenu] itemArray] objectAtIndex:1] submenu];
  NSUInteger fileMenuItemCount = [[fileMenu itemArray] count];
  
  [fileMenu insertItem:[NSMenuItem separatorItem] atIndex:fileMenuItemCount];
  
  self.menuItem = [[NSMenuItem alloc] initWithTitle:CP_MENU_ITEM_TITLE
                                             action:@selector(openCodePilotWindow:)
                                      keyEquivalent:@""];
  
  [self.menuItem setTarget:self.installedPlugin];
  [self.menuItem setAction:@selector(openCodePilotWindow)];
  
  [self updateMenuItem:self.menuItem withShortcut:[self keyboardShortcutFromUserDefaults]];
  [fileMenu insertItem:self.menuItem atIndex:fileMenuItemCount + 1];
}

// our preferences were applied/ok'd by the user
- (void)preferencesDidChange
{
}

- (void)dealloc
{
  [self removeNotificationListeners];
}
@end
