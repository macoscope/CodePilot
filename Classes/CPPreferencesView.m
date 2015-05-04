//
//  CPPreferencesView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/10/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPPreferencesView.h"
#import "CPCodePilotConfig.h"

static const CGFloat PreferredViewWidth = 750.0f;
static const CGFloat PreferredViewHeight = 250.0f;
static const CGFloat Margin = 24;
static const CGFloat LeftSideWidth = 200;
static const CGFloat RightSideWidth = 420;
static const CGFloat TextHeight = 16;

@implementation CPPreferencesView
- (id)initWithPreferredFrame
{
  return [self initWithFrame:NSMakeRect(0.0f, 0.0f, PreferredViewWidth, PreferredViewHeight)];
}

- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self setAutoresizingMask:NSViewNotSizable];
    
    [self setupAutoCopyingSelectionOption];
    [self setupCopyrightLabel];
    [self setupCreditsAndThanksLabels];
    [self setupSeparatorView];
  }
  
  return self;
}

- (void)setupAutoCopyingSelectionOption
{
  NSButton *autocopyingSelectionCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(Margin, Margin, LeftSideWidth, TextHeight)];
  
  autocopyingSelectionCheckbox.title = @"Auto-search for selected text";
  autocopyingSelectionCheckbox.font = [self boldFont];
  [autocopyingSelectionCheckbox setButtonType:NSSwitchButton];
  
  
  if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_AUTOCOPY_SELECTION_KEY]) {
    [autocopyingSelectionCheckbox setState:DEFAULT_AUTOCOPY_SELECTION_VALUE];
  } else {
    [autocopyingSelectionCheckbox setState:[[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_AUTOCOPY_SELECTION_KEY]];
  }
  
  [autocopyingSelectionCheckbox sizeToFit];
  
  self.autocopyingSelectionCheckbox = autocopyingSelectionCheckbox;
  
  [self addSubview:autocopyingSelectionCheckbox];
  
  NSButton *externalEditorCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(Margin, Margin*1.5 + autocopyingSelectionCheckbox.bounds.size.height, LeftSideWidth, TextHeight)];
  
  externalEditorCheckbox.title = @"Use external editor";
  externalEditorCheckbox.font = [self boldFont];
  [externalEditorCheckbox setButtonType:NSSwitchButton];
  
  if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_EXTERNAL_EDITOR_KEY]) {
    [externalEditorCheckbox setState:DEFAULT_EXTERNAL_EDITOR_SELECTION_VALUE];
  } else {
    [externalEditorCheckbox setState:[[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_EXTERNAL_EDITOR_KEY]];
  }
  
  [externalEditorCheckbox sizeToFit];
  
  self.externalEditorCheckbox = externalEditorCheckbox;
  
  [self addSubview:externalEditorCheckbox];
}

- (void)setupCopyrightLabel
{
  CGFloat left = self.frame.size.width - Margin - RightSideWidth;
  NSTextField *copyrightLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(left, Margin, RightSideWidth, TextHeight)];
  
  copyrightLabel.stringValue = [NSString stringWithFormat:@"%@ %@ © 2014 Macoscope Sp. z o.o. All rights reserved.\nhttp://macoscope.com", PRODUCT_NAME, PRODUCT_CURRENT_VERSION];
  copyrightLabel.font = [self boldFont];
  copyrightLabel.bordered = NO;
  copyrightLabel.editable = NO;
  copyrightLabel.backgroundColor = [NSColor clearColor];
 
  [copyrightLabel sizeToFit];
  
  [self addSubview:copyrightLabel];
}

- (void)setupCreditsAndThanksLabels
{
  CGFloat left = self.frame.size.width - Margin - RightSideWidth;
  
  NSTextField *firstCreditsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(left, Margin + TextHeight + Margin, RightSideWidth, TextHeight)];
  
  firstCreditsLabel.stringValue = @"Credits:";
  firstCreditsLabel.font = [self boldFont];
  firstCreditsLabel.bordered = NO;
  firstCreditsLabel.editable = NO;
  firstCreditsLabel.backgroundColor = [NSColor clearColor];
  
  [firstCreditsLabel sizeToFit];
  
  NSTextField *secondCreditsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(left, CGRectGetMaxY(firstCreditsLabel.frame), RightSideWidth, 10 * TextHeight)];
  
  secondCreditsLabel.stringValue = CREDITS_STRING;
  secondCreditsLabel.font = [self font];
  secondCreditsLabel.bordered = NO;
  secondCreditsLabel.editable = NO;
  secondCreditsLabel.backgroundColor = [NSColor clearColor];
  
  [secondCreditsLabel sizeToFit];
  
  NSTextField *firstThanksLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(left, CGRectGetMaxY(secondCreditsLabel.frame) + Margin, RightSideWidth, TextHeight)];
  
  firstThanksLabel.stringValue = @"Thanks:";
  firstThanksLabel.font = [self boldFont];
  firstThanksLabel.bordered = NO;
  firstThanksLabel.editable = NO;
  firstThanksLabel.backgroundColor = [NSColor clearColor];
  
  [firstThanksLabel sizeToFit];
  
  NSTextField *secondThanksLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(left, CGRectGetMaxY(firstThanksLabel.frame), RightSideWidth, TextHeight)];
  
  secondThanksLabel.stringValue = THANKS_STRING;
  secondThanksLabel.font = [self font];
  secondThanksLabel.bordered = NO;
  secondThanksLabel.editable = NO;
  secondThanksLabel.backgroundColor = [NSColor clearColor];
  
  [secondThanksLabel sizeToFit];
  
  [self addSubview:firstCreditsLabel];
  [self addSubview:secondCreditsLabel];
  [self addSubview:firstThanksLabel];
  [self addSubview:secondThanksLabel];
}

- (void)setupSeparatorView
{
  CGFloat position = Margin + LeftSideWidth + (self.frame.size.width - 2 * Margin - RightSideWidth - LeftSideWidth) / 2;
  
  NSView *separatorView = [[NSView alloc] initWithFrame:CGRectMake(position, self.frame.size.height * 0.1, 1, self.frame.size.height * 0.8)];
  [separatorView setWantsLayer:YES];
  separatorView.layer.backgroundColor = [[NSColor colorWithCalibratedRed:0.537 green:0.537 blue:0.537 alpha:1] CGColor];
  
  [self addSubview:separatorView];
}

- (NSFont *)boldFont
{
  return [NSFont fontWithName:@"Helvetica-Bold" size:[self fontSize]];
}

- (NSFont *)font
{
  return [NSFont fontWithName:@"Helvetica" size:[self fontSize]];
}

- (CGFloat)fontSize
{
  return [NSFont systemFontSize];
}

- (BOOL)isFlipped
{
  return YES;
}

+ (CGFloat)preferredWidth
{
  return PreferredViewWidth;
}

+ (CGFloat)preferredHeight
{
  return PreferredViewHeight;
}

@end