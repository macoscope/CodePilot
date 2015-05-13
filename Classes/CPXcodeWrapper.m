//
//  CPXcodeWrapper.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/9/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPXcodeWrapper.h"
#import "CPCodePilotConfig.h"
#import "CPFileReference.h"
#import "CPSymbol.h"
#import "CPSymbolCache.h"
#import "NSArray+MiscExtensions.h"
#import "NSMutableArray+MiscExtensions.h"
#import "CPWorkspaceSymbolCache.h"
#import "CPResult.h"
#import "NSURL+Xcode.h"
#import "NSWorkspace+OpenFileOnLine.h"

static NSString * const WorkspaceDocumentsKeyPath = @"workspaceDocuments";
static NSString * const IDEIndexWillIndexWorkspaceNotification = @"IDEIndexWillIndexWorkspaceNotification";
static NSString * const IDEIndexDidIndexWorkspaceNotification = @"IDEIndexDidIndexWorkspaceNotification";

@implementation CPXcodeWrapper
- (id)init
{
  self = [super init];
  
  if (self) {
    self.currentlyIndexedWorkspaces = [NSMutableArray array];
    self.workspaceSymbolCaches = [NSMutableArray array];
    self.symbolCachingInProgress = NO;
    
    // we monitor workspaces open to keep an up-to-date indexDB connections / query providers
    // open, because it requires a lot of resources to open. and monitoring workspaces.
    [[IDEDocumentController sharedDocumentController] addObserver:self
                                                       forKeyPath:WorkspaceDocumentsKeyPath
                                                          options:0
                                                          context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willIndexWorkspace:)
                                                 name:IDEIndexWillIndexWorkspaceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didIndexWorkspace:)
                                                 name:IDEIndexDidIndexWorkspaceNotification
                                               object:nil];
  }
  
  return self;
}

- (void)dealloc
{
  [[IDEDocumentController sharedDocumentController] removeObserver:self forKeyPath:WorkspaceDocumentsKeyPath];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willIndexWorkspace:(NSNotification *)notification
{
  @synchronized (self.currentlyIndexedWorkspaces) {
    IDEIndex *index = (IDEIndex *)[notification object];
    
    for (IDEWorkspace *workspace in [self allOpenedWorkspaces]) {
      if (index == [workspace index]) {
        if (![self.currentlyIndexedWorkspaces containsObject:workspace]) {
          [self.currentlyIndexedWorkspaces addObject:workspace];
        }
      }
    }
  }
}

- (void)didIndexWorkspace:(NSNotification *)notification
{
  IDEIndex *index = (IDEIndex *)[notification object];
  IDEWorkspace *workspace = [self workspaceForIndex:index];
  
  @synchronized (self.currentlyIndexedWorkspaces) {
    if ([self.currentlyIndexedWorkspaces containsObject:workspace]) {
      [self.currentlyIndexedWorkspaces removeObject:workspace];
    }
  }
  
  [NSThread detachNewThreadSelector:@selector(updateWorkspaceSymbolCacheForWorkspace:)
                           toTarget:self
                         withObject:workspace];
}

// if someone closes workspace while it's being indexed,
// we need to remove it from currentlyIndexedWorkspaces array
- (void)removeClosedWorkspacesFromCurrentlyIndexed
{
  @synchronized (self.currentlyIndexedWorkspaces) {
    NSArray *currentWorkspaces = [self allOpenedWorkspaces];
    for (IDEWorkspace *workspace in [self.currentlyIndexedWorkspaces copy]) {
      if (![currentWorkspaces containsObject:workspace]) {
        [self.currentlyIndexedWorkspaces removeObject:workspace];
      }
    }
  }
}

- (NSArray *)allOpenedWorkspaces
{
  NSArray *workspaces = [NSArray array];
  
  for (IDEWorkspaceDocument *workspaceDocument in [[IDEDocumentController sharedDocumentController] workspaceDocuments]) {
    workspaces = [workspaces arrayByAddingObject:[workspaceDocument workspace]];
  }
  
  return workspaces;
}

- (IDEWorkspace *)workspaceForIndex:(IDEIndex *)index
{
  for (IDEWorkspace *workspace in [self allOpenedWorkspaces]) {
    if ([workspace index] == index) {
      return workspace;
    }
  }
  
  return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:WorkspaceDocumentsKeyPath] && [object isKindOfClass:[IDEDocumentController class]]) {
    [self removeClosedWorkspacesFromCurrentlyIndexed];
  }
}

