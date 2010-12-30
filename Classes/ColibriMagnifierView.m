//
//  ColibriMagnifierView.m
//  Colibri
//
//  Created by mmw on 5/5/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#import "ColibriApplicationCommon.h"
#import "ColibriMagnifierView.h"
#import "AUColorAdditionRGB.h"
#import "AUGraphicsAddition.h"

extern NSString *const kColibriUserDefaultsColorValueTypeKey;
extern NSString *const kColibriUserDefaultsMagnifierDimensionKey;
extern NSString *const kColibriMenuActionZoomMagnifierNotificationName;

@implementation ColibriMagnifierView

static bool CMW_awaked = NO;

@synthesize colorView;

- (void)dealloc
{	
	if (CMW_color) {
		[CMW_color release];
	}
	if (CMW_fontattr) {
		[CMW_fontattr release];
	}
	if (CMW_cgImage) {
		CGImageRelease(CMW_cgImage);
		CMW_cgImage = NULL;
	}
	
	[super dealloc];
}

- (void)createImage:(NSPoint)point
{
	CGFloat x, y, w, h;
	NSRect screenRect, imageRect;
	
	screenRect = [[NSScreen mainScreen] frame];
	point.y = screenRect.size.height - point.y;	
	CMW_Flags._posX = 'L';
	CMW_Flags._posY = 'B';	

	x = (point.x - (CMW_dimension / 2.0));
	
	if (x > 0.0) {
		if ((point.x + (CMW_dimension / 2.0)) > screenRect.size.width) {
			w = ((CMW_dimension / 2.0) + screenRect.size.width - point.x);
		} else {
			w = CMW_dimension;
		}
	} else {
		x = 0.0;
		w = CMW_dimension + (point.x - (CMW_dimension / 2.0));
		w = w > CMW_dimension ? CMW_dimension : w;
		CMW_Flags._posX = 'R';
	}
	
	y = (point.y - (CMW_dimension / 2.0));
	
	if (y > 1.0) {
		if ((point.y + (CMW_dimension / 2.0)) > screenRect.size.height - 1.0) {
			h = ((CMW_dimension / 2.0) + screenRect.size.height -1 - point.y);
			CMW_Flags._posY = 'T';
		} else {
			h = CMW_dimension;
		}
	} else {
		y = 1.0;
		h = CMW_dimension + 1.0 + (point.y - (CMW_dimension / 2.0));
		h = h > CMW_dimension ? CMW_dimension : h;
	}
	
	if (CMW_cgImage) {
		CGImageRelease(CMW_cgImage);
		CMW_cgImage = NULL;
	}

	imageRect = NSMakeRect(x, y, w, h);
	CMW_cgImage = AUScreenCaptureCreate(imageRect);
}

- (BOOL)acceptsFirstResponder
{	
	return YES;
}

- (void)awakeFromController
{	
	if (CMW_awaked)
	{
		assert(0);
	}
	BOOL updateDefaults = NO;
	NSNumber *magnifierDimension = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsMagnifierDimensionKey
	];
	
	CMW_dimension = [magnifierDimension integerValue];
	
	if (CMW_dimension > MAGNIFIER_DEFAULT_MAX_DIMENSION) {
		CMW_dimension = MAGNIFIER_DEFAULT_MAX_DIMENSION;
		updateDefaults = YES;
	}
	
	if (CMW_dimension < MAGNIFIER_DEFAULT_MIN_DIMENSION) {
		CMW_dimension = MAGNIFIER_DEFAULT_MIN_DIMENSION;
		updateDefaults = YES;
	}
	
	if (updateDefaults) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:CMW_dimension] 
			forKey:kColibriUserDefaultsMagnifierDimensionKey
		];
	}
	
	CMW_cgImage = NULL;
	CMW_color = nil;
	CMW_location = [NSEvent mouseLocation];
	
	CMW_Flags._Xlocked = NO;
	CMW_Flags._Ylocked = NO;
	CMW_Flags._XYlocked = NO;
	
	if (!CMW_fontattr)
	{
		CMW_fontattr = [[NSMutableDictionary alloc] init];
		[CMW_fontattr setValue:[NSFont fontWithName:@"Monaco" size:9.0] forKey:NSFontAttributeName]; //monospace
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0, -1)];
		[shadow setShadowBlurRadius:0.1];
		[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.6]];
		[CMW_fontattr setValue:shadow forKey:NSShadowAttributeName];
		[CMW_fontattr setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	}
	[self createImage:CMW_location];
	CMW_awaked = YES;
}

