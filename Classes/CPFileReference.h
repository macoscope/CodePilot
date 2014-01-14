//
//  CPFileReference.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/15/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPResult.h"

@interface CPFileReference : CPResult
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *absolutePath;
@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSString *projectName;
@property (nonatomic, assign) BOOL subprojectFile;
@property (nonatomic, strong) NSString *originalClassName;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, assign) BOOL isOpenable;
@property (nonatomic, assign) BOOL isSearchable;
@property (nonatomic, assign) BOOL isOpenableInEditor;

- (CPFileReference *)initWithPBXFileReference:(PBXFileReference *)pbxFileReference;
- (CPFileReference *)initWithFileURL:(NSURL *)_fileURL;
- (NSString *)name;
- (BOOL)isEqualToPbxReference:(PBXFileReference *)pbxReference;
+ (BOOL)pbxFileReferenceIsImportable:(PBXFileReference *)pbxFileReference;
- (CPFileReference *)initWithDVTFilePath:(DVTFilePath *)_filePath;
@end