- (void)reloadAfterPreferencesChange
{
}

- (void)reloadXcodeState
{
}

- (BOOL)hasOpenWorkspace
{
  NSUInteger numberOfOpenWorkspaces = [[[IDEDocumentController sharedDocumentController] workspaceDocuments] count];
  
  return (numberOfOpenWorkspaces > 0);
}

- (NSString *)normalizedQueryForQuery:(NSString *)query
{
  if (!query) {
    return nil;
  }
  NSMutableString *mQuery = [query mutableCopy];
  NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[\\*\\ \\r\\n\\t]"  options:NSRegularExpressionCaseInsensitive error:nil];

  [regex replaceMatchesInString:mQuery options:NSMatchingAnchored range:NSMakeRange(0, mQuery.length) withTemplate:@""];
  return mQuery;
}

- (CPWorkspaceSymbolCache *)workspaceSymbolCacheForWorkspace:(IDEWorkspace *)workspace
{
  for (CPWorkspaceSymbolCache *workspaceSymbolCache in self.workspaceSymbolCaches) {
    if (workspaceSymbolCache.workspace == workspace) {
      return workspaceSymbolCache;
    }
  }
  
  return nil;
}


- (void)updateWorkspaceSymbolCacheForWorkspace:(IDEWorkspace *)workspace withWorkspaceSymbolCache:(CPWorkspaceSymbolCache *)newWorkspaceSymbolCache
{
  @synchronized (self.workspaceSymbolCaches) {
    CPWorkspaceSymbolCache *oldWorkspaceSymbolCache = [self workspaceSymbolCacheForWorkspace:workspace];
    
    NSUInteger oldWorkspaceSymbolCacheIndex = [self.workspaceSymbolCaches indexOfObject:oldWorkspaceSymbolCache];
    
    if (NSNotFound == oldWorkspaceSymbolCacheIndex) {
      [self.workspaceSymbolCaches addObject:newWorkspaceSymbolCache];
    } else {
      [self.workspaceSymbolCaches replaceObjectAtIndex:oldWorkspaceSymbolCacheIndex withObject:newWorkspaceSymbolCache];
    }
  }
}

- (void)updateWorkspaceSymbolCacheForWorkspace:(IDEWorkspace *)workspace
{
  @try {
    @synchronized (self.workspaceSymbolCaches) {
      self.symbolCachingInProgress = YES;
      NSMutableArray *newSymbolCacheContents = [NSMutableArray array];
      
      NSArray *interestingSymbolKinds = [NSArray arrayWithObjects:
                                         [DVTSourceCodeSymbolKind containerSymbolKind],
                                         [DVTSourceCodeSymbolKind globalSymbolKind],
                                         [DVTSourceCodeSymbolKind classMethodSymbolKind],
                                         [DVTSourceCodeSymbolKind instanceMethodSymbolKind],
                                         [DVTSourceCodeSymbolKind instanceVariableSymbolKind],
                                         [DVTSourceCodeSymbolKind classVariableSymbolKind],
                                         [DVTSourceCodeSymbolKind parameterSymbolKind],
                                         [DVTSourceCodeSymbolKind macroSymbolKind],
                                         [DVTSourceCodeSymbolKind propertySymbolKind],
                                         [DVTSourceCodeSymbolKind unionSymbolKind],
                                         [DVTSourceCodeSymbolKind localVariableSymbolKind], nil];
      
      for (DVTSourceCodeSymbolKind *symbolKind in interestingSymbolKinds) {
        NSArray *symbolsForKind = [workspace.index allSymbolsMatchingKind:symbolKind workspaceOnly:YES];
        
        NSUInteger duplicateSymbols = 0;
        for (IDEIndexSymbol *symbol in symbolsForKind) {
          if ([newSymbolCacheContents containsObject:symbol]) {
            duplicateSymbols++;
          } else {
            [newSymbolCacheContents addObject:symbol];
          }
        }
      }
      
      CPWorkspaceSymbolCache *newWorkspaceSymbolCache = [CPWorkspaceSymbolCache symbolCacheWithSymbols:newSymbolCacheContents
                                                                                          forWorkspace:workspace];
      
      [self updateWorkspaceSymbolCacheForWorkspace:workspace withWorkspaceSymbolCache:newWorkspaceSymbolCache];
      
      self.symbolCachingInProgress = NO;
    }
  }
  @catch (NSException *exception) {
    LOG(@"EXCEPTION OCCURRED: %@", exception);
  }
}