- (void)keyUp:(NSEvent*)theEvent
{
	
	if ([theEvent modifierFlags] & NSCommandKeyMask && [theEvent modifierFlags] & NSAlternateKeyMask && [theEvent keyCode] == 8)
	{
		id obj = [[NSApplication sharedApplication] delegate];
		if ([obj respondsToSelector:@selector(copyMagnifierColor:)]) {
			[obj performSelector:@selector(copyMagnifierColor:) withObject:nil];
		}
	}
}

- (void)mouseMoved:(NSEvent*)theEvent
{
	NSPoint mouseLocation;
	if (!CMW_dimension) {
		return;
	}
	
	if ([[self window] isMiniaturized]) {
		return;
	}
	
	if (CMW_Flags._XYlocked) {
		return;
	}
	
	mouseLocation = [NSEvent mouseLocation];
	
	if (CMW_Flags._Xlocked) {
		CMW_location.y = mouseLocation.y;
	} else {
		CMW_location.x = mouseLocation.x;
	}
	
	if (CMW_Flags._Ylocked) {
		CMW_location.x = mouseLocation.x;
	} else {
		CMW_location.y = mouseLocation.y;
	}
	[self createImage:CMW_location];
	if (CMW_cgImage) {
		[self setNeedsDisplayInRect:[self bounds]];
	}
}

