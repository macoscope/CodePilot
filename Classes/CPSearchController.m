//
//  SearchController.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPSearchController.h"
#import "CPCodePilotWindowDelegate.h"
#import "CPXcodeWrapper.h"
#import "CPResultTableView.h"
#import "CPCodePilotConfig.h"
#import "CPSearchWindowView.h"
#import "CPSymbolCell.h"
#import "CPResultTableViewColumn.h"
#import "CPSearchField.h"
#import "CPFileReference.h"
#import "CPStatusLabel.h"
#import "CPSymbol.h"
#import "CPResult.h"

@implementation CPSearchController
- (id)init
{
	self = [super init];
  
  if (self) {
    self.suggestedObjects = [NSArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteQueriesChanged)
                                                 name:MCXcodeWrapperReloadedIndex
                                               object:nil];
	}
  
	return self;
}

- (void)noteQueriesChanged
{
	if (OUR_WINDOW_IS_OPEN) {
		[self updateContentsWithSearchField];
	}
}

// called whenever project index building was finished
- (void)noteProjectIndexChanged
{
	[self noteQueriesChanged];
}

- (void)selectRowAtIndex:(NSUInteger)rowIndex
{
	NSIndexSet *selectedRowIndexSet = [NSIndexSet indexSetWithIndex:rowIndex];
	[self.tableView selectRowIndexes:selectedRowIndexSet byExtendingSelection:NO];
	[self.tableView scrollRowToVisible:[self.tableView selectedRow]];
}

- (void)windowDidBecomeInactive
{
}

// before the window is on screen
- (void)windowWillBecomeActive
{
	[self.searchField reset];
  
	[self updateContentsWithSearchField];
	[self selectRowAtIndex:0];
  
	[self setupIndexingProgressIndicatorTimer];
}

// after the window appeared on the screen
- (void)windowDidBecomeActive
{
	[[self.searchField window] makeFirstResponder:self.searchField];
  
  NSNumber *autocopySelection = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_AUTOCOPY_SELECTION_KEY] ?: @(DEFAULT_AUTOCOPY_SELECTION_VALUE);
  
  if ([autocopySelection boolValue]) {
    NSString *currentSelection = [self.xcodeWrapper currentSelectionSymbolString];
    
    if (!IsEmpty(currentSelection)) {
      [self.searchField pasteString:currentSelection];
    }
  }
}

- (void)saveSelectedElement
{
	self.selectedElement = [self tableView:self.tableView
               objectValueForTableColumn:nil
                                     row:[self.tableView selectedRow]];
}

// tries to remain selection, or selects first element
- (void)updateSelectionAfterDataChange
{
#ifdef PRESERVE_SELECTION
  NSInteger currentObjectIndex = self.selectedElement ? [self indexOfObjectIsSuggestedCurrentlyForObject:self.selectedElement] : NSNotFound;
  
	if (NSNotFound != currentObjectIndex) {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:currentObjectIndex] byExtendingSelection:0];
    [self saveSelectedElement];
    
	} else if ([self.suggestedObjects count] > 0) {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:0];
    [self saveSelectedElement];
	}
#else
	if ([self.suggestedObjects count] > 0) {
		[self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:0];
		[self saveSelectedElement];
    
	} else {
		self.selectedElement = nil;
	}
#endif
}

#ifdef PRESERVE_SELECTION
- (NSInteger)indexOfObjectIsSuggestedCurrentlyForObject:(id)object
{
	for (id suggestedObject in self.suggestedObjects) {
		if ([[suggestedObject name] isEqualToString:[object name]]) {
			return [self.suggestedObjects indexOfObject:suggestedObject];
		}
	}
  
	return NSNotFound;
}
#endif

#pragma mark - Data Setup
- (void)setupRecentJumpsData
{
	self.currentDataMode = DataModeRecentJumps;
	self.suggestedObjects = [self.xcodeWrapper recentlyVisited];
	self.tableView.extendedDisplay = NO;
	self.tableView.fileQuery = @"";
	self.tableView.symbolQuery = @"";
}

