
// this is general config used for every xcode version we support.

#import <Cocoa/Cocoa.h>
#import "MCCommons.h"
#import "MCLog.h"
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import "CPCodePilotPlugin.h"
#import "NSView+AllSubviews.h"
#import "NSString+Abbreviation.h"
#import "CPCodePilotWindowDelegate.h"
#import "NSNumber+VersionComparison.h"

#undef DEBUG_MODE

#define XCODE_VERSION_CHECKING_DISABLED 1

#define PRODUCT_NAME @"Code Pilot"
#define PRODUCT_NAME_FOR_UPDATES @"codepilot3"
#define PREFERENCES_TOOLBAR_ITEM_IDENTIFIER @"codepilot3"
#define PRODUCT_CURRENT_VERSION [[[NSBundle bundleForClass:NSClassFromString(@"CPCodePilotPlugin")] infoDictionary] valueForKey:@"CFBundleShortVersionString"]


#define CP_MENU_ITEM_TITLE       PRODUCT_NAME
#define CP_DEFAULT_SHORTCUT      @"$@X" // for key binding system
#define CP_DEFAULT_MENU_SHORTCUT @"X"   // just for the menuitem
#define CP_KEY_BINDING_MENU_NAME @"File Menu"

#define DEFAULT_KEY_EQUIVALENT @"X"

#define MAX_OBJECT_COUNT_FOR_SORT_AND_FILTER 4989

#define DOCUMENTATION_MODE [[CPCodePilotPlugin sharedInstance] isInDocumentationMode]

#define NO_PROJECT_OPEN_INFO_STRING [NSString stringWithFormat:@"%@ %@ works with projects only.\n\nOpen some project first!", PRODUCT_NAME, PRODUCT_CURRENT_VERSION]
#define CURRENT_XCODE_VERSION_UNSUPPORTED_INFO_STRING [NSString stringWithFormat:@"Xcode %@ isn't supported in %@ %@.\n\nClick here to upgrade!", CURRENT_XCODE_VERSION_STRING, PRODUCT_NAME, PRODUCT_CURRENT_VERSION]
#define FIRST_RUN_INFO_STRING [NSString stringWithFormat:@"Thanks for installing %@ %@!\nOpen some project and press \u21d1\u2318X to start!", PRODUCT_NAME, PRODUCT_CURRENT_VERSION]
#define TOO_MANY_RESULTS_STRING @"Gosh, so many results! Please try to be more specific."

#define CURRENT_XCODE_VERSION_STRING [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]
#define CURRENT_XCODE_VERSION [NSNumber numberWithVersionString:CURRENT_XCODE_VERSION_STRING]
#define CURRENT_XCODE_REVISION [NSNumber numberWithVersionNumber:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]]

#define NO_PROJECT_IS_CURRENTLY_OPEN (![[[CPCodePilotPlugin sharedInstance] xcWrapper] hasOpenWorkspace])

#define PRODUCT_BUY_LINK @"http://codepilot.cc"


#define CREDITS_STRING @"AMIndeterminateProgressIndicatorCell - Copyright © 2007 Andreas Mayer\nQSSmallScroller - Copyright © 2007-2008 Google Inc. All rights reserved\nRegexKitLite - Copyright © 2008-2009 John Engelhart"
#define THANKS_STRING @"Ruben Bakker, Marcus S. Zarra";

#define PILOT_WINDOW_DELEGATE (CPCodePilotWindowDelegate *)[[CPCodePilotPlugin sharedInstance] windowDelegate]
#define USER_LEVEL_DEBUG [[CPCodePilotPlugin sharedInstance] isUserLevelDebugOn]
#define OUR_WINDOW_IS_OPEN [PILOT_WINDOW_DELEGATE ourWindowIsOpen]


#define CORNER_RADIUS 20
#define BACKGROUND_COLOR [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.851]

#define FILE_SELECTION_CELL_FONT_NAME @"Helvetica"
#define FILE_SELECTION_CELL_FONT_SIZE 18

#define SYMBOL_SELECTION_CELL_FONT_NAME FILE_SELECTION_CELL_FONT_NAME
#define SYMBOL_SELECTION_CELL_FONT_SIZE FILE_SELECTION_CELL_FONT_SIZE

