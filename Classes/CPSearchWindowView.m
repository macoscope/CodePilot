//
//  CPSearchWindowView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/14/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPSearchWindowView.h"
#import "CPCodePilotConfig.h"
#import "CPResultTableView.h"
#import "CPStatusLabel.h"
#import "CPWindow.h"
#import "QSBSmallScroller.h"
#import "CPSearchField.h"
#import "CPResultScrollView.h"

#import "AMIndeterminateProgressIndicatorCell.h"

#define ZERO_IF_VIEW_IS_HIDDEN(view, valueIfNotHidden) ([view isHidden] ? 0 : valueIfNotHidden)
#define MAX_Y_PLUS_TOPMARGIN(view, topmargin) (NSMaxY(view.frame) + ZERO_IF_VIEW_IS_HIDDEN(view, topmargin))
#define DEFAULT_RECT NSMakeRect(10, 10, WINDOW_CONTROL_WIDTH, 10)

@implementation CPSearchWindowView
- (CPSearchWindowView *)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
  
  if (self) {
    self.cornerRadius = CORNER_RADIUS;
    self.backgroundColor = [NSColor clearColor];
    self.documentationViewOn = NO;
    
    [self setupSearchField];
    [self setupUpperStatusLabel];
    [self setupLowerStatusLabel];
    [self setupIndexingProgressIndicator];
    [self setupResultTableScrollViewAndResultTableView]; // must be called after setupResultTableView
    [self setupInfoLabel];
    
    [self loadUIElements];
    
    [self layoutSubviews];
  }
  
	return self;
}

- (void)setupInfoLabel
{
	self.infoStatusLabel = [[CPStatusLabel alloc] initWithFrame:DEFAULT_RECT];
	[self.infoStatusLabel setAlignment:NSCenterTextAlignment];
	[self addSubview:self.infoStatusLabel];
}

- (void)setupResultTableView
{
}

- (void)setupSearchField
{
	// this rect here must be of proper size, because if contains placeholer label which we don't
	// want to care resizing
  self.searchField = [[CPSearchField alloc] initWithFrame:NSMakeRect(0, 0, WINDOW_CONTROL_WIDTH, WINDOW_SEARCHFIELD_HEIGHT)];
	[self addSubview:self.searchField];
}

- (void)setupUpperStatusLabel
{
  self.upperStatusLabel = [[CPStatusLabel alloc] initWithFrame:DEFAULT_RECT];
	[self.upperStatusLabel setAlignment:NSLeftTextAlignment];
	[self addSubview:self.upperStatusLabel];
}

- (void)setupLowerStatusLabel
{
  self.lowerStatusLabel = [[CPStatusLabel alloc] initWithFrame:DEFAULT_RECT];
	[self.lowerStatusLabel setAlignment:NSRightTextAlignment];
	[self addSubview:self.lowerStatusLabel];
}

- (void)setupResultTableScrollViewAndResultTableView
{
  self.resultTableView = [[CPResultTableView alloc] initWithFrame:DEFAULT_RECT];
  self.resultTableScrollView = [[CPResultScrollView alloc] initWithFrame:self.resultTableView.frame];
  [self.resultTableScrollView setDrawsBackground:NO];
  [self.resultTableScrollView setDocumentView:self.resultTableView];
  [self.resultTableScrollView setHasVerticalScroller:YES];
  [self.resultTableScrollView setAutohidesScrollers:YES];
  [self.resultTableScrollView setVerticalScroller:[[QSBSmallScroller alloc] init]];
  [self addSubview:self.resultTableScrollView];
}

- (void)setupIndexingProgressIndicator
{
	self.indexingProgressIndicator = [[NSControl alloc] initWithFrame:DEFAULT_RECT];
	AMIndeterminateProgressIndicatorCell *cell = [[AMIndeterminateProgressIndicatorCell alloc] init];
	[cell setColor:[NSColor colorWithCalibratedRed:1.0 green:0.9 blue:0.9 alpha:1.0]];
	[cell setDisplayedWhenStopped:YES];
	[cell setSpinning:YES];
	[self.indexingProgressIndicator setCell:cell];
	[self.indexingProgressIndicator setToolTip:@"Project is being indexed at the moment"];
	[self.indexingProgressIndicator setHidden:YES];
	[self addSubview:self.indexingProgressIndicator];
}

- (NSSize)windowFrameRequirements
{
	return NSMakeSize(WINDOW_WIDTH, MAX_Y_PLUS_TOPMARGIN(self.infoStatusLabel, WINDOW_INFO_LABEL_TOPMARGIN));
}

