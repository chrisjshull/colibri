//
//  AUPathUtilitiesAddition.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUCommonGround.h"

/* AUUserDirectory enum type */

typedef enum {
	AUUserDirectoryHome = 0,
	AUUserDirectoryDesktop,
	AUUserDirectoryDocuments,
	AUUserDirectoryLibrary,
	AUUserDirectoryMusic,
	AUUserDirectoryMovies,
	AUUserDirectoryPictures,
	AUUserDirectoryDownloads,
	AUUserDirectorySites,
	AUUserDirectoryPublic,
	AUUserDirectoryApplicationSupport,
	AUUserDirectoryAudio,
	AUUserDirectoryCaches,
	AUUserDirectoryFonts,
	AUUserDirectoryInternetPlugIns,
	AUUserDirectoryKeychains,
	AUUserDirectoryLogs,
	AUUserDirectoryPlugins,
	AUUserDirectoryPreferences,
	AUUserDirectoryPrinters,
	AUUserDirectoryScreenSavers,
	AUUserDirectoryScripts,
	AUUserDirectorySounds,
	AUUserDirectoryWidgets,
	AUUserDirectoryBSDTemporary
} AUUserDirectory;

/*!
	@function AUUserPathForDirectory
	@discussion Returns the path according to the constant type directory.
	@param The type of directory.
	@result The user's constant directory.
 */
NSString *AUUserPathForDirectory(AUUserDirectory directory);

/*!
	@function AUSearcPathForDirectoryInDomain
	@discussion Returns the first matched filepath for the specified directory in the specified domain;
		If expandTilde is YES, tildes are expanded as described in stringByExpandingTildeInPath.
	@param NSSearchPathDirectory integer.
	@param NSSearchPathDomainMask integer.
	@param expandTilde BOOL.
	@result The first matched filepath or nil if not found.
 */
NSString *AUSearcPathForDirectoryInDomain(
	NSSearchPathDirectory directory,
	NSSearchPathDomainMask domainMask,
	BOOL expandTilde
);

/*!
	@function AUVolumeNameAtMountPoint
	@discussion Returns the volume display name for a given mount point.
	@param the volume mount point.
	@result The volume display name;
		otherwise nil, if not a valid mount point.
 */
NSString *AUVolumeNameAtMountPoint(NSString *mountpoint);

/*!
	@function AUMacOSVolumeDisplayName
	@discussion Returns the MacOS volume display name for "/" mount point.
	@result The MacOS volume display name.
 */
NSString *AUMacOSVolumeDisplayName(void);

/*!
	@function AUFinderDisplayNameForPath
	@discussion Returns the MacOS Finder display name for a given Path.
	@param A filepath.
	@result The MacOS Finder display name.
 */
NSString *AUFinderDisplayNameForPath(NSString *path);

/*!
	@function AUFileNamesToQuotedPaths
	@discussion Returns a string where each elements have been quoted and separated by a space.
	@param filenames.
	@result Quoted Paths.
 */
NSString *AUFileNamesToQuotedPaths(NSArray *filenames);

/*!
	@function AUUserHomeDirectory
	@discussion Returns the path to the current user's home directory.
	@result The user's home directory.
 */
AU_INLINE NSString *AUUserHomeDirectory(void)
{
	return NSHomeDirectory();
}

/*!
	@function AUUserDesktopDirectory
	@discussion Returns the path to the current user's desktop directory.
	@result The user's desktop directory.
 */
AU_INLINE NSString *AUUserDesktopDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryDesktop);
}

/*!
	@function AUUserDocumentsDirectory
	@discussion Returns the path to the current user's documents directory.
	@result The user's documents directory.
 */
AU_INLINE NSString *AUUserDocumentsDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryDocuments);
}

/*!
	@function AUUserLibraryDirectory
	@discussion Returns the path to the current user's library directory.
	@result The user's library directory.
 */
AU_INLINE NSString *AUUserLibraryDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryLibrary);
}

/*!
	@function AUUserMusicDirectory
	@discussion Returns the path to the current user's music directory.
	@result The user's music directory.
 */
AU_INLINE NSString *AUUserMusicDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryMusic);
}

/*!
	@function AUUserMoviesDirectory
	@discussion Returns the path to the current user's movies directory.
	@result The user's movies directory.
 */
AU_INLINE NSString *AUUserMoviesDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryMovies);
}

/*!
	@function AUUserPicturesDirectory
	@discussion Returns the path to the current user's pictures directory.
	@result The user's pictures directory.
 */
AU_INLINE NSString *AUUserPicturesDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryPictures);
}

/*!
	@function AUUserDownloadsDirectory
	@discussion Returns the path to the current user's downloads directory.
	@result The user's downloads directory.
 */
AU_INLINE NSString *AUUserDownloadsDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryDownloads);
}

/*!
	@function AUUserSitesDirectory
	@discussion Returns the path to the current user's sites directory.
	@result The user's sites directory.
 */
AU_INLINE NSString *AUUserSitesDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectorySites);
}

/*!
	@function AUUserPublicDirectory
	@discussion Returns the path to the current user's public directory.
	@result The user's public directory.
 */
AU_INLINE NSString *AUUserPublicDirectory(void)
{
	return AUUserPathForDirectory(AUUserDirectoryPublic);
}

/* EOF */