#define SYMBOL_SELECTION_CELL_EXTENDED_INFO_FONT_NAME @"Monaco"
#define SYMBOL_SELECTION_CELL_EXTENDED_INFO_FONT_SIZE 12

#define FILE_SELECTION_CELL_EXTENDED_INFO_FONT_NAME @"Monaco"
#define FILE_SELECTION_CELL_EXTENDED_INFO_FONT_SIZE 12
#define FILE_SELECTION_CELL_FONT_COLOR [NSColor colorWithCalibratedWhite:0.657 alpha:1.000]
#define FILE_SELECTION_CELL_HIGHLIGHTED_FONT_COLOR [NSColor whiteColor]

#define FILE_SELECTION_CELL_HEIGHT FILE_SELECTION_CELL_FONT_SIZE*1.7
#define SYMBOL_SELECTION_CELL_HEIGHT SYMBOL_SELECTION_CELL_FONT_SIZE*1.7

#define SYMBOL_SELECTION_CELL_EXTENDED_HEIGHT (SYMBOL_SELECTION_CELL_FONT_SIZE+SYMBOL_SELECTION_CELL_EXTENDED_INFO_FONT_SIZE)*1.7
#define SYMBOL_SELECTION_CELL_EXTENDED_INFO_COLOR [NSColor lightGrayColor]
#define SYMBOL_SELECTION_CELL_HIGHLIGHTED_EXTENDED_INFO_COLOR [NSColor whiteColor]

#define FILE_SELECTION_CELL_EXTENDED_HEIGHT (FILE_SELECTION_CELL_FONT_SIZE+FILE_SELECTION_CELL_EXTENDED_INFO_FONT_SIZE)*1.7
#define FILE_SELECTION_CELL_EXTENDED_INFO_COLOR [NSColor lightGrayColor]

// how far from the top the window will be located
// 0.2 means - 1/5 of screensize from the menu bar.
#define WINDOW_TOP_LOCATION_ON_THE_SCREEN		0.2

// more defined in cpsearchwindowview.h
#define WINDOW_WIDTH												500.0f
#define WINDOW_MARGIN											  10.0f
#define PROGRESS_INDICATOR_HEIGHT           15.0f
#define PROGRESS_INDICATOR_WIDTH            15.0f
#define PROGRESS_INDICATOR_RIGHT_MARGIN     15.0f

#define WINDOW_CONTROL_WIDTH                (WINDOW_WIDTH-(2*WINDOW_MARGIN))

#define MAX_TABLE_HEIGHT										400.0f

#define WINDOW_INFO_LABEL_UNREGISTERED_FONT_COLOR [NSColor lightGrayColor]
#define WINDOW_INFO_LABEL_NEW_VERSION_AVAILABLE_FONT_COLOR [NSColor whiteColor]

#define SYMBOL_OTHER_NAME_COLOR             [NSColor lightGrayColor]

#define TABLE_ROW_HIGHLIGHT_COLOR						[NSColor colorWithDeviceWhite:0.25 alpha:0.95]

#define RESULT_CELL_FILE_ICON_WIDTH				  	35.0f
#define RESULT_CELL_FILE_EXTENDED_ICON_WIDTH  55.0f
#define RESULT_CELL_SYMBOL_ICON_WIDTH           RESULT_CELL_FILE_ICON_WIDTH + 3
#define RESULT_CELL_SYMBOL_EXTENDED_ICON_WIDTH	RESULT_CELL_FILE_EXTENDED_ICON_WIDTH + 2
#define RESULT_CELL_ICON_LEFT_MARGIN        	9.0f

#define SEARCHFIELD_FONT                    @"Lucida Grande"
#define SEARCHFIELD_FONT_SIZE														18
#define SEARCHFIELD_FONT_COLOR							[NSColor whiteColor]
#define SEARCHFIELD_TOKEN_FONT							@"Lucida Grande"
#define SEARCHFIELD_TOKEN_CORNER_RADIUS     10
#define SEARCHFIELD_TOKEN_FONT_SIZE					18
#define SEARCHFIELD_TOKEN_FONT_COLOR				[NSColor colorWithCalibratedRed:0.221 green:0.221 blue:0.22 alpha:1.000]
#define SEARCHFIELD_TOKEN_BACKGROUND_COLOR	[NSColor colorWithCalibratedRed:0.654 green:0.654 blue:0.654 alpha:1.000]
#define SEARCHFIELD_TOKEN_BORDER_COLOR			[NSColor colorWithCalibratedRed:0.523 green:0.523 blue:0.523 alpha:1.000]
#define SEARCHFIELD_TOKEN_INSIDE_MARGIN     4