- (BOOL)_infoLabelPresent
{
	return NO;
}

- (void)alignIndexingProgressIndicator
{
	if ([self.lowerStatusLabel isHidden]) {
		[self.indexingProgressIndicator setHidden:YES];
	}
  
	[self removeOrAddToSubviewsBasedOnVisibilityOfView:self.indexingProgressIndicator];
	[self.indexingProgressIndicator setFrame:NSMakeRect(WINDOW_MARGIN,
                                                      WINDOW_CONTENT_BOTTOMMARGIN,
                                                      PROGRESS_INDICATOR_WIDTH,
                                                      PROGRESS_INDICATOR_HEIGHT)];
}

- (void)alignLowerStatusLabel
{
	[self removeOrAddToSubviewsBasedOnVisibilityOfView:self.lowerStatusLabel];
	[self.lowerStatusLabel setFrame:NSMakeRect(WINDOW_MARGIN + PROGRESS_INDICATOR_RIGHT_MARGIN,
                                             WINDOW_CONTENT_BOTTOMMARGIN,
                                             WINDOW_CONTROL_WIDTH - PROGRESS_INDICATOR_RIGHT_MARGIN,
                                             ZERO_IF_VIEW_IS_HIDDEN(self.lowerStatusLabel, WINDOW_LOWER_STATUS_LABEL_HEIGHT))];
}

- (void)alignScrollViewFrame
{
	[self removeOrAddToSubviewsBasedOnVisibilityOfView:self.resultTableScrollView];
	[self.resultTableScrollView setFrame:NSMakeRect(0,
                                                  MAX_Y_PLUS_TOPMARGIN(self.lowerStatusLabel, WINDOW_LOWER_STATUS_LABEL_TOPMARGIN),
                                                  WINDOW_WIDTH,
                                                  self.currentMainContentViewHeight)];
}

- (void)alignUpperStatusLabel
{
	[self removeOrAddToSubviewsBasedOnVisibilityOfView:self.upperStatusLabel];
  
  [self.upperStatusLabel setFrame:NSMakeRect(WINDOW_MARGIN,
                                             MAX_Y_PLUS_TOPMARGIN(self.resultTableScrollView, WINDOW_TABLEVIEW_TOPMARGIN),
                                             WINDOW_CONTROL_WIDTH,
                                             ZERO_IF_VIEW_IS_HIDDEN(self.upperStatusLabel, WINDOW_UPPER_STATUS_LABEL_HEIGHT))];
}

- (void)alignSearchField
{
	[self.searchField setFrame:NSMakeRect(WINDOW_MARGIN + WINDOW_SEARCHFIELD_LEFT_MARGIN,
                                        MAX_Y_PLUS_TOPMARGIN(self.upperStatusLabel, WINDOW_UPPER_STATUS_LABEL_TOPMARGIN),
                                        WINDOW_CONTROL_WIDTH - WINDOW_SEARCHFIELD_LEFT_MARGIN - 10,
                                        WINDOW_SEARCHFIELD_HEIGHT)];
}

- (void)alignInfoStatusLabel
{
	[self removeOrAddToSubviewsBasedOnVisibilityOfView:self.infoStatusLabel];
	[self.infoStatusLabel setFrame:NSMakeRect(WINDOW_MARGIN,
                                            MAX_Y_PLUS_TOPMARGIN(self.searchField, WINDOW_SEARCHFIELD_TOPMARGIN),
                                            WINDOW_CONTROL_WIDTH,
                                            ZERO_IF_VIEW_IS_HIDDEN(self.infoStatusLabel, WINDOW_INFO_LABEL_HEIGHT))];
}

- (void)layoutSubviews
{
	self.currentMainContentViewHeight = [self mainContentViewHeight];
  
  [self.infoStatusLabel setHidden:NO];
  
	[self alignIndexingProgressIndicator];
	[self alignLowerStatusLabel];
	[self alignScrollViewFrame];
	[self alignUpperStatusLabel];
	[self alignSearchField];
	[self alignInfoStatusLabel];
  
	[(CPWindow *)[self window] updateFrameWithViewRequirements];
}

- (NSInteger)mainContentViewHeight
{
	if ([self.resultTableScrollView isHidden]) {
		return 0;
	} else {
		return [self.resultTableView requiredHeight];
	}
}

// if it's hidden - removes from subviews, adds otherwise
- (void)removeOrAddToSubviewsBasedOnVisibilityOfView:(NSView *)view
{
	if ([view isHidden]) {
		if (nil != [view superview]) {
			[view removeFromSuperview];
		}
	} else {
		if (nil == [view superview]) {
			[self addSubview:view];
		}
	}
}

