//
//  SearchField.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/27/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CPStatusLabel, CPSearchFieldTextView, CPResult;

@interface CPSearchField : NSTextField
@property (nonatomic, strong) NSString *fileQuery;
@property (nonatomic, strong) NSString *symbolQuery;
@property (nonatomic, weak) NSTimer *delegateNotificationAboutChangedQueriesTimer;
@property (nonatomic, strong) CPResult *selectedObject;
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic, strong)	CPStatusLabel *placeholderTextField;

- (BOOL)spaceKeyDown;
- (void)reset;
- (id)copyWithZone:(NSZone *)zone;
- (void)disableObservers;
- (void)letDelegateKnowAboutChangedQueries;
- (void)setupDelegateNotificationAboutChangedQueriesTimer;
- (void)selectedObjectDidChange;
- (BOOL)cmdBackspaceKeyDown;
- (void)pasteString:(NSString *)str;
@end