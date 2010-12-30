//
//  AUColorAdditionExtra.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUColorAdditionExtra.h"

@interface NSColor(AUColorAdditionExtraUnexposed)

- (NSBitmapImageRep *)bitmapImageRepWithSize:(NSSize)size;
- (NSBitmapImageRep *)bitmapImageRepWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha;
- (NSData *)dataWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha storageType:(NSBitmapImageFileType)storageType;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size storageType:(NSBitmapImageFileType)storageType;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size storageType:(NSBitmapImageFileType)storageType ignoreAlpha:(BOOL)ignoreAlpha;

@end

@implementation NSColor(AUColorAdditionExtraUnexposed)

- (NSBitmapImageRep *)bitmapImageRepWithSize:(NSSize)size
{
	return [self bitmapImageRepWithSize:size ignoreAlpha:NO];
}

- (NSBitmapImageRep *)bitmapImageRepWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha
{
	NSImage *buffer;
	NSBitmapImageRep *rep;
	NSRect rect;
	NSSize min = NSMakeSize(1.0, 1.0);
	
	size.width = MAX(min.width, size.width);
	size.height = MAX(min.height, size.height);
	
	if ((buffer = [[NSImage alloc] initWithSize:size])) {
		rect = NSMakeRect(0.0, 0.0, size.width, size.height);
		[buffer lockFocus];
		if (ignoreAlpha) {
			[[self colorWithAlphaComponent:1.0f] set];
		} else {
			[self set];
		}
		[NSBezierPath fillRect:rect];
		rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
		[buffer unlockFocus];
		[buffer release];
		if (rep) {
			return [rep autorelease];
		}
	}
	return nil;
}

- (NSData *)dataWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha storageType:(NSBitmapImageFileType)storageType
{
	NSBitmapImageRep *rep;
	if ((rep = [self bitmapImageRepWithSize:size ignoreAlpha:ignoreAlpha])) {
		return [rep representationUsingType:storageType properties:nil];
	}
	return nil;
	
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size storageType:(NSBitmapImageFileType)storageType
{
	return [self writeToFile:path atomically:flag size:size storageType:storageType ignoreAlpha:NO];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size storageType:(NSBitmapImageFileType)storageType ignoreAlpha:(BOOL)ignoreAlpha
{
	NSParameterAssert(path != nil);
	NSData *data;
	NSBitmapImageRep *rep;
	BOOL result = NO;	
	if ((rep = [self bitmapImageRepWithSize:size ignoreAlpha:ignoreAlpha])) {
		if ((data = [rep representationUsingType:storageType properties:nil])) {
			result = [data writeToFile:path atomically:flag];
		}
	}
	return result;
}

@end

@implementation NSColor(AUColorAdditionExtra)

- (NSImage *)imageWithSize:(NSSize)size
{
	return [self imageWithSize:size ignoreAlpha:NO];
}

- (NSImage *)imageWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha
{
	return [self imageWithSize:size ignoreAlpha:ignoreAlpha drawBorder:NO];
}

- (NSImage *)imageWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha drawBorder:(BOOL)drawBorder
{
	NSImage *buffer;
	NSRect rect;
	NSSize min = NSMakeSize(1.0, 1.0);
	
	size.width = MAX(min.width, size.width);
	size.height = MAX(min.height, size.height);
	
	if ((buffer = [[NSImage alloc] initWithSize:size])) {
		rect = NSMakeRect(0.0, 0.0, size.width, size.height);
		[buffer lockFocus];
		if (ignoreAlpha) {
			[[self colorWithAlphaComponent:1.0f] set];
		} else {
			[self set];
		}
		
		[NSBezierPath fillRect:rect];
		if (drawBorder) {
			rect.origin.x += 0.5;
			rect.origin.y += 0.5;
			rect.size.width -= 1.0;
			rect.size.height -= 1.0;
			
			[[NSColor blackColor] set];
			[NSBezierPath strokeRect:rect];
			
			rect.origin.x += 1.0;
			rect.origin.y += 1.0;
			rect.size.width -= 2.0;
			rect.size.height -= 2.0;
			
			[[NSColor whiteColor] set];
			[NSBezierPath strokeRect:rect];
		}
		[buffer unlockFocus];
		return [buffer autorelease];
	}
	return nil;
}

- (NSData *)PNGDataWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha
{
	return [self dataWithSize:size ignoreAlpha:ignoreAlpha storageType:NSPNGFileType];
}

- (NSData *)PNGDataWithSize:(NSSize)size
{
	return [self PNGDataWithSize:size ignoreAlpha:NO];
}

- (NSData *)TIFFDataWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha
{
	return [self dataWithSize:size ignoreAlpha:ignoreAlpha storageType:NSTIFFFileType];
}

- (NSData *)TIFFDataWithSize:(NSSize)size
{
	return [self TIFFDataWithSize:size ignoreAlpha:NO];
}

- (BOOL)writeToPNGFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size
{
	return [self writeToPNGFile:path atomically:flag size:size ignoreAlpha:NO];
}

- (BOOL)writeToPNGFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha
{
	return [self writeToFile:path atomically:flag size:size storageType:NSPNGFileType ignoreAlpha:ignoreAlpha];
}

- (BOOL)writeToTIFFFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size
{
	return [self writeToTIFFFile:path atomically:flag size:size ignoreAlpha:NO];
}

- (BOOL)writeToTIFFFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha
{
	return [self writeToFile:path atomically:flag size:size storageType:NSTIFFFileType ignoreAlpha:ignoreAlpha];
}

- (BOOL)writeToJPEGFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size
{
	return [self writeToFile:path atomically:flag size:size storageType:NSJPEGFileType];
}

- (BOOL)writeToGIFFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size
{
	return [self writeToFile:path atomically:flag size:size storageType:NSGIFFileType];
}

- (BOOL)writeToBMPFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size
{
	return [self writeToFile:path atomically:flag size:size storageType:NSBMPFileType];
}

@end

/* EOF */