- (NSArray *)topLevelCPSymbolsMatchingQuery:(NSString *)query
{
  query = [self normalizedQueryForQuery:query];
  
  CPWorkspaceSymbolCache *workspaceSymbolCache = [self workspaceSymbolCacheForWorkspace:[self currentWorkspace]];
  
  NSMutableArray *symbols = [workspaceSymbolCache.symbols mutableCopy];
  
  [symbols filterWithFuzzyQuery:query forKey:@"name"];
  
  NSArray *result = [self arrayOfCPSymbolsByWrappingIDESymbols:symbols forCPFileReference:nil];
  
  return result;
}

- (NSArray *)filesAndSymbolsFromProjectForQuery:(NSString *)query
{
  query = [self normalizedQueryForQuery:query];
  
	NSArray *symbols = [NSArray array];
  
  NSArray *files = [self cpFileReferencesMatchingQuery:query];
  
  if ([files count] < MAX_OBJECT_COUNT_FOR_SORT_AND_FILTER) {
    symbols = [self topLevelCPSymbolsMatchingQuery:query];
  } else {
    USER_LOG(@"not adding symbols - we already have %d entries.", MAX_OBJECT_COUNT_FOR_SORT_AND_FILTER);
  }
  
  NSArray* resultArray = [symbols arrayByAddingObjectsFromArray:files];
  
  // TODO/FIXME: We could add API search here
  resultArray = [self arrayByFilteringAndSortingArray:resultArray
                                       withFuzzyQuery:query
                                                  key:@"name"];
  
	return resultArray;
}

- (NSArray *)arrayByFilteringAndSortingArray:(NSArray *)unsortedArray withFuzzyQuery:(NSString *)query key:(NSString *)key
{
	if ([unsortedArray count] > MAX_OBJECT_COUNT_FOR_SORT_AND_FILTER) {
		return unsortedArray;
	}
  
	if (IsEmpty(query)) {
    return [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
      return [[obj1 valueForKey:key] compare:[obj2 valueForKey:key]];
    }];
    
	}
  
	NSMutableArray *mutableUnsortedArray = [unsortedArray mutableCopy];
	NSArray *scores = [mutableUnsortedArray arrayFilteredAndScoredWithFuzzyQuery:query forKey:key];
	
	NSArray *result = [mutableUnsortedArray sortedArrayUsingComparator:^NSComparisonResult(CPResult *a, CPResult *b) {
    NSUInteger indexA = [mutableUnsortedArray indexOfObject:a];
    NSUInteger indexB = [mutableUnsortedArray indexOfObject:b];
    
    if (indexA >= [scores count] || indexB >= [scores count]) {
      LOG(@"Something's wrong. indexA=%lu indexB=%lu score count=%lu unsorted count=%lu", (unsigned long)indexA, (unsigned long)indexB, (unsigned long)[scores count], (unsigned long)[mutableUnsortedArray count]);
      return NSOrderedSame;
    }
    
    float scoreA = [[scores objectAtIndex:indexA] floatValue] + [a scoreOffset];
    float scoreB = [[scores objectAtIndex:indexB] floatValue] + [b scoreOffset];
    
    if (scoreA > scoreB) {
      return NSOrderedAscending;
    
    } else if (scoreA < scoreB) {
      return NSOrderedDescending;
    }
    
    return NSOrderedSame;
  }];
  
	return result;
}