- (void)drawRect:(NSRect)aRect 
{
	NSRect rect = [self bounds];
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetInterpolationQuality(context, kCGInterpolationNone);
	CGContextSetShouldAntialias(context, NO);
	CGFloat apertureGrayScaleColor = 0.2f;
	NSColor *pixelsAverage = nil;
	CGRect apertureRect;
	
	[self lockFocus];
	// drawing magnifier image
	if (CMW_cgImage)
	{
		size_t w = CGImageGetWidth(CMW_cgImage) * (MAGNIFIER_DEFAULT_DIMENSION / CMW_dimension);
		size_t h = CGImageGetHeight(CMW_cgImage) * (MAGNIFIER_DEFAULT_DIMENSION / CMW_dimension);
		if (w < MAGNIFIER_DEFAULT_DIMENSION || h < MAGNIFIER_DEFAULT_DIMENSION) {
			CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
			CGContextFillRect(context, NSRectToCGRect(rect));
			
			if (CMW_Flags._posX == 'R') {
				rect.origin.x += MAGNIFIER_DEFAULT_DIMENSION - w;
			}
			if (CMW_Flags._posY == 'T') {
				rect.origin.y += MAGNIFIER_DEFAULT_DIMENSION - h;
			}
		}
		rect.size.width = w;
		rect.size.height = h;
		CGContextDrawImage(context, NSRectToCGRect(rect), CMW_cgImage);
		// drawing magnifier info
		NSNumber *magnifierDimension = [[NSUserDefaults standardUserDefaults] 
					objectForKey:kColibriUserDefaultsMagnifierDimensionKey
				];		
		NSInteger factor, dim = [magnifierDimension integerValue];
		switch(dim) {
			case 64: factor = 2; break;
			case 32: factor = 4; break;
			case 16: factor = 8; break;
			default: factor = 1;
		};
		NSString *zoomFactorStringValue = [NSString stringWithFormat:@"%dx", factor];
		CGContextSetGrayFillColor(context, 0.1, 0.55);
		CGContextFillRect(context, CGRectMake(2.0, 2.0, 22.0, 22.0));
		[zoomFactorStringValue drawAtPoint:NSMakePoint(7.0 , 6.5) withAttributes:CMW_fontattr];
	}
	// getting color
	NSColor *pixel = NSReadPixel(NSMakePoint(64.0, 64.0));
	if ([self canZoomIn]) {
		pixelsAverage = AUReadPixels(NSMakeRect(57.0, 57.0, 15.0, 15.0));
	}
	// reseting previous color
	if (CMW_color) {
		[CMW_color release];
		CMW_color = nil;
	}
	CMW_color = [pixel retain];
	//[self unlockFocus];
	//[self lockFocus];
	// drawing magnifier view borders
	CGContextSetGrayStrokeColor(context, 0.5, 1.0);	
	CAC_drawBorderForRect(&context, CGRectMake(0.0, 0.0, 127.0, 127.0));
	CGContextSetGrayStrokeColor(context, 1.0, 1.0);
	CAC_drawBorderForRect(&context, CGRectMake(1.0, 1.0, 125.0, 125.0));
	// drawing magnifier view aperture
	if (![self canZoomIn]) {
		apertureRect = CGRectMake(64.0, 64.0, 7.0, 7.0);
	} else {
		apertureRect = CGRectMake(61.0, 61.0, 7.0, 7.0);
	}
	// calculating aperture color
	if (![self canZoomIn]) {
		apertureGrayScaleColor = [CMW_color grayScaleComponent] > 0.6f ? 0.0f : 1.0f;
	} else {
		if (pixelsAverage) {
			apertureGrayScaleColor = [pixelsAverage grayScaleComponent] > 0.6f ? 0.2f : 1.0f;
		}
	}
	CGContextSetGrayStrokeColor(context, apertureGrayScaleColor, 1.0);
	CAC_drawBorderForRect(&context, apertureRect);
	//
	// drawing color view
	if ([colorView lockFocusIfCanDraw])
	{
		// drawing color
		CGContextSetRGBFillColor(context, [CMW_color redComponent], [CMW_color greenComponent], [CMW_color blueComponent], 1.0);
		CGContextFillRect(context, CGRectMake(0, 0.0, 122.0, 50.0));
		// drawing color info
		NSString * colorStringValue;
		NSNumber *colorValueType = [[NSUserDefaults standardUserDefaults] 
				objectForKey:kColibriUserDefaultsColorValueTypeKey
		];
		switch ([colorValueType integerValue]) {
			case COLOR_VALUE_TYPE_ACTUAL:
				colorStringValue = [CMW_color actualValue];
				break;
			case COLOR_VALUE_TYPE_PERCENTAGE:
				colorStringValue = [CMW_color percentageValue];
				break;
			case COLOR_VALUE_TYPE_HEXADECIMAL:
				colorStringValue = [CMW_color hexaValue];
				break;
			default:
				colorStringValue = [CMW_color hexaValue];
				break;
		}
		CGContextSetGrayFillColor(context, 0.1, 0.7);
		CGContextFillRect(context, CGRectMake(1.0, 0.0, 122.0, 20.0));
		[colorStringValue drawAtPoint: NSMakePoint(10.5 , 4.0) withAttributes:CMW_fontattr];
		// drawing color view borders 
		CGContextSetGrayStrokeColor(context, 0.5, 1.0);	
		CAC_drawBorderForRect(&context, CGRectMake(0.5, 0.5, 121.0, 49.0));
		CGContextSetGrayStrokeColor(context, 1.0, 1.0);
		CAC_drawBorderForRect(&context, CGRectMake(1.5, 1.5, 119.0, 47.0));
		
		
	/*	NSColor *complementary = [CMW_color complementaryColor];
		 
		 CGContextSetRGBFillColor(context, 
			[complementary redComponent], 
			[complementary greenComponent], 
			[complementary blueComponent], 
			1.0
		 );
		 
		CGContextFillRect(context, CGRectMake(0, 3.0, 32.0, 12.0));

		CGContextSetGrayStrokeColor(context, 0.5, 1.0);
		CAC_drawBorderForRect(&context, CGRectMake(0.5, 3.5, 31.0, 11.0));

		CGContextSetGrayStrokeColor(context, 1.0, 1.0);
		CAC_drawBorderForRect(&context, CGRectMake(1.5, 4.5, 29.0, 9.0));
		
		CGContextSetRGBFillColor(context, [CMW_color redComponent], 0, 0, 1.0);
		CGContextFillRect(context, CGRectMake(42.0, 4.0, 5.0, 10.0));
		
		CGContextSetGrayStrokeColor(context, 0.0, 1.0);
		//CAC_drawBorderForRect(&context, CGRectMake(42.5, 4.5, 5.0, 10.0));
		
		CGContextSetRGBFillColor(context, 0, [CMW_color greenComponent], 0, 1.0);
		CGContextFillRect(context, CGRectMake(52.0, 4.0, 5.0, 10.0));
		
		CGContextSetGrayStrokeColor(context, 0.0, 1.0);
		//CAC_drawBorderForRect(&context, CGRectMake(52.5, 4.5, 5.0, 10.0));
		
		CGContextSetRGBFillColor(context, 0, 0, [CMW_color blueComponent], 1.0);
		CGContextFillRect(context, CGRectMake(62.0, 4.0, 5.0, 10.0));
		
		CGContextSetGrayStrokeColor(context, 0.0, 1.0);
		//CAC_drawBorderForRect(&context, CGRectMake(62.5, 4.5, 5.0, 10.0));
*/		
		[colorView unlockFocus];
	}
	[self unlockFocus];
}