- (void)setupMatchingFilesAndSymbolsData
{
	self.currentDataMode = DataModeMatchingFiles;
  
  self.suggestedObjects = [self.xcodeWrapper filesAndSymbolsFromProjectForQuery:[self.searchField fileQuery]];
  
	self.tableView.extendedDisplay = YES;
	self.tableView.fileQuery = [self.xcodeWrapper normalizedQueryForQuery:self.searchField.fileQuery];
	self.tableView.symbolQuery = [self.xcodeWrapper normalizedQueryForQuery:self.searchField.fileQuery];
}

- (void)setupMatchingSymbolsData
{
	self.currentDataMode = DataModeMatchingSymbols;
	self.suggestedObjects = [self.xcodeWrapper contentsForQuery:self.searchField.symbolQuery
                                                   fromResult:self.searchField.selectedObject];
  
  self.tableView.extendedDisplay = NO;
  
	self.tableView.fileQuery = [self.xcodeWrapper normalizedQueryForQuery:self.searchField.fileQuery];
	self.tableView.symbolQuery = [self.xcodeWrapper normalizedQueryForQuery:self.searchField.symbolQuery];
}

#pragma mark - Status Labels
- (NSDictionary *)infoStatusLabelUnregisteredStringAttributes
{
	NSMutableParagraphStyle *leftAlignedParagraphStyle = [NSMutableParagraphStyle new];
	leftAlignedParagraphStyle.alignment = NSCenterTextAlignment;
  
	return [[NSDictionary alloc] initWithObjectsAndKeys: leftAlignedParagraphStyle, NSParagraphStyleAttributeName,
          WINDOW_INFO_LABEL_UNREGISTERED_FONT_COLOR, NSForegroundColorAttributeName,
          nil];
}

- (NSDictionary *)infoStatusLabelNextVersionAvailableStringAttributes
{
	NSMutableParagraphStyle *leftAlignedParagraphStyle = [NSMutableParagraphStyle new];
	leftAlignedParagraphStyle.alignment = NSCenterTextAlignment;
  
	return [[NSDictionary alloc] initWithObjectsAndKeys: leftAlignedParagraphStyle, NSParagraphStyleAttributeName,
          WINDOW_INFO_LABEL_NEW_VERSION_AVAILABLE_FONT_COLOR, NSForegroundColorAttributeName,
          nil];
}

- (NSDictionary *)upperStatusLabelStringAttributes
{
	NSMutableParagraphStyle *leftAlignedParagraphStyle = [NSMutableParagraphStyle new];
	leftAlignedParagraphStyle.alignment = NSLeftTextAlignment;
  
	return [[NSDictionary alloc] initWithObjectsAndKeys: leftAlignedParagraphStyle, NSParagraphStyleAttributeName,
          [self statusLabelFont], NSFontAttributeName,
          nil];
}

- (NSDictionary *)lowerStatusLabelStringAttributes
{
	NSMutableParagraphStyle *rightAlignedParagraphStyle = [NSMutableParagraphStyle new];
	rightAlignedParagraphStyle.alignment = NSRightTextAlignment;
  
	return [[NSDictionary alloc] initWithObjectsAndKeys: rightAlignedParagraphStyle, NSParagraphStyleAttributeName,
          [self statusLabelFont], NSFontAttributeName,
          nil];
}

- (NSMutableAttributedString *)boldFacedStatusLabelString:(NSString *)str
{
	if (IsEmpty(str)) {
		return [[NSMutableAttributedString alloc] init];
	}
  
	NSMutableDictionary *boldAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                         [NSColor colorWithCalibratedRed:0.48 green:0.49 blue:0.62 alpha:1], NSForegroundColorAttributeName,
                                         [NSNumber numberWithFloat:0.8],  NSKernAttributeName,
                                         [self statusLabelFont], NSFontAttributeName,
                                         nil];
  
	return [[NSMutableAttributedString alloc] initWithString:str attributes:boldAttributes];
}

