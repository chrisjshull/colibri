//
//  AUPathUtilitiesAddition.m
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUPathUtilitiesAddition.h"
#import "AUCommonGround.h"

#define _kAUUserPathComponentDesktop @"Desktop"
#define _kAUUserPathComponentDocuments @"Documents"
#define _kAUUserPathComponentLibrary @"Library"
#define _kAUUserPathComponentMusic @"Music"
#define _kAUUserPathComponentMovies @"Movies"
#define _kAUUserPathComponentPictures @"Pictures"
#define _kAUUserPathComponentDownloads @"Downloads"
#define _kAUUserPathComponentSites @"Sites"
#define _kAUUserPathComponentPublic @"Public"
#define _kAUUserPathComponentApplicationSupport @"Library/Application Support"
#define _kAUUserPathComponentAudio @"Library/Audio"
#define _kAUUserPathComponentCaches @"Library/Caches"
#define _kAUUserPathComponentFonts @"Library/Fonts"
#define _kAUUserPathComponentInternetPlugIns @"Library/Internet Plug-Ins"
#define _kAUUserPathComponentKeychains @"Library/Keychains"
#define _kAUUserPathComponentLogs @"Library/Logs"
#define _kAUUserPathComponentPlugins @"Library/Plug-ins"
#define _kAUUserPathComponentPreferences @"Library/Preferences"
#define _kAUUserPathComponentPrinters @"Library/Printers"
#define _kAUUserPathComponentScreenSavers @"Library/Screen Savers"
#define _kAUUserPathComponentScripts @"Library/Scripts"
#define _kAUUserPathComponentSounds @"Library/Sounds"
#define _kAUUserPathComponentWidgets @"Library/Widgets"
#define _kAUUserPathBSDTemporary @"/private/tmp"

#define _kAUMacOSVolumeDisplayName @"MachintoshHD"
#define _kAUMacOSVolumeMountPoint @"/"

#include <sys/param.h>
#include <sys/attr.h>
#include <limits.h>
#include <errno.h>

/*
*  NSString *AUUserPathForDirectory(AUUserDirectory directory);
*/
NSString *AUUserPathForDirectory(AUUserDirectory directory)
{
	NSString *path = nil;
	NSString *home = NSHomeDirectory();
	switch (directory) {
		case AUUserDirectoryDesktop:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentDesktop];
		break;
		case AUUserDirectoryDocuments:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentDocuments];
		break;
		case AUUserDirectoryLibrary:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentLibrary];
		break;
		case AUUserDirectoryMusic:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentMusic];
		break;
		case AUUserDirectoryMovies:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentMovies];
		break;
		case AUUserDirectoryPictures:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentPictures];
		break;
		case AUUserDirectoryDownloads:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentDownloads];
		break;
		case AUUserDirectorySites:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentSites];
		break;
		case AUUserDirectoryPublic:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentPublic];
		break;
		case AUUserDirectoryApplicationSupport:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentApplicationSupport];
		break;
		case AUUserDirectoryAudio:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentAudio];
		break;
		case AUUserDirectoryCaches:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentCaches];
		break;
		case AUUserDirectoryFonts:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentFonts];
		break;
		case AUUserDirectoryInternetPlugIns:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentInternetPlugIns];
		break;
		case AUUserDirectoryKeychains:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentKeychains];
		break;
		case AUUserDirectoryLogs:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentLogs];
		break;
		case AUUserDirectoryPlugins:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentPlugins];
		break;		
		case AUUserDirectoryPreferences:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentPreferences];
		break;
		case AUUserDirectoryPrinters:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentPrinters];
		break;
		case AUUserDirectoryScreenSavers:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentScreenSavers];
		break;
		case AUUserDirectoryScripts:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentScripts];
		break;
		case AUUserDirectorySounds:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentSounds];
		break;
		case AUUserDirectoryWidgets:
			path = [home stringByAppendingPathComponent:_kAUUserPathComponentWidgets];
		break;
		case AUUserDirectoryBSDTemporary:
			path = [NSString stringWithString:_kAUUserPathBSDTemporary];
		break;
		default:
			path = home;
	}	
	return path;
}

/*
*  NSString *AUSearcPathForDirectoryInDomain(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);
*/
NSString *AUSearcPathForDirectoryInDomain(
	NSSearchPathDirectory directory,
	NSSearchPathDomainMask domainMask,
	BOOL expandTilde) 
{
	NSArray *paths;
	NSString *path;
	
	if ((paths = NSSearchPathForDirectoriesInDomains(directory, domainMask, YES))) {
		if ((path = [paths objectAtIndex:0])) {
			return path;
		}
	}
	return nil;
}