- (NSArray *)cpFileReferencesMatchingQuery:(NSString *)query
{
	query = [self normalizedQueryForQuery:query];
  
  NSMutableArray *projectFiles = [[self flattenedProjectContents] mutableCopy];
	[projectFiles filterWithFuzzyQuery:query forKey:@"name"];
  
  return [self arrayOfCPFileReferencesByWrappingXcodeFileReferences:projectFiles];
}

- (NSArray *)arrayOfCPFileReferencesByWrappingXcodeFileReferences:(NSArray *)xcodeFileReferences
{
	NSMutableArray *cpFileReferences = [NSMutableArray array];
	for (id xcodeFileReference in xcodeFileReferences) {
    @try {
      CPFileReference *cpFileRef = [[CPFileReference alloc] initWithPBXFileReference:xcodeFileReference];
      if (nil != cpFileRef) {
        [cpFileReferences addObject:cpFileRef];
      }
    }
    @catch (NSException *exception) {
      LOG(@"EXCEPTION OCCURRED: %@", exception);
    }
	}
  
	return cpFileReferences;
}

- (NSArray *)arrayOfCPFileReferencesByWrappingDVTFilePaths:(NSArray *)dvtFilePaths
{
  NSArray *cpFileReferences = @[];
  
  for (DVTFilePath *dvtFilePath in dvtFilePaths) {
    @try {
      CPFileReference *newCPFileReference = [[CPFileReference alloc] initWithDVTFilePath:dvtFilePath];
      cpFileReferences = [cpFileReferences arrayByAddingObject:newCPFileReference];
    }
    @catch (NSException *exception) {
      LOG(@"EXCEPTION OCCURRED: %@", exception);
    }
  }
  
  return cpFileReferences;
}

// used for history document urls
- (NSArray *)arrayOfCPFileReferencesByWrappingFileURLs:(NSArray *)fileURLs
{
  NSArray *cpFileReferences = @[];
  
  for (NSURL *fileURL in fileURLs) {
    @try {
      id newCPFileReference; // declaring as CPFileReference * generates a bunch of WTF warnings
      newCPFileReference = [[CPFileReference alloc] initWithFileURL:fileURL];
      cpFileReferences = [cpFileReferences arrayByAddingObject:newCPFileReference];
    }
    @catch (NSException *exception) {
      LOG(@"EXCEPTION OCCURRED: %@", exception);
    }
  }
  
  return cpFileReferences;
}

- (NSScreen *)currentScreen
{
  return nil;
}

- (BOOL)currentProjectIsIndexing
{
  return ([self.currentlyIndexedWorkspaces containsObject:[self currentWorkspace]] || [self isSymbolCachingInProgress]);
}

- (BOOL)isSymbolCachingInProgress
{
  return self.symbolCachingInProgress;
}

- (void)openFileOrSymbol:(id)fileOrSymbol
{
  [self openFileOrSymbol:fileOrSymbol inExternalEditor:NO];
}

- (void)openFileOrSymbol:(id)fileOrSymbol inExternalEditor:(BOOL)aUseExternal
{
  if (nil != fileOrSymbol && [fileOrSymbol isOpenable]) {
    if ([fileOrSymbol isKindOfClass:[CPSymbol class]]) {
      [self openCPSymbol:fileOrSymbol inExternalEditor:aUseExternal];
    } else if ([fileOrSymbol isKindOfClass:[CPFileReference class]]) {
      [self openCPFileReference:fileOrSymbol inExternalEditor:aUseExternal];
    }
  }
}

