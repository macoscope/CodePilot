//
//  CPSymbol.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPFileReference.h"
#import "CPSymbol.h"
#import <objc/objc-class.h>

@interface CPSymbol ()
@property (nonatomic, assign, readwrite) BOOL hasOccurrences;
@end

@implementation CPSymbol
- (CPSymbol *)init
{
  self = [super init];
  
  if (self) {
    self.childrenCache = [NSArray array];
    self.cachedRelatedSymbolOccurrence = nil;
    self.hasOccurrences = YES;
  }
  
  return self;
}

- (CPSymbol *)initWithIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol forCPFileReference:(CPFileReference *)fileReference
{
  return [self initWithIDEIndexSymbol:ideIndexSymbol forRelatedFileAtPath:fileReference.absolutePath];
}

- (CPSymbol *)initWithIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol forRelatedFileAtPath:(NSString *)relatedFilePath
{
	self = [self init];
  
	if (self) {
    self.wrappedObject = ideIndexSymbol;
    self.relatedFilePath = relatedFilePath;
  }
  
	return self;
}

- (void)logOccurrences
{
  LOG(@"============= %@", self);
  
  LOG(@"=== modelOccurrence: %@", [self.wrappedObject modelOccurrence]);
  
  LOG(@"=== DECLARATIONS", self);
  for (IDEIndexSymbolOccurrence *occurrence in [self.wrappedObject declarations]) {
    LOG(@"%@ - file: %@ location %@ lineNumber %d", occurrence, [occurrence file], [occurrence location], [occurrence lineNumber]);
  }
  
  LOG(@"=== DEFINITIONS", self);
  for (IDEIndexSymbolOccurrence *occurrence in [self.wrappedObject definitions]) {
    LOG(@"%@ - file: %@ location %@ lineNumber %d", occurrence, [occurrence file], [occurrence location], [occurrence lineNumber]);
  }
  
  LOG(@"=== OCCURRENCES", self);
  for (IDEIndexSymbolOccurrence *occurrence in [self.wrappedObject occurrences]) {
    LOG(@"%@ - file: %@ location %@ lineNumber %d", occurrence, [occurrence file], [occurrence location], [occurrence lineNumber]);
  }
}

- (DVTTextDocumentLocation *)relatedDocumentLocation
{
  IDEIndexSymbolOccurrence *occurrence = [self relatedSymbolOccurrence];
  
  NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
  
  return [[DVTTextDocumentLocation alloc] initWithDocumentURL:[[occurrence file] fileURL]
                                                    timestamp:timestamp
                                                    lineRange:NSMakeRange([occurrence lineNumber] - 1, 1)];
}

- (void)cacheRelatedSymbolOccurrence
{
  if (nil == self.cachedRelatedSymbolOccurrence && _hasOccurrences) {
    NSArray *orderedOccurrences = [NSArray array];
    
    NSArray *occurrences = [[self.wrappedObject occurrences] allObjects];
    NSArray *definitions = [[self.wrappedObject definitions] allObjects];
    
    if ([occurrences count] > 0) {
      orderedOccurrences = [orderedOccurrences arrayByAddingObjectsFromArray:definitions];
      orderedOccurrences = [orderedOccurrences arrayByAddingObjectsFromArray:occurrences];
      
      for (IDEIndexSymbolOccurrence *occurrence in orderedOccurrences) {
        if (IsEmpty(self.relatedFilePath) || [[[occurrence file] pathString] isEqualToString:self.relatedFilePath]) {
          self.cachedRelatedSymbolOccurrence = occurrence;
          break;
        }
      }
      
      self.cachedRelatedSymbolOccurrence = self.cachedRelatedSymbolOccurrence ?: [orderedOccurrences objectAtIndex:0];
      
    } else {
      self.hasOccurrences = NO;
      LOG(@"WARNING: no occurrences found for symbol: %@", self);
    }
  }
}

- (IDEIndexSymbolOccurrence *)relatedSymbolOccurrence
{
  [self cacheRelatedSymbolOccurrence];
  
  return self.cachedRelatedSymbolOccurrence;
}

- (NSImage *)icon
{
  return [self.wrappedObject icon];
}

- (NSString *)originalClassName
{
	return [self.wrappedObject className];
}

- (NSString *)sourceFile
{
  if (nil != [self relatedSymbolOccurrence]) {
    NSURL *sourceFileURL = [[[self relatedSymbolOccurrence] file] fileURL];
    return [sourceFileURL lastPathComponent];
  }
  
  return @"(sourceFile)";
}

- (NSString *)name
{
  return [self.wrappedObject name];
}

- (BOOL)isEqualToIDEIndexSymbol:(id)ideIndexSymbol
{
	return (self.wrappedObject == ideIndexSymbol);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: originalClassName: %@ name: %@ sourceFile: %@ >", [super description], self.originalClassName, self.name, self.sourceFile];
}

- (id)copyWithZone:(NSZone *)zone
{
  CPSymbol *newSelf = [[[self class] allocWithZone:zone] init];
	newSelf.wrappedObject = self.wrappedObject;
	return newSelf;
}

// we can list the contents
- (BOOL)isSearchable
{
	return [self.wrappedObject isKindOfClass:[IDEIndexContainerSymbol class]];
}

// we can open it with enter
- (BOOL)isOpenable
{
	return YES;
}

- (NSString *)symbolTypeName
{
	NSMutableString *_name = [self.originalClassName mutableCopy];
  
	MC_SED(_name, @"IDE", @"");
	MC_SED(_name, @"Symbol", @"");
  
	return [_name lowercaseString];
}

- (BOOL)isCategory
{
	return [self.wrappedObject isKindOfClass:[IDEIndexCategorySymbol class]];
}

- (NSArray *)children
{
  if ([self.wrappedObject isKindOfClass:[IDEIndexContainerSymbol class]] &&
      0 == [self.childrenCache count]) {
    self.childrenCache = [NSArray array];
    
    for (IDEIndexSymbol *ideIndexSymbol in [(IDEIndexContainerSymbol *)self.wrappedObject children]) {
      CPSymbol *childSymbol = [[CPSymbol alloc] initWithIDEIndexSymbol:ideIndexSymbol
                                                  forRelatedFileAtPath:self.relatedFilePath];
      
      self.childrenCache = [self.childrenCache arrayByAddingObject:childSymbol];
    }
  }
  
  return self.childrenCache;
}

- (BOOL)hasOccurrences
{
  [self cacheRelatedSymbolOccurrence];
  
  return _hasOccurrences;
}

- (double)scoreOffset
{
  return [self isImplementation] ? 0.01 : 0;
}
@end