- (void)loadUIElements
{
  [self loadFooterImageRepresentation];
  [self loadHeaderImageRepresentation];
  [self loadInfoLabelBarImageRepresentation];
}


// TODO/FIXME: refactor asset loading
- (void)loadHeaderImageRepresentation
{
  self.headerImageRepresentation = nil;
  self.headerWithInfoImageRepresentation = nil;
  
  NSString *headerImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Header"
                                                                               ofType:@"png"];
  
  NSImage *headerImage = [[NSImage alloc] initWithContentsOfFile:headerImagePath];
  
  NSString *headerWithInfoImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"HeaderWithInfo"
                                                                                       ofType:@"png"];
  
  NSImage *headerWithInfoImage = [[NSImage alloc] initWithContentsOfFile:headerWithInfoImagePath];
  
  if ([[headerImage representations] count] > 0 && [[headerWithInfoImage representations] count] > 0) {
    self.headerImageRepresentation = [[headerImage representations] objectAtIndex:0];
    self.headerWithInfoImageRepresentation = [[headerWithInfoImage representations] objectAtIndex:0];
  }
}

- (void)loadFooterImageRepresentation
{
  self.footerImageRepresentation = nil;
  
  NSString *footerImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Footer"
                                                                               ofType:@"png"];
  
  NSImage *footerImage = [[NSImage alloc] initWithContentsOfFile:footerImagePath];
  
  if ([[footerImage representations] count] > 0) {
    self.footerImageRepresentation = [[footerImage representations] objectAtIndex:0];
  }
}

- (void)loadInfoLabelBarImageRepresentation
{
  self.infoLabelBarImageRepresentation = nil;
  
  NSString *infoLabelBarImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"UpperStatusBackground"
                                                                                     ofType:@"png"];
  
  NSImage *infoLabelBarImage = [[NSImage alloc] initWithContentsOfFile:infoLabelBarImagePath];
  
  if ([[infoLabelBarImage representations] count] > 0) {
    self.infoLabelBarImageRepresentation = [[infoLabelBarImage representations] objectAtIndex:0];
  }
}

- (void)drawHeader
{
  if (nil != self.headerImageRepresentation) {
    NSImageRep *imageRep = self.headerImageRepresentation;
    
    if ([self _infoLabelPresent]) {
      imageRep = self.headerWithInfoImageRepresentation;
    }
    
    NSRect dstRect = NSMakeRect(NSMinX(self.frame), NSMaxY(self.frame) - imageRep.size.height,
                                imageRep.size.width, imageRep.size.height);
    
    [imageRep drawInRect:dstRect
                fromRect:NSMakeRect(0, 0, imageRep.size.width, imageRep.size.height)
               operation:NSCompositeSourceOver
                fraction:1.0
          respectFlipped:YES
                   hints:nil];
  }
}

- (void)drawFooter
{
  if (nil != self.footerImageRepresentation) {
    NSRect dstRect = NSMakeRect(NSMinX(self.frame), NSMinY(self.frame),
                                self.footerImageRepresentation.size.width, self.footerImageRepresentation.size.height);
    
    [self.footerImageRepresentation drawInRect:dstRect];
  }
}

- (void)drawInfoLabelBar
{
  if (nil != self.infoLabelBarImageRepresentation) {
    CGFloat upperStatusLabelOffset = 0;
    
    if (![self.infoStatusLabel isHidden]) {
      upperStatusLabelOffset = (WINDOW_UPPER_STATUS_LABEL_HEIGHT + 91);
    } else {
      upperStatusLabelOffset = 90;
    }
    
    NSRect dstRect = NSMakeRect(0, NSMaxY(self.frame) - upperStatusLabelOffset,
                                WINDOW_WIDTH, self.infoLabelBarImageRepresentation.size.height);
    
    [self.infoLabelBarImageRepresentation drawInRect:dstRect
                                            fromRect:NSMakeRect(0, 0, self.infoLabelBarImageRepresentation.size.width,
                                                                self.infoLabelBarImageRepresentation.size.height)
                                           operation:NSCompositeSourceOver
                                            fraction:1.0
                                      respectFlipped:YES
                                               hints:nil];
  }
}

- (void)drawRect:(NSRect)_rect
{
  [super drawRect:_rect];
  
  [self drawFooter];
  [self drawHeader];
  [self drawInfoLabelBar];
}

@end