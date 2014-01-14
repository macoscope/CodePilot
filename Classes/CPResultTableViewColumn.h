//
//  ResultTableViewColumn.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CPSymbolCell, CPFileReferenceCell;

@interface CPResultTableViewColumn : NSTableColumn
@property (nonatomic, strong)	CPSymbolCell *symbolCell;
@property (nonatomic, strong)	CPFileReferenceCell *fileCell;
@end