- (NSMutableAttributedString *)normalFacedStatusLabelString:(NSString *)str
{
	if (IsEmpty(str)) {
		return [[NSMutableAttributedString alloc] init];
	}
  
	NSMutableDictionary *normalAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSColor colorWithCalibratedWhite:0.5 alpha:0.8], NSForegroundColorAttributeName,
                                           [NSNumber numberWithFloat:0.8],  NSKernAttributeName,
                                           [self statusLabelFont], NSFontAttributeName,
                                           nil];
  
	return [[NSMutableAttributedString alloc] initWithString:str attributes:normalAttributes];
}

- (NSFont *)statusLabelFont
{
  NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
  NSString *fontPath = [myBundle pathForResource:@"ATROX" ofType:@"TTF"];
  NSURL *fontURL = [NSURL fileURLWithPath:fontPath];
  
  NSArray *fontDescriptors = (NSArray *)CFBridgingRelease(CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fontURL));
  CTFontDescriptorRef fontDescriptor = (__bridge CTFontDescriptorRef)[fontDescriptors lastObject];
  
  return (NSFont *)CFBridgingRelease(CTFontCreateWithFontDescriptor(fontDescriptor, 16.0, NULL));
}

- (void)setupRecentJumpsStatusLabels
{
	if ([self.suggestedObjects count] > 0) {
		NSMutableAttributedString *attributedLabel = [self normalFacedStatusLabelString:@"Recently opened files in "];
    
		[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:[self.xcodeWrapper currentProjectName]]];
		[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@":"]];
    
		[self.upperStatusLabel setAttributedStringValue:attributedLabel];
    
		[self setupLowerStatusLabelForMatchingFiles];
	} else {
		[self.upperStatusLabel setHidden:YES];
		[self.lowerStatusLabel setHidden:YES];
	}
}

- (void)setupLowerStatusLabelForMatchingFiles
{
  NSMutableAttributedString *attributedLabel = [NSMutableAttributedString new];
  
	if (nil != self.selectedElement) {
    attributedLabel = [[NSMutableAttributedString alloc] initWithString:@" " // to set the alignment
                                                             attributes:[self lowerStatusLabelStringAttributes]];
    
    [attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@"Press "]];
    
		if ([self.selectedElement isSearchable]) {
			[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:@"[space]"]];
			[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" for contents"]];
		}
    
		if ([self.selectedElement isOpenable]) {
			if ([self.selectedElement isSearchable]) {
				[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@", "]];
			}
			[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:@"[enter]"]];
			[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" to open"]];
		}
	}
  
	[self.lowerStatusLabel setAttributedStringValue:attributedLabel];
}

- (void)setupMatchingFilesStatusLabels
{
	NSInteger count = [self.suggestedObjects count];
  
	NSString *basicString = [NSString nounWithCount:count forNoun:@"match"];
  
	NSMutableAttributedString *attributedLabel = [self normalFacedStatusLabelString:basicString];
  
	[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" found in "]];
	[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:[self.xcodeWrapper currentProjectName]]];
	[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@":"]];
  [self.upperStatusLabel setAttributedStringValue:attributedLabel];
	[self setupLowerStatusLabelForMatchingFiles];
}

- (void)setupMatchingSymbolsStatusLabels
{
	NSString *basicString = [NSString nounWithCount:[self.suggestedObjects count] forNoun:@"matching symbol"];
  
	NSMutableAttributedString *attributedLabel = [self normalFacedStatusLabelString:basicString];
  
  
	[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" found in "]];
	[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:[self.searchField.selectedObject name]]];
  
	NSString *suffix = @":";
	if ([self.searchField.selectedObject isKindOfClass:[CPSymbol class]]) {
		suffix = [NSString stringWithFormat:@" %@:", [(CPSymbol *)self.searchField.selectedObject symbolTypeName]];
	}
  
	[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:suffix]];
  
  
	[self.upperStatusLabel setAttributedStringValue:attributedLabel];
  
  attributedLabel = [[NSMutableAttributedString alloc] initWithString:@" "
                                                           attributes:[self lowerStatusLabelStringAttributes]];
  
	[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@"Press "]];
	[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:@"[backspace]"]];
	[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" to go back"]];
  
	if ([self.selectedElement isSearchable]) {
		[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@", "]];
		[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:@"[space]"]];
		[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" for contents"]];
	}
  
	if ([self.selectedElement isOpenable]) {
		if ([self.selectedElement isSearchable]) {
			[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" or "]];
		} else {
			[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@", "]];
		}
		[attributedLabel appendAttributedString:[self boldFacedStatusLabelString:@"[enter]"]];
		[attributedLabel appendAttributedString:[self normalFacedStatusLabelString:@" to open"]];
	}
  
	[self.lowerStatusLabel setAttributedStringValue:attributedLabel];
}

- (void)setupTooMuchResultsStatusLabels
{
	[self.lowerStatusLabel setHidden:YES];
	[self.upperStatusLabel setHidden:NO];
  
	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:TOO_MANY_RESULTS_STRING
                                                                         attributes:[self upperStatusLabelStringAttributes]];
  
	[self.upperStatusLabel setAttributedStringValue:attributedString];
}

- (void)setupStatusLabels
{
	[self.upperStatusLabel setAttributedStringValue:[[NSAttributedString alloc] init]];
	[self.lowerStatusLabel setAttributedStringValue:[[NSAttributedString alloc] init]];
	[self.upperStatusLabel setHidden:NO];
	[self.lowerStatusLabel setHidden:NO];
	[self setupInfoStatusLabel];
  
	if ([self numberOfRowsInTableView:self.tableView] > MAX_OBJECT_COUNT_FOR_SORT_AND_FILTER) {
		[self setupTooMuchResultsStatusLabels];
	} else {
		switch (self.currentDataMode) {
			case DataModeMatchingFiles:
				[self setupMatchingFilesStatusLabels];
				break;
			case DataModeMatchingSymbols:
				[self setupMatchingSymbolsStatusLabels];
				break;
			case DataModeRecentJumps:
				[self setupRecentJumpsStatusLabels];
				break;
		}
	}
}

- (void)setupInfoStatusLabel
{
	if (nil != self.infoStatusLabel) {
		[self.infoStatusLabel setStringValue:@""];
		self.infoStatusLabel.clickUrl = nil;
	}
}

- (void)updateContentsWithSearchField
{
	if (self.searchField.selectedObject) {
		[self setupMatchingSymbolsData];
    
	} else if (IsEmpty(self.searchField.fileQuery)) {
		[self setupRecentJumpsData];
    
	} else {
		[self setupMatchingFilesAndSymbolsData];
	}
  
	[self.tableView reloadData];
	[self.tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.suggestedObjects count])]];
  
  BOOL shouldHideEnclosingScrollView = 0 == [self numberOfRowsInTableView:self.tableView] || [self numberOfRowsInTableView:self.tableView] > MAX_OBJECT_COUNT_FOR_SORT_AND_FILTER;
  [[self.tableView enclosingScrollView] setHidden:shouldHideEnclosingScrollView];
  
	[self updateSelectionAfterDataChange];
	[self setupStatusLabels];
  
	// this needs to go after [tableView reloadData] (as it could change required size
	// for the table), and after setupStatusLabels (as it could change visibility of the
	// upper/lower status labels)
	[(CPSearchWindowView *)[self.searchField superview] layoutSubviews];
}

#pragma mark - Search Field Delegate
- (BOOL)spacePressedForSearchField:(CPSearchField *)searchField
{
	if (self.selectedElement && [self.selectedElement isSearchable]) {
		self.searchField.selectedObject = self.selectedElement;
		[self noteQueriesChanged];
	}
  
	return YES; // it wasn't handled.
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	if (@selector(moveDown:) == command) {
		NSInteger nextRowIndex = [self.tableView selectedRow]+1;
		if (nextRowIndex < [self numberOfRowsInTableView:self.tableView]) {
			[self selectRowAtIndex:nextRowIndex];
			[self saveSelectedElement];
			[self setupStatusLabels];
		}
		return YES;
	}
  
	if (@selector(moveUp:) == command) {
		NSInteger prevRowIndex = [self.tableView selectedRow]-1;
		if (prevRowIndex >= 0) {
			[self selectRowAtIndex:prevRowIndex];
			[self saveSelectedElement];
			[self setupStatusLabels];
		}
		return YES;
	}
  
	if (@selector(insertLineBreak:) == command) {
		return YES;
	}
  
	if (@selector(insertContainerBreak:) == command) {
		return YES;
	}
  
	// enter - file opening
	if (@selector(insertNewline:) == command || @selector(PBX_insertNewlineAndIndent:) == command) {
		if (self.selectedElement) {
			[(CPCodePilotWindowDelegate *)[[self.searchField window] delegate] hideWindow];
      
      BOOL external = [[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_EXTERNAL_EDITOR_KEY] boolValue];
      if ([NSEvent modifierFlags] & NSCommandKeyMask) {
        external = !external;
      }
      [self.xcodeWrapper openFileOrSymbol:self.selectedElement
                         inExternalEditor:external];

		}
    
		return YES;
	}
  
	// escape - we step aside
	if (@selector(cancelOperation:) == command) {
		[(CPCodePilotWindowDelegate *)[[self.searchField window] delegate] hideWindow];
		return YES;
	}
  
  if ([self.tableView respondsToSelector:command]) {
    if (@selector(scrollToBeginningOfDocument:) == command) {
      [self.tableView scrollToBeginningOfDocument:self];
      return YES;
    }
    
    if (@selector(scrollToEndOfDocument:) == command) {
      [self.tableView scrollToEndOfDocument:self];
      return YES;
    }
  }
  
  
	if (@selector(scrollPageUp:) == command) {
		[[self.tableView enclosingScrollView] pageUp:self];
		return YES;
  }
  
	if (@selector(scrollPageDown:) == command) {
		[[self.tableView enclosingScrollView] pageDown:self];
		return YES;
  }
  
	return NO;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self.suggestedObjects count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	@try {
		return [self.suggestedObjects objectAtIndex:rowIndex];
	}
	@catch (NSException * e) {
	}
	return nil;
}

#pragma mark - Table View Delegate
- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
  return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	CPResultTableViewColumn *tableColumn = (CPResultTableViewColumn *)[[self.tableView tableColumns] objectAtIndex:0];
	id cell = [tableColumn dataCellForRow:row];
	return [cell requiredHeight];
}

#pragma mark - Indexing Progress Indicator
- (void)setupIndexingProgressIndicatorTimer
{
	if (nil == self.indexingProgressIndicatorTimer) {
		self.indexingProgressIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:[[self.indexingProgressIndicator cell] animationDelay]
                                                                           target:self
                                                                         selector:@selector(animateIndexingProgressIndicator:)
                                                                         userInfo:NULL
                                                                          repeats:YES];
    
		[[NSRunLoop currentRunLoop] addTimer:self.indexingProgressIndicatorTimer
                                 forMode:NSEventTrackingRunLoopMode];
	}
}

- (void)animateIndexingProgressIndicator:(NSTimer *)aTimer
{
	double value = fmod(([[self.indexingProgressIndicator cell] doubleValue] + (5.0/60.0)), 1.0);
  
	[[self.indexingProgressIndicator cell] setDoubleValue:value];
	[self.indexingProgressIndicator setNeedsDisplay:YES];
  
	if ([self.xcodeWrapper currentProjectIsIndexing]) {
		[self.indexingProgressIndicator setHidden:NO];
	} else {
		[self.indexingProgressIndicator setHidden:YES];
	}
}

@end