//
//  NSAppleEventDescriptor+ToObject.m
//  Quark
//
//  Created by Daniel on 09-10-15.
//  Copyright 2009 Macosope. All rights reserved.
//

#import "NSAppleEventDescriptor+ToObject.h"
#import "CPCodePilotConfig.h"

// TODO: brak obslugi ldt - 'ldt ' (LongDateTime) http://lists.apple.com/archives/applescript-implementors/2003/Mar/msg00019.html

@interface NSAppleEventDescriptor (MCPrivate)
- (id)_toDictionary;
@end

@implementation NSAppleEventDescriptor (ToObject)

- (id)toObject
{
	const AEDesc *aed = [self aeDesc];
	DescType desc = aed->descriptorType;
	id ret = nil;
	switch (desc) {
		case typeAEList:
			ret = [NSMutableArray array];
			unsigned int i = 1; // AS lists are 1-indexed.
			for (i=1; i <= [self numberOfItems]; i++)
				[ret addObject:[[self descriptorAtIndex:i] toObject]];
			break;
		case typeAERecord:
			ret = [self _toDictionary];
			break;
		case typeTrue:
			ret = [NSNumber numberWithBool:YES];
			break;
		case typeFalse:
			ret = [NSNumber numberWithBool:NO];
			break;
		case typeNull:
			ret = [NSNull null];
			break;
		case typeChar:
		case 'utxt':
			ret = [self stringValue];
			break;
		case 'long':
		case 'shor':
			ret = [NSNumber numberWithLong:[self int32Value]];
			break;
		case 'doub':
		case 'sing':
			ret = [NSNumber numberWithDouble:[[self stringValue] doubleValue]];
			break;
		case 'bool':
			ret = [NSNumber numberWithBool:[[self stringValue] boolValue]];
			break;
    default:
      //http://lists.apple.com/archives/applescript-implementors/2003/Mar/msg00019.html
      LOG(@"Unknown AEType: '%C%C%C%C'", _cmd, desc >> 24 & 0xFF, desc >> 16 & 0xFF, desc >> 8 & 0xFF, desc & 0xFF);
			ret = [self stringValue];
	}
	return ret;
}

- (id)_toDictionary
{
	unsigned long i = 1; // AS lists are 1-indexed
	NSMutableDictionary *d = [NSMutableDictionary dictionary];
	for (i=1; i <= [self numberOfItems]; i++) {
		AEKeyword keyword = [self keywordForDescriptorAtIndex:i];
		if (keyword == 'usrf') {
			// 'usrf' records appear to be a list wherein the first item is the key and the second item is the object
			NSAppleEventDescriptor *list = [self paramDescriptorForKeyword:keyword];
			unsigned long j = 1; // AS lists are 1-indexed
			while (j <= [list numberOfItems]) {
				NSString *key = [[list descriptorAtIndex:j++] toObject];
				NSString *obj = [[list descriptorAtIndex:j++] toObject];
				if (key && obj) [d setObject:obj forKey:key];
			}
		}	else { // These are the keys that are based on keywords.  They can just be tossed in.
			NSString *key = nil;
			// This is a short list of Applescript keywords.  If it's not in this list, then we use the 4 char code.
			switch (keyword) {
				case 'pnam': key = @"name"; break;
				case 'url ': key = @"url"; break;
				case 'kywd': key = @"keyword"; break;
				case 'pALL': key = @"properties"; break;
				case 'capp': key = @"application"; break;
				case 'cwin': key = @"window"; break;
				case 'cmnu': key = @"menu"; break;
				case 'TEXT': key = @"string"; break;
				case 'reco': key = @"record"; break;
				case 'nmbr': key = @"number"; break;
				default:
					key = [NSString stringWithFormat:@"%C%C%C%C", (unichar)(keyword >> 24 & 0xFF), (unichar)(keyword >> 16 & 0xFF), (unichar)(keyword >> 8 & 0xFF), (unichar)(keyword & 0xFF)];
					LOG(@"Unknown applescript keyword: %@", key);
			}
			// If the keyword is 'usrf', then it's likely the non-keyword items of a record.  Let's place them in the current dictionary.
			[d setObject:[[self paramDescriptorForKeyword:keyword] toObject] forKey:key];
		}
	}
	return d;
}

@end

