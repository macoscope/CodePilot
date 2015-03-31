//
//  CPFileReference.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPFileReference.h"
#import "CPCodePilotConfig.h"
#import "CPXcodeInterfaces.h"
#import "objc/objc-class.h"

@implementation CPFileReference
- (CPFileReference *)initWithDVTFilePath:(DVTFilePath *)dvtFilePath
{
  return [self initWithFileURL:[dvtFilePath fileURL]];
}

- (CPFileReference *)initWithFileURL:(NSURL *)fileURL
{
  self = [super init];
  
  if (self) {
    self.fileURL = fileURL;
    self.fileName = [fileURL lastPathComponent];
    self.absolutePath = [fileURL path];
    self.isGroup = NO;
    self.subprojectFile = NO;
    self.groupName = nil;
    self.isOpenable = !self.isGroup;
    self.isSearchable = YES;
    self.isOpenableInEditor = self.isOpenable;
    
    if (!IsEmpty(self.absolutePath) &&
        [[NSFileManager defaultManager] fileExistsAtPath:self.absolutePath]) {
      DVTFilePath *dvtFilePath = [DVTFilePath filePathForPathString:self.absolutePath];
      self.icon = [dvtFilePath navigableItem_image];
    }
  }
  
  return self;
}

- (CPFileReference *)initWithPBXFileReference:(PBXFileReference *)pbxFileReference
{
	self = [super init];
  
  if (self) {
    if (![CPFileReference pbxFileReferenceIsImportable:pbxFileReference]) {
      return nil;
    }
    
    self.fileName = [pbxFileReference name];
    self.absolutePath = [pbxFileReference resolvedAbsolutePath];
    self.originalClassName = NSStringFromClass([pbxFileReference class]);
    self.isGroup = [pbxFileReference isGroup];
    
    self.subprojectFile = NO;
    
    if (!IsEmpty(self.absolutePath)) {
      self.fileURL = [NSURL fileURLWithPath:self.absolutePath];
    }
    
    self.groupName = nil;
    
    @try {
      self.groupName = [[pbxFileReference group] name];
      
      PBXContainer *projectContainer = [pbxFileReference container];
      
      if (nil != projectContainer) {
        self.projectName = [projectContainer name];
      }
    }
    @catch (NSException * e) {
      LOG(@"EXCEPTION: %@", e);
    }
    
    self.icon = nil;
    
    self.isOpenable = !self.isGroup;
    self.isSearchable = YES;
    self.isOpenableInEditor = self.isOpenable;
    
    if ([pbxFileReference isGroup]) {
      self.icon = [[[IDEGroup alloc] init] navigableItem_image];
    } else {
      if (!IsEmpty(self.absolutePath) && [[NSFileManager defaultManager] fileExistsAtPath:self.absolutePath]) {
        DVTFilePath *dvtFilePath = [DVTFilePath filePathForPathString:self.absolutePath];
        self.icon = [dvtFilePath navigableItem_image];
      }
    }
  }
  
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: fileName: %@ groupName: %@ absolutePath: %@",
          [super description], self.fileName, self.groupName, self.absolutePath];
}

- (NSString *)name
{
	return self.fileName;
}

- (NSString *)sourceFile
{
  return [[self.fileURL path] lastPathComponent];
}

- (id)copyWithZone:(NSZone *)zone
{
  CPFileReference *newSelf = [[[self class] allocWithZone:zone] init];
  
	newSelf.fileName = self.fileName;
	newSelf.groupName = self.groupName;
	newSelf.icon = self.icon;
	newSelf.absolutePath = self.absolutePath;
	newSelf.projectName = self.projectName;
	newSelf.subprojectFile = self.subprojectFile;
	newSelf.originalClassName = self.originalClassName;
	newSelf.isGroup = self.isGroup;
	newSelf.isOpenable = self.isOpenable;
	newSelf.isSearchable = self.isSearchable;
  
	return newSelf;
}

- (BOOL)isEqualToPbxReference:(PBXFileReference *)pbxReference
{
	CPFileReference *tmpRef = [[CPFileReference alloc] initWithPBXFileReference:pbxReference];
  
	// group name, project name and subproject status aren't compared any more, as
	// xcode tends to confuse those for subprojects
	return ([tmpRef.absolutePath isEqualToString:self.absolutePath] &&
					[tmpRef.fileName isEqualToString:self.fileName] &&
					(tmpRef.isGroup == self.isGroup));
}

+ (BOOL)pbxFileReferenceIsImportable:(PBXFileReference *)pbxFileReference
{
	if (nil == pbxFileReference) {
		return NO;
	}
  
	PBXFileType *fileType = [pbxFileReference fileType];
	if (fileType == nil) {
		// xibs and folders don't have a filetype
		return YES;
	}
  
	if ([fileType isBundle] ||
      [fileType isApplication] ||
      [fileType isLibrary] ||
      [fileType isFramework] ||
      [fileType isProjectWrapper] ||
      [fileType isTargetWrapper]/* ||
      [fileType isExecutable] */) { // ruby files return true for isExecutable.
    return NO;
  }
  
	return YES;
}

- (double)scoreOffset
{
  return [self isImplementation] ? 16.01 : 16;
}
@end