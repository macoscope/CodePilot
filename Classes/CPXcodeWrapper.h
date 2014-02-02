//
//  CPXcodeWrapper.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPCodePilotConfig.h"

@class CPFileReference, CPSymbol, CPWorkspaceSymbolCache, CPResult;

@interface CPXcodeWrapper : NSObject
@property (nonatomic, strong) NSMutableArray *currentlyIndexedWorkspaces;
@property (nonatomic, strong) NSMutableArray *workspaceSymbolCaches;
@property (nonatomic, assign) BOOL symbolCachingInProgress;

- (void)reloadAfterPreferencesChange;
- (void)reloadXcodeState;
- (BOOL)hasOpenWorkspace;
- (NSScreen *)currentScreen;
- (BOOL)currentProjectIsIndexing;
- (void)openFileOrSymbol:(id)fileOrSymbol;
- (void)openFileOrSymbol:(id)fileOrSymbol inExternalEditor:(BOOL)aUseExternal;
- (void)openCPSymbol:(CPSymbol *)symbol;
- (void)openCPSymbol:(CPSymbol *)symbol inExternalEditor:(BOOL)aUseExternal;
- (void)openCPFileReference:(CPFileReference *)cpFileReference;
- (void)openCPFileReference:(CPFileReference *)cpFileReference inExternalEditor:(BOOL)aUseExternal;
- (NSString *)currentProjectName;
- (NSString *)normalizedQueryForQuery:(NSString *)query;
- (NSArray *)contentsForQuery:(NSString *)query fromResult:(CPResult *)result;
- (NSArray *)filesAndSymbolsFromProjectForQuery:(NSString *)query;
- (NSArray *)recentlyVisited;
- (NSString *)currentSelectionSymbolString;
+ (NSArray *)symbolsForProject:(id)pbxProject;
- (NSArray *)cpFileReferencesMatchingQuery:(NSString *)query;
- (NSArray *)topLevelCPSymbolsMatchingQuery:(NSString *)query;
- (NSArray *)arrayOfCPFileReferencesByWrappingXcodeFileReferences:(NSArray *)xcodeFileReferences;
- (id)pbxFileReferenceForCPFileReference:(CPFileReference *)cpFileReference;
- (NSArray *)cpSymbolsFromFile:(CPFileReference *)fileObject matchingQuery:(NSString *)query;
- (NSArray *)arrayOfCPSymbolsByWrappingIDESymbols:(NSArray *)ideSymbols forCPFileReference:(CPFileReference *)fileObject;

- (NSArray *)recursiveChildrenOfPBXGroup:(PBXGroup *)pbxGroup;
- (NSArray *)flattenedProjectContents;
- (IDEWorkspace *)currentWorkspace;
- (IDEIndex *)currentIndex;
- (NSArray *)recursiveChildrenOfIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol;
- (NSArray *)allIDEIndexSymbolsFromCPFileReference:(CPFileReference *)fileReference;
- (IDEEditorContext *)currentEditorContext;
- (IDEWorkspaceDocument *)currentWorkspaceDocument;
- (NSArray *)arrayOfCPFileReferencesByWrappingFileURLs:(NSArray *)fileURLs;
- (IDEWorkspaceWindowController *)currentWorkspaceWindowController;

- (NSArray *)arrayOfCPFileReferencesByWrappingDVTFilePaths:(NSArray *)dvtFilePaths;

- (void)willIndexWorkspace:(NSNotification *)notification;
- (void)didIndexWorkspace:(NSNotification *)notification;
- (void)removeClosedWorkspacesFromCurrentlyIndexed;
- (NSArray *)allOpenedWorkspaces;
- (IDEWorkspace *)workspaceForIndex:(IDEIndex *)index;

- (void)updateWorkspaceSymbolCacheForWorkspace:(IDEWorkspace *)workspace;
- (CPWorkspaceSymbolCache *)workspaceSymbolCacheForWorkspace:(IDEWorkspace *)workspace;

- (void)updateWorkspaceSymbolCacheForWorkspace:(IDEWorkspace *)workspace withWorkspaceSymbolCache:(CPWorkspaceSymbolCache *)workspaceSymbolCache;
- (BOOL)isSymbolCachingInProgress;

- (NSArray *)recentlyVisitedFiles;
@end