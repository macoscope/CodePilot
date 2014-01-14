//
//  ResultTableView.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/14/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPResultTableView : NSTableView
@property (nonatomic, assign) BOOL extendedDisplay;
@property (nonatomic, strong) NSString *fileQuery;
@property (nonatomic, strong) NSString *symbolQuery;

- (NSUInteger)requiredHeight;
@end
