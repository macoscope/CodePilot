//
//  ResultTableViewColumn.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPResultTableViewColumn.h"
#import "CPResultTableView.h"
#import "CPSymbolCell.h"
#import "CPFileReferenceCell.h"
#import "CPFileReference.h"
#import "CPCodePilotConfig.h"
#import "CPSymbol.h"

@implementation CPResultTableViewColumn
- (id)init
{
	self = [super init];
  
  if (self) {
    [self setMaxWidth:WINDOW_WIDTH];
    [self setMinWidth:WINDOW_WIDTH];
    [self setWidth:WINDOW_WIDTH];
  }
  
	return self;
}

- (id)dataCellForRow:(NSInteger)rowIndex
{
  CPResultTableView *resultTableView = (CPResultTableView *)[self tableView];
  
	if (nil == self.symbolCell) {
		self.symbolCell = [CPSymbolCell new];
	}
  
	if (nil == self.fileCell) {
		self.fileCell = [CPFileReferenceCell new];
	}
  
	self.fileCell.extendedDisplay = resultTableView.extendedDisplay;
	self.symbolCell.extendedDisplay = resultTableView.extendedDisplay;
	self.fileCell.query = resultTableView.fileQuery;
	self.symbolCell.query = resultTableView.symbolQuery;
  
  if ([resultTableView dataSource]) {
    id dataSource = [resultTableView dataSource];
    if ([dataSource respondsToSelector:@selector(tableView:objectValueForTableColumn:row:)]) {
			id object = [dataSource tableView:resultTableView objectValueForTableColumn:self row:rowIndex];
      if ([object isKindOfClass:[CPFileReference class]]) {
        return self.fileCell;
			} else if ([object isKindOfClass:[CPSymbol class]]) {
        return self.symbolCell;
			} else if (nil == object) {
				// happens rarely when we're reloading while user browses the table
				// it's caused by timer-based, async communication and searching
				// user won't see it probably anyway
				LOG(@"WARNING: nil object requested cell at index %d", rowIndex);
				return self.symbolCell;
			} else {
				LOG(@"WARNING: object of unknown class found %@ at index %d", object, rowIndex);
			}
    }
  }
  
  return [super dataCellForRow:rowIndex];
}
@end
