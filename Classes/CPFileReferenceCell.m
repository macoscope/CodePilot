//
//  FileSelectionCell.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/10/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPFileReferenceCell.h"
#import "CPCodePilotConfig.h"
#import "CPFileReference.h"

@implementation CPFileReferenceCell
@dynamic cpFileReference;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  [super drawWithFrame:cellFrame inView:controlView];
  
	[self drawIconWithFrame:cellFrame];
  [self drawFileNameWithFrame:cellFrame];
  
	if (self.extendedDisplay) {
		[self drawGroupNameWithFrame:cellFrame];
	}
}

- (void)drawIconWithFrame:(NSRect)cellFrame
{
	[self drawIconImage:[self.cpFileReference icon] withFrame:cellFrame];
}

- (void)drawFileNameWithFrame:(NSRect)cellFrame
{
	NSMutableDictionary *fileNameStringAttributes = [[self defaultStringAttributes] mutableCopy];
  
	[fileNameStringAttributes setObject:[NSFont fontWithName:FILE_SELECTION_CELL_FONT_NAME
																										  size:FILE_SELECTION_CELL_FONT_SIZE]
															 forKey:NSFontAttributeName];
  
  if ([self isHighlighted]) {
    [fileNameStringAttributes setObject:FILE_SELECTION_CELL_HIGHLIGHTED_FONT_COLOR forKey:NSForegroundColorAttributeName];
  } else {
    [fileNameStringAttributes setObject:FILE_SELECTION_CELL_FONT_COLOR forKey:NSForegroundColorAttributeName];
  }
  
	NSMutableAttributedString *fileNameAttributedString = [[self queryHitAttributedStringWithString:[self.cpFileReference fileName]] mutableCopy];
  
	[fileNameAttributedString addAttributes:fileNameStringAttributes range:NSMakeRange(0, [fileNameAttributedString length])];
  
  // odstep miedzy ikona a nazwa pliku;
  CGFloat fileNameMargin;
  
  if (self.extendedDisplay) {
    fileNameMargin = RESULT_CELL_FILE_EXTENDED_ICON_WIDTH;
  } else {
    fileNameMargin = RESULT_CELL_FILE_ICON_WIDTH;
  }
  
	[fileNameAttributedString drawInRect:NSMakeRect(cellFrame.origin.x + fileNameMargin,
																									cellFrame.origin.y + 4,
																									cellFrame.size.width - fileNameMargin,
																									cellFrame.size.height)];
}

- (void)drawGroupNameWithFrame:(NSRect)cellFrame
{
	if ([self.cpFileReference groupName]) {
		NSMutableDictionary *groupNameStringAttributes = [[self defaultStringAttributes] mutableCopy];
    
		[groupNameStringAttributes setObject:[NSFont fontWithName:FILE_SELECTION_CELL_EXTENDED_INFO_FONT_NAME
																												 size:FILE_SELECTION_CELL_EXTENDED_INFO_FONT_SIZE]
                                  forKey:NSFontAttributeName];
    
    if ([self isHighlighted]) {
      [groupNameStringAttributes setObject:FILE_SELECTION_CELL_HIGHLIGHTED_FONT_COLOR forKey:NSForegroundColorAttributeName];
    } else {
      [groupNameStringAttributes setObject:FILE_SELECTION_CELL_FONT_COLOR forKey:NSForegroundColorAttributeName];
    }
    
		NSString *groupNameString = [self.cpFileReference groupName];
		NSString *projectName = [self.cpFileReference projectName];
    
		if ([self.cpFileReference subprojectFile]) {
			groupNameString = [NSString stringWithFormat:@"%@ (%@)", groupNameString, projectName];
		}
    
		NSAttributedString *groupNameAttributedString = [[NSAttributedString alloc] initWithString:groupNameString
																																										attributes:groupNameStringAttributes];
    
		[groupNameAttributedString drawInRect:NSMakeRect(cellFrame.origin.x + RESULT_CELL_FILE_EXTENDED_ICON_WIDTH,
																										 cellFrame.origin.y + FILE_SELECTION_CELL_FONT_SIZE + 9,
																										 cellFrame.size.width - RESULT_CELL_FILE_EXTENDED_ICON_WIDTH,
																										 cellFrame.size.height - (FILE_SELECTION_CELL_FONT_SIZE + 9))];
	}
}

- (CPFileReference *)cpFileReference
{
  return (CPFileReference *)self.objectValue;
}

- (NSUInteger)requiredHeight
{
	if (self.extendedDisplay) {
		return FILE_SELECTION_CELL_EXTENDED_HEIGHT;
	} else {
		return FILE_SELECTION_CELL_HEIGHT;
	}
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
  return NSZeroRect;
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
{
  return;
}
@end