#define SEARCHFIELD_PLACEHOLDER_STRING      @"Type your query to find files and symbols"
#define SEARCHFIELD_PLACEHOLDER_FONT_SIZE   16
#define SEARCHFIELD_PLACEHOLDER_FONT        @"Helvetica" // Grande version doesn't have native italic version
#define SEARCHFIELD_PLACEHOLDER_ALTERNATIVE_FONT        @"Lucida Grande" // Lucida Grande isn't supported on fresh systems
#define SEARCHFIELD_PLACEHOLDER_FONT_COLOR  [NSColor colorWithCalibratedRed:0.631 green:0.631 blue:0.631 alpha:0.75]

#define DEFAULT_SEARCHFIELD_DELAY_VALUE																	0.4

// how often do we check whether index is ready and if we need to reload symbol table
#define INDEX_STATE_CHECK_INTERVAL																						0.5

// #define PRESERVE_SELECTION									1

#define MCXcodeWrapperReloadedIndex          @"__MCXcodeWrapperReloadedIndex"

// Preferences - system fonts are used here
#define PREFS_CREDITS_TEXT_FONT_SIZE               				11

#define PREFS_VIEW_MIN_WIDTH                              630
#define PREFS_VIEW_MIN_HEIGHT                             230

#define DEFAULTS_AUTOCOPY_SELECTION_KEY										@"MCCodePilotAutocopySelection"
#define DEFAULTS_EXTERNAL_EDITOR_KEY                      @"MCCodePilotUseExternalEditor"
#define DEFAULTS_API_SEARCH_KEY										        @"MCCodePilotAPISearch"
#define DEFAULTS_LAST_VERSION_RUN_KEY                     @"MCCodePilotLastVersionRun"
#define DEFAULTS_USER_LEVEL_DEBUG_KEY											@"MCCodePilotUserLevelDebug"
#define DEFAULTS_SEARCH_INTERVAL_KEY                      @"MCCodePilotSearchFieldDelay" // in seconds
#define DEFAULTS_INCLUDE_SUBPROJECTS_KEY                  @"MCCodePilotIncludeSubprojects"
#define DEFAULTS_KEY_BINDING                              @"MCCodePilotKeyBinding"

#define DEFAULT_INCLUDE_SUBPROJECTS_VALUE																NO
#define DEFAULT_AUTOCOPY_SELECTION_VALUE																NO
#define DEFAULT_EXTERNAL_EDITOR_SELECTION_VALUE											   	NO
#define DEFAULT_API_SEARCH_VALUE                                        YES

// longest string we accept in autocopying from current editor's selection
#define MAX_AUTOCOPY_STRING_LENGTH                                      100

#define IS_THIS_NEW_VERSION_FIRST_RUN                    [[CPCodePilotPlugin sharedInstance] thisVersionFirstRun]
#define IS_THIS_FIRST_RUN_EVER                           [[CPCodePilotPlugin sharedInstance] firstRunEver]

#define INFO_WINDOW_WIDTH                                360
#define INFO_WINDOW_HEIGHT                               133

#define __OPEN_CODE_PILOT_WINDOW @"openCodePilotWindow"

#define USER_LOG(s, ...) do{if(USER_LEVEL_DEBUG){[MCLog prefix:[NSString stringWithFormat:@"%@ %@", PRODUCT_NAME, PRODUCT_CURRENT_VERSION] format:(s),##__VA_ARGS__];}}while(0)

#define LOG_TIMESTAMP_SINCE(msg, ddd) NSLog([NSString stringWithFormat:@"[TS] %0.2fs %@", [[NSDate date] timeIntervalSinceDate:ddd], msg])