- (void)openCPFileReference:(CPFileReference *)cpFileReference
{
  [self openCPFileReference:cpFileReference inExternalEditor:NO];
}

- (void)openCPFileReference:(CPFileReference *)cpFileReference inExternalEditor:(BOOL)aUseExternal
{
  if (aUseExternal && ![cpFileReference.fileURL cp_opensInXcode]) {
    [[NSWorkspace sharedWorkspace] openURL:cpFileReference.fileURL];
  }
  else {
    DVTDocumentLocation *documentLocation = [[DVTDocumentLocation alloc] initWithDocumentURL:[cpFileReference fileURL]
                                                                                   timestamp:nil];
    
    IDEEditorOpenSpecifier *openSpecifier = [IDEEditorOpenSpecifier structureEditorOpenSpecifierForDocumentLocation:documentLocation
                                                                                                        inWorkspace:[self currentWorkspace]
                                                                                                              error:nil];
    
    [[self currentEditorContext] openEditorOpenSpecifier:openSpecifier];
  }
}

- (void)openCPSymbol:(CPSymbol *)symbol
{
  [self openCPSymbol:symbol inExternalEditor:NO];
}
- (void)openCPSymbol:(CPSymbol *)symbol inExternalEditor:(BOOL)aUseExternal
{
  if (!symbol.hasOccurrences) {
    LOG(@"WARNING: Tried to open a symbol without occurrences: %@", symbol);
    return;
  }
  
  @try {
    IDEIndexSymbolOccurrence *occurrence = [symbol relatedSymbolOccurrence];
    NSURL *url = occurrence.file.fileURL;
    if (aUseExternal && ![url cp_opensInXcode]) {
      [[NSWorkspace sharedWorkspace] cp_openURL:url onLine:occurrence.lineNumber];
    }
    else {
      IDEEditorOpenSpecifier *openSpecifier = [IDEEditorOpenSpecifier structureEditorOpenSpecifierForDocumentLocation:[symbol relatedDocumentLocation]
                                                                                                          inWorkspace:[self currentWorkspace]
                                                                                                                error:nil];
      [[self currentEditorContext] openEditorOpenSpecifier:openSpecifier];
    }
  }
  @catch (NSException * e) {
    LOG(@"EXCEPTION OCCURRED: %@", e);
  }
}

- (IDEEditorContext *)currentEditorContext
{
  return [[[self currentWorkspaceWindowController] editorArea] lastActiveEditorContext];
}

- (IDEWorkspaceWindowController *)currentWorkspaceWindowController
{
  return [IDEWorkspaceWindowController workspaceWindowControllerForWindow:[IDEWorkspaceWindow mc_lastActiveWorkspaceWindow]];
}

- (NSString *)currentProjectName
{
  return [[self currentWorkspace] name];
}

- (NSArray *)contentsForQuery:(NSString *)query fromResult:(CPResult *)result
{
  NSString *normalizedQuery = [self normalizedQueryForQuery:query];
  NSArray *resultArray = [NSArray new];
  
	if ([result isKindOfClass:[CPFileReference class]]) {
    CPFileReference *fileReference = (CPFileReference *)result;
    
		if (fileReference.isGroup) {
			PBXFileReference *pbxSymbol = [self pbxFileReferenceForCPFileReference:fileReference];
      
			resultArray = [pbxSymbol children];
			resultArray = [self arrayByFilteringAndSortingArray:resultArray withFuzzyQuery:normalizedQuery key:@"name"];
			resultArray = [self arrayOfCPFileReferencesByWrappingXcodeFileReferences:resultArray];
      
		} else {
			resultArray = [self cpSymbolsFromFile:fileReference matchingQuery:normalizedQuery];
			resultArray = [self arrayByFilteringAndSortingArray:resultArray withFuzzyQuery:normalizedQuery key:@"name"];
		}
	} else if ([result isKindOfClass:[CPSymbol class]]) {
    CPSymbol *symbol = (CPSymbol *)result;
    
    resultArray = [symbol children];
    resultArray = [self arrayByFilteringAndSortingArray:resultArray withFuzzyQuery:normalizedQuery key:@"name"];
	}
  
	return resultArray;
}

- (NSArray *)cpSymbolsFromFile:(CPFileReference *)fileObject matchingQuery:(NSString *)query
{
	NSString *normalizedQuery = [self normalizedQueryForQuery:query];
  
	@try {
    NSMutableArray *ideSymbols = [[self allIDEIndexSymbolsFromCPFileReference:fileObject] mutableCopy];
    
    [ideSymbols filterWithFuzzyQuery:normalizedQuery forKey:@"name"];
    
		NSArray *cpSymbols = [self arrayOfCPSymbolsByWrappingIDESymbols:ideSymbols forCPFileReference:fileObject];
    
    return cpSymbols;
    
	} @catch (NSException * e) {
		LOG(@"EXCEPTION OCCURRED: %@", e);
	}
  
	return [NSArray new];
}

// we wrap Xcode's IDE*Symbol into CPSymbol to provide copyWithZone: capabilities
- (NSArray *)arrayOfCPSymbolsByWrappingIDESymbols:(NSArray *)ideSymbols forCPFileReference:(CPFileReference *)fileObject
{
	NSMutableArray *cpSymbols = [NSMutableArray array];
  
  for (id ideSymbol in ideSymbols) {
    @try {
      CPSymbol *cpSymbol = [[CPSymbolCache sharedInstance] symbolForIDEIndexSymbol:ideSymbol relatedFilePath:[fileObject absolutePath]];
      [cpSymbols addObject:cpSymbol];
    }
    @catch (NSException *exception) {
      LOG(@"EXCEPTION OCCURRED: %@", exception);
    }
  }
  
	return cpSymbols;
}

// sometimes comparing absolute path is not enough if the reference
// isn't referencing the actual file, but for example a group of variantgroup (e.g. .xib file)
- (PBXFileReference *)pbxFileReferenceForCPFileReference:(CPFileReference *)cpFileReference
{
	for (PBXFileReference *pbxFileReference in [self flattenedProjectContents]) {
		if ([cpFileReference isEqualToPbxReference:pbxFileReference]) {
			return pbxFileReference;
		}
	}
  
	return nil;
}


- (NSArray *)recentlyVisitedFiles
{
  NSArray *recentDocumentURLs = [[self currentWorkspaceDocument] recentEditorDocumentURLs];
  
  // there are not just files, but also things like:
  // x-xcode-log://07BF5C48-BD53-4F83-9C14-1E8DB4EC5C09
  NSArray *fileURLs = [NSArray array];
  
  for (NSURL *documentURL in recentDocumentURLs) {
    if ([documentURL isFileURL]) {
      fileURLs = [fileURLs arrayByAddingObject:documentURL];
    }
  }
  
  return [self arrayOfCPFileReferencesByWrappingFileURLs:fileURLs];
}

- (NSArray *)recentlyVisited
{
  return [self recentlyVisitedFiles];
}

- (NSString *)currentSelectionSymbolString
{
  @try {
    DVTSourceExpression *selectedExpression = [[[self currentEditorContext] editor] selectedExpression];
    if (nil != selectedExpression) {
      NSString *selectedString = [selectedExpression textSelectionString];
      if (selectedString.length < MAX_AUTOCOPY_STRING_LENGTH) {
        return selectedString;
      }
    }
  }
  @catch (NSException *exception) {
    LOG(@"EXCEPTION: %@", exception);
  }
  
  return @"";
}

+ (NSArray *)symbolsForProject:(id)pbxProject
{
  return @[];
}

- (NSArray *)recursiveChildrenOfPBXGroup:(PBXGroup *)pbxGroup
{
  NSMutableArray *objects = [NSMutableArray array];
  
  [objects addObjectsFromArray:[pbxGroup children]];
  
  for (id child in [pbxGroup children]) {
    if ([child isKindOfClass:[PBXGroup class]]) {
      [objects addObjectsFromArray:[self recursiveChildrenOfPBXGroup:child]];
    }
  }
  
  return objects;
}

- (NSArray *)recursiveGroupsOfPBXGroup:(PBXGroup *)pbxGroup
{
  NSMutableArray *objects = [NSMutableArray array];
  
  for (id child in [pbxGroup children]) {
    if ([child isKindOfClass:[PBXGroup class]]) {
      [objects addObject:child];
      [objects addObjectsFromArray:[self recursiveGroupsOfPBXGroup:child]];
    }
  }
  
  return objects;
}

- (NSArray *)recursiveChildrenOfIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol
{
  NSMutableArray *objects = [NSMutableArray array];
  
  if ([ideIndexSymbol isKindOfClass:[IDEIndexContainerSymbol class]]) {
    IDEIndexContainerSymbol *containerSymbol = (IDEIndexContainerSymbol *)ideIndexSymbol;
    
    [objects addObjectsFromArray:[containerSymbol children]];
    
    for (id child in [containerSymbol children]) {
      [objects addObjectsFromArray:[self recursiveChildrenOfIDEIndexSymbol:child]];
    }
  }
  
  return objects;
}

- (NSArray *)allIDEIndexSymbolsFromCPFileReference:(CPFileReference *)fileReference
{
  NSMutableArray *objects = [NSMutableArray array];
  
  PBXFileReference *pbxFileReference = [self pbxFileReferenceForCPFileReference:fileReference];
  
  NSArray * topLevelSymbols = [[self currentIndex] topLevelSymbolsInFile:[pbxFileReference absolutePath]];
  
  for (IDEIndexSymbol *ideSymbol in topLevelSymbols) {
    [objects addObject:ideSymbol];
    [objects addObjectsFromArray:[self recursiveChildrenOfIDEIndexSymbol:ideSymbol]];
  }
  
  objects = [[objects arrayWithoutElementsHavingNilOrEmptyValueForKey:@"name"] mutableCopy];
  
  NSArray *objectsWithRealOccurrences = [NSArray array];
  
  // only add symbols that we know really occur in the file selected
  // TODO/FIXME: add occursInFile or sth to CPSymbol
  for (IDEIndexSymbol *ideSymbol in objects) {
    NSArray *declarations = [[ideSymbol declarations] allObjects];
    NSArray *definitions = [[ideSymbol definitions] allObjects];
    
    for (IDEIndexSymbolOccurrence *occurrence in [declarations arrayByAddingObjectsFromArray:definitions]) {
      if ([[[occurrence file] pathString] isEqualToString:fileReference.absolutePath]) {
        objectsWithRealOccurrences = [objectsWithRealOccurrences arrayByAddingObject:ideSymbol];
        break;
      }
    }
  }
  
  return objectsWithRealOccurrences;
}

- (NSArray *)flattenedProjectContents
{
  NSArray *workspaceReferencedContainers = [[[self currentWorkspace] referencedContainers] allObjects];
  NSArray *contents = [NSArray array];
  
  for (IDEContainer *container in workspaceReferencedContainers) {
    if ([container isKindOfClass:[Xcode3Project class]]) {
      Xcode3Project *xc3Project = (Xcode3Project *)container;
      Xcode3Group *xc3RootGroup = [xc3Project rootGroup];
      PBXGroup *mainPBXGroup = [xc3RootGroup group];
      
      contents = [contents arrayByAddingObjectsFromArray:[self recursiveChildrenOfPBXGroup:mainPBXGroup]];
    }
  }
  
  return contents;
}

- (IDEWorkspace *)currentWorkspace
{
  return [[self currentWorkspaceDocument] workspace];
}

- (IDEWorkspaceDocument *)currentWorkspaceDocument
{
  return [[IDEWorkspaceWindow mc_lastActiveWorkspaceWindow] document];
}

- (IDEIndex *)currentIndex
{
  return [[self currentWorkspace] index];
}
@end
