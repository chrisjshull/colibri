//
//  AUGraphicsAddition.m
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUGraphicsAddition.h"

/*
*  NSColor *AUBitmapImageRepReadColorAverage(NSBitmapImageRep *aBitmapImageRep);
*/
NSColor *AUBitmapImageRepReadColorAverage(NSBitmapImageRep *aBitmapImageRep)
{	
	if (aBitmapImageRep) {
		NSInteger i = 0;
		NSInteger components[3] = {0,0,0};
		unsigned char *data = [aBitmapImageRep bitmapData];
		NSInteger pixels = ([aBitmapImageRep size].width *[aBitmapImageRep size].height);
		
		do {
			components[0] += *data++;
			components[1] += *data++;
			components[2] += *data++;
		} while (++i < pixels);
		
		CGFloat red = (CGFloat)components[0] / pixels / 256;
		CGFloat green = (CGFloat)components[1] / pixels / 256;
		CGFloat blue = (CGFloat)components[2] / pixels / 256;
	
		return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0];
	}
	
	return nil;
}

/*
*  NSColor *AUReadPixels(NSRect aRect);
*/
NSColor *AUReadPixels(NSRect aRect)
{
	if (aRect.size.width >=  2.0 && aRect.size.height >= 2.0) {
		NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:aRect];
		NSColor *average = AUBitmapImageRepReadColorAverage(imageRep);
		[imageRep release];
		
		return average;
	}
	
	return NSReadPixel(NSMakePoint(aRect.origin.x, aRect.origin.y));
}

/*
*  NSImage *AUImageResize(NSImage *anImage, NSCompositingOperation op, CGFloat delta, NSSize aSize, NSBitmapImageRep **aBitmapImageRep);
*/
NSImage *AUImageResize(NSImage *anImage, NSCompositingOperation op, CGFloat delta, NSSize aSize, NSBitmapImageRep **aBitmapImageRep)
{
	NSImage *newImage;
	NSRect imgRect, rect;
	NSSize min = NSMakeSize(1.0, 1.0);
	aSize.width = MAX(min.width, aSize.width);
	aSize.height = MAX(min.height, aSize.height);
	if (nil != anImage) {
		if ((newImage = [[NSImage alloc] initWithSize:aSize])) {
			rect = NSMakeRect(0.0, 0.0, aSize.width, aSize.height);
			imgRect = NSMakeRect(0, 0, anImage.size.width, anImage.size.height);
			[newImage lockFocus];
			[anImage drawInRect:rect fromRect:imgRect operation:op fraction:delta];
			if (aBitmapImageRep != nil) {
				*aBitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
			}
			[newImage unlockFocus];
		}
		if (nil != newImage) {
			return [newImage autorelease];
		}
	}
	return nil;
}

/*
*  NSBitmapImageRep *AUBitmapImageRepResize(NSBitmapImageRep *aBitmapImageRep, NSSize aSize);
*/
NSBitmapImageRep *AUBitmapImageRepResize(NSBitmapImageRep *aBitmapImageRep, NSSize aSize)
{
	NSBitmapImageRep *outRep;
	NSRect rect = NSMakeRect(0.0, 0.0, aSize.width, aSize.height);
	if (nil != aBitmapImageRep) {
		NSImage *buffer = [[NSImage alloc] initWithSize:aSize];
		[buffer lockFocus];
		[aBitmapImageRep drawInRect:rect];
		outRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
		[buffer unlockFocus];
		[buffer release];
		if (nil != outRep) {
			return [outRep autorelease];
		}
	}
	return nil;
}

/*
*  CGImageRef AUScreenCaptureCreate(NSRect aRect);
*/
CGImageRef AUScreenCaptureCreate(NSRect aRect)
{
	return CGWindowListCreateImage(
		NSRectToCGRect(aRect), 
		kCGWindowListOptionOnScreenOnly, 
		kCGNullWindowID, 
		kCGWindowImageBoundsIgnoreFraming|kCGWindowImageShouldBeOpaque
	);
}

/* EOF */