/*
*  NSString *AUVolumeNameAtMountPoint(NSString *mountpoint);
*/
NSString *AUVolumeNameAtMountPoint(NSString *mountpoint)
{
	NSString *ret = nil;
	int status = 0;
	char buf[MAXPATHLEN+1];
	
	typedef struct attrlist attrlist_t;
	attrlist_t list = {0};
	
	typedef struct {
 		size_t size;
 		attrreference_t data;
 		char name[MAXPATHLEN+1];
 	} attrname_t;
 	attrname_t attr = {0};
	
	if (mountpoint) {
		list.bitmapcount = ATTR_BIT_MAP_COUNT;
		list.volattr = ATTR_VOL_INFO|ATTR_VOL_NAME;		
		if (0 == getattrlist([mountpoint fileSystemRepresentation], &list, &attr, sizeof(attr), 0)) {
			status = sprintf(buf, "%.*s",
				 (int)attr.data.attr_length, 
				 (((char *)&attr.data) + 
				 attr.data.attr_dataoffset)
			);
			
			if (status) {
				ret = [[[NSString alloc] initWithBytes:buf length:strlen(buf) encoding:NSUTF8StringEncoding] autorelease];
			}
		}
	}
	return ret;
}

/*
*  NSString *AUMacOSVolumeDisplayName(void);
*/
NSString *AUMacOSVolumeDisplayName(void)
{
	NSString *displayName;	
	if (!(displayName = AUVolumeNameAtMountPoint(_kAUMacOSVolumeMountPoint))) {
		displayName = [NSString stringWithString:_kAUMacOSVolumeDisplayName];
	}
	return displayName;
}

/*
*  NSString *AUFinderDisplayNameForPath(NSString *path);
*/
NSString *AUFinderDisplayNameForPath(NSString *path) {
	/**
		@future
		e.g /Library -> return Bibliothèque
		e.g /Users/username/Desktop -> return Bureau
	*/
	NSString *displayName = nil, *dirName;
	if (path) {
		if ([path isEqualToString:_kAUMacOSVolumeMountPoint]) {
			displayName = AUMacOSVolumeDisplayName();
		} else {
			if ((dirName = [path lastPathComponent])) {
				// displayName = NSLocalizedString(dirName, dirName);
				displayName = [NSString stringWithString:dirName];
			}
		}
	}
	return displayName;
}

/*
*  NSString *AUFileNamesToQuotedPaths(NSArray *filenames);
*/
NSString *AUFileNamesToQuotedPaths(NSArray *filenames) {
	NSString *result, *append;
	NSMutableString *concat = [[NSMutableString alloc] init];
	NSUInteger index = 0;
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	for (; index < [filenames count]; index++) {
		id obj = [filenames objectAtIndex:index];
		if ([obj length]) {
			append = [[NSString alloc] initWithFormat:@"\"%@\"", obj];
			[concat appendString:append];
			if (index < [filenames count] -1) {
				[concat appendString:@" "];
			}
			[append release];
		}
	}
	[pool drain];
	result = [NSString stringWithString:concat];
	[concat release];
	return result;
}

Boolean AUIsFinderAlias(const char *pathname) {
	FSRef ref;
	Boolean aliasFileFlag, folderFlag;
	
	if (noErr == FSPathMakeRef((const UInt8 *)pathname, &ref, NULL)) {
		if (noErr == FSIsAliasFile(&ref, &aliasFileFlag, &folderFlag)) {
			return aliasFileFlag;
		}
	}
	
	return FALSE;
}

char *AUResolveFinderAlias(const char *pathname) {
	FSRef ref;
	Boolean targetIsFolder, wasAliased;
	char *resolvedAlias;	
	if (noErr == FSPathMakeRef((const UInt8 *)pathname, &ref, NULL)) {
		if (noErr == FSResolveAliasFile(&ref, TRUE, &targetIsFolder, &wasAliased)) {
			if (TRUE == wasAliased) {
				if (NULL != (resolvedAlias = malloc(PATH_MAX + 1))) {
					if (noErr == FSRefMakePath(&ref, (UInt8 *)resolvedAlias, PATH_MAX)) {
						errno = 0;
						return resolvedAlias;
					}
					free(resolvedAlias);
				}
			}
		}
	}	
	if (!errno)
		errno = ENOENT;
	
	return NULL;
}

BOOL AUIsFinderAliasAtPath(NSString *pathname) {
	return AUIsFinderAlias([pathname fileSystemRepresentation]) ? YES : NO;
}

NSString *AUStringByResolvingFinderAliasInPath(NSString *pathname) {
	NSString *result;
	char *path;
	if ((path = AUResolveFinderAlias([pathname fileSystemRepresentation]))) {
		result = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
		free(path);
		return result;
	}
	return pathname;
}

NSString *AUStringByResolvingAliasInPath(NSString *pathname) {
	NSString *path  = [pathname stringByResolvingSymlinksInPath];
	while(AUIsFinderAliasAtPath(path)) {
		path = AUStringByResolvingFinderAliasInPath(path);
	}
	return [path stringByResolvingSymlinksInPath];
}

/* EOF */