- (void)displayWithNewDimension
{
	NSNumber *magnifierDimension = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsMagnifierDimensionKey
	];
	
	CMW_dimension = [magnifierDimension integerValue];
	
	if (!CMW_Flags._XYlocked) {
		NSPoint mouseLocation = [NSEvent mouseLocation];
		
		if (CMW_Flags._Xlocked) {
			CMW_location.y = mouseLocation.y;
		} else {
			CMW_location.x = mouseLocation.x;
		}
		
		if (CMW_Flags._Ylocked) {
			CMW_location.x = mouseLocation.x;
		} else {
			CMW_location.y = mouseLocation.y;
		}
	}
	
	[self createImage:CMW_location];
	if (CMW_cgImage) {
		[self setNeedsDisplayInRect:[self bounds]];
	}
}

- (void)displayWithNewDisplay
{
	[self createImage:CMW_location];
	if (CMW_cgImage) {
		[self setNeedsDisplayInRect:[self bounds]];
	}
}

- (void)redraw
{
	[self setNeedsDisplayInRect:[self bounds]];
}

- (BOOL)canZoomIn
{
	return (ZOOM_FACTOR(CMW_dimension) < ZOOM_MAX_FACTOR_DIVISOR) ? YES : NO;
}

- (BOOL)canZoomOut
{
	return (ZOOM_FACTOR(CMW_dimension) > ZOOM_MIN_FACTOR_DIVISOR) ? YES : NO;
}

- (BOOL)zoomIn
{
	if (ZOOM_FACTOR(CMW_dimension) <= ZOOM_MAX_FACTOR_DIVISOR) {
		CMW_dimension = CMW_dimension / 2;
		[self createImage:CMW_location];
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:CMW_dimension] 
			forKey:kColibriUserDefaultsMagnifierDimensionKey
		];
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:kColibriMenuActionZoomMagnifierNotificationName 
			object:[[NSApplication sharedApplication] delegate] userInfo:nil
		];
		[self setNeedsDisplayInRect:[self bounds]];
	}
	
	return [self canZoomIn];
}

- (BOOL)zoomOut
{
	if (ZOOM_FACTOR(CMW_dimension) >= ZOOM_MIN_FACTOR_DIVISOR) {
		CMW_dimension = CMW_dimension * 2;
		[self createImage:CMW_location];
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:CMW_dimension] 
			forKey:kColibriUserDefaultsMagnifierDimensionKey
		];
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:kColibriMenuActionZoomMagnifierNotificationName 
			object:[[NSApplication sharedApplication] delegate] userInfo:nil
		];
		[self setNeedsDisplayInRect:[self bounds]];
	}
	
	return [self canZoomOut];
}

- (void)setLockPositionX:(BOOL)locked
{
	CMW_Flags._Xlocked = locked;	
}

- (void)setLockPositionY:(BOOL)locked
{
	CMW_Flags._Ylocked = locked;
}

- (void)setLockPositionXY:(BOOL)locked
{
	CMW_Flags._XYlocked = locked;
}

- (NSColor *)currentColor
{
	return CMW_color;
}

- (NSString *)colorValue
{
	NSString *value = nil;
	NSNumber *colorValueType = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsColorValueTypeKey
	];
	switch ([colorValueType integerValue]) {
		case COLOR_VALUE_TYPE_ACTUAL:
			value = [CMW_color actualValue];	
		break;
		case COLOR_VALUE_TYPE_PERCENTAGE:
			value = [CMW_color percentageValue];	
		break;
		case COLOR_VALUE_TYPE_HEXADECIMAL:
			value = [CMW_color hexaValue];
		break;
		default:
			value = [CMW_color hexaValue];
		break;
	}
	
	return value;
}

- (NSBitmapImageRep *)captureView
{
	NSBitmapImageRep *imageRep;
	NSRect rect = [self bounds];
	
	[self lockFocus];
	imageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
	[self unlockFocus];
	
	return [imageRep autorelease];
}

@end

/* EOF */