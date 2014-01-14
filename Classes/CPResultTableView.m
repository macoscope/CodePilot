//
//  ResultTableView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/14/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPResultTableView.h"
#import "CPCodePilotConfig.h"
#import "CPSearchWindowView.h"
#import "CPResultTableViewColumn.h"

@implementation CPResultTableView
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
  
  if (self) {
    self.extendedDisplay = NO;
    self.fileQuery = @"";
    self.symbolQuery = @"";
    
    CPResultTableViewColumn *tableColumn = [CPResultTableViewColumn new];
    [self addTableColumn:tableColumn];
    
    [self setHeaderView:nil];
    [self setAllowsColumnReordering:NO];
    [self setAllowsColumnResizing:NO];
    [self setAllowsColumnSelection:NO];
    [self setAllowsMultipleSelection:NO];
    [self setAllowsEmptySelection:NO];
    [self setAllowsTypeSelect:NO];
    [self setAlphaValue:1];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setGridColor:[NSColor clearColor]];
    [self setIntercellSpacing:NSZeroSize];
	}
  
	return self;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	NSInteger selectedRow = [self selectedRow];
  
	if (selectedRow >= 0) {
		NSRect selectedRowRect = [self rectOfRow:selectedRow];
		if (NSIntersectsRect(selectedRowRect, clipRect)) {
			[TABLE_ROW_HIGHLIGHT_COLOR set];
      
			NSRectFill(selectedRowRect);
		}
	}
}

- (void)reloadData
{
	[super reloadData];
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
}

- (void)mouseDown:(NSEvent *)theEvent
{
}

- (BOOL)canBecomeKeyView
{
	return NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return NO;
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (NSUInteger)requiredHeight
{
	NSUInteger newTableViewHeight = 0;
	NSUInteger rowCount = [self.dataSource numberOfRowsInTableView:self];
	NSTableColumn *firstColumn = [[self tableColumns] objectAtIndex:0];
  
	for (NSInteger i = 0; i < rowCount; i++) {
		newTableViewHeight += [[firstColumn dataCellForRow:i] requiredHeight];
	}
  
	return MIN(newTableViewHeight, MAX_TABLE_HEIGHT);
}
@end
