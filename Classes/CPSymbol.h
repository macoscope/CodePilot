//
//  CPSymbol.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPResult.h"

@class CPFileReference, IDEIndexSymbolOccurrence;

@interface CPSymbol : CPResult
@property (nonatomic, strong) IDEIndexSymbol *wrappedObject;
@property (nonatomic, strong) NSString *relatedFilePath;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSArray *childrenCache;
@property (nonatomic, assign, readonly) BOOL hasOccurrences;
@property (nonatomic, strong) IDEIndexSymbolOccurrence *cachedRelatedSymbolOccurrence;

- (CPSymbol *)initWithIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol forRelatedFileAtPath:(NSString *)relatedFilePath;
- (CPSymbol *)initWithIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol forCPFileReference:(CPFileReference *)fileReference;

- (BOOL)isEqualToIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol;
- (BOOL)isCategory;

- (NSString *)symbolTypeName;
- (NSString *)name;
- (NSString *)sourceFile;
- (NSString *)originalClassName;
- (NSImage *)icon;

- (void)logOccurrences;
- (DVTTextDocumentLocation *)relatedDocumentLocation;
- (IDEIndexSymbolOccurrence *)relatedSymbolOccurrence;
- (NSArray *)children;

- (void)cacheRelatedSymbolOccurrence;
@end