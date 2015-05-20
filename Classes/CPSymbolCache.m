//
//  CPSymbolCache.m
//  CodePilot
//
//  Created by karol on 5/11/12.
//  Copyright (c) 2012 Macoscope. All rights reserved.
//

#import "CPSymbolCache.h"
#import "CPSymbol.h"
#import "CPXcodeInterfaces.h"

@interface CPSymbolCache ()
@property (nonatomic, strong) NSMutableDictionary *symbolsForFilePath;
@end

@implementation CPSymbolCache
+ (CPSymbolCache *)sharedInstance
{
  static CPSymbolCache *symbolCacheSharedInstance;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    symbolCacheSharedInstance = [[CPSymbolCache alloc] init];
  });
  
  return symbolCacheSharedInstance;
}

- (id)init
{
  self = [super init];
  
  if (self) {
    self.symbolsForFilePath = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFileChangeNotification:) name:IDEEditorDocumentDidChangeNotification object:nil];
  }
  
  return self;
}

- (void)onFileChangeNotification:(NSNotification *)notification
{
  /*
   Be careful with [IDESourceCodeDocument class], use NSClassFromString(@"IDESourceCodeDocument") instead.
   The reason is IDESourceCodeDocument is a private class residing in some dylib loaded after launching Xcode. However,
   since Xcode 6.3.2 plugins are loaded before loading the dylib with IDESourceCodeDocument, and so linker freaks out.
   NSClassFromString(@"IDESourceCodeDocument"), though not perfect, is safer because will return nil until appropriate
   dylib is loaded.
   */
  if (![[notification object] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
    return;
  }
  
  IDESourceCodeDocument *document = [notification object];
  
  for (Xcode3FileReference *fileReference in (NSArray *)[document knownFileReferences]) {
    [self.symbolsForFilePath removeObjectForKey:[[fileReference resolvedFilePath] pathString]];
  }
}

- (CPSymbol *)symbolForIDEIndexSymbol:(IDEIndexSymbol *)ideIndexSymbol relatedFilePath:(NSString *)relatedFilePath
{
  if (relatedFilePath == nil) {
    relatedFilePath = @"";
  }
  
  if (nil == self.symbolsForFilePath[relatedFilePath]) {
    self.symbolsForFilePath[relatedFilePath] = [NSMutableDictionary dictionary];
  }
  
  NSNumber *symbolHash = @([ideIndexSymbol hash]);
  NSMutableDictionary *symbols = self.symbolsForFilePath[relatedFilePath];
  
  if (nil == symbols[symbolHash]) {
    symbols[symbolHash] = [[CPSymbol alloc] initWithIDEIndexSymbol:ideIndexSymbol forRelatedFileAtPath:relatedFilePath];
  }
  
  return symbols[symbolHash];
}

@end
