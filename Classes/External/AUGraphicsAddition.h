//
//  AUGraphicsAddition.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUCommonGround.h"

/*!
	@function AUBitmapImageRepReadColorAverage
	@discussion 
	@param NSBitmapImageRep
	@result NSColor
 */
NSColor *AUBitmapImageRepReadColorAverage(NSBitmapImageRep *aBitmapImageRep);

/*!
	@function AUReadPixels
	@discussion 
	@param NSRect
	@result NSColor
 */
NSColor *AUReadPixels(NSRect aRect);

/*!
	@function AUImageResize
	@discussion 
	@param NSImage
	@param NSCompositingOperation
	@param CGFloat
	@param NSSize
	@param &NSBitmapImageRep
	@result NSImage
 */
NSImage *AUImageResize(NSImage *anImage, NSCompositingOperation op, CGFloat delta, NSSize size, NSBitmapImageRep **aBitmapImageRep);

/*!
	@function AUBitmapImageRepResize
	@discussion 
	@param NSBitmapImageRep
	@param NSSize
	@result NSBitmapImageRep
 */
NSBitmapImageRep *AUBitmapImageRepResize(NSBitmapImageRep *aBitmapImageRep, NSSize aSize);

/*!
 @function AUScreenCaptureCreate
 @discussion 
 @param NSRect
 @result CGImageRef
 */
CGImageRef AUScreenCaptureCreate(NSRect aRect);

/* EOF */