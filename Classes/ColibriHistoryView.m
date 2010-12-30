//
//  ColibriHistoryView.m
//  Colibri
//
//  Created by mmw on 7/3/10.
//  Copyright 2010 Cucurbita. All rights reserved.
//

#import "ColibriApplicationCommon.h"
#import "ColibriHistoryView.h"
#import "AUColorAdditionExtra.h"
#import "AUColorAdditionRGB.h"

extern NSString *const kColibriUserDefaultsColorHistoryKey;

@implementation ColibriHistoryView

static inline NSUInteger CHV_indexAtLocation(NSPoint location, NSArray *bounds, NSUInteger count)
{
	NSUInteger i;
	for (i = 0; i < count; i++) {
		if (NSPointInRect(location, [[bounds objectAtIndex:i] rectValue]))
		{
			return i;
		}
	}
	return NSNotFound;
}

- (void)dealloc
{
	if (CHV_colors) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSKeyedArchiver archivedDataWithRootObject:CHV_colors]
			forKey:kColibriUserDefaultsColorHistoryKey
		 ];
		[CHV_colors release];
	}
	if (CHV_colorBounds) {
		[CHV_colorBounds release];
	}
	if (CHV_currentDraggedColor) {
		[CHV_currentDraggedColor release];
	}
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
		id archive = nil;
    	NSArray *colors = nil;
    	if (nil != (archive = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsColorHistoryKey])) {
			if (nil != (colors = [NSKeyedUnarchiver unarchiveObjectWithData:archive])) {
				CHV_colors = [colors retain];
			}
		}
		if (colors == nil) {
			CHV_colors = [[NSMutableArray alloc] initWithCapacity:36];
		}
		CHV_colorBounds = [[NSMutableArray alloc] initWithCapacity:36];
		int32_t i, index;
		CGFloat xoffset = 0.0, yoffset = 42.0;
		for (i = 0, index = 0; i < 36; i++, index++) {
			if (index == 9) {
				index = 0;
				yoffset = yoffset - 14;
			}
			xoffset = (index * 14);
			[CHV_colorBounds addObject:[NSValue valueWithRect:NSMakeRect(xoffset, yoffset, 9.0, 9.0)]];
		}
    }
    return self;
}

- (void)drawRect:(NSRect)aRect
{
	NSUInteger i;
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetInterpolationQuality(context, kCGInterpolationNone);
	CGContextSetShouldAntialias(context, NO);
	NSUInteger colorcount = [CHV_colors count];
	NSUInteger boundcount = [CHV_colorBounds count];
	for (i = 0; i < boundcount; i++) {
		CGRect bounds = NSRectToCGRect([[CHV_colorBounds objectAtIndex:i] rectValue]);
		if (i < colorcount) {
			NSColor *color = [CHV_colors objectAtIndex:i];
			CGContextSetRGBFillColor(context, [color redComponent], [color greenComponent], [color blueComponent], 1.0);
			CGContextFillRect(context, bounds);
			//CAC_drawBorderForRect(&context, CGRectMake(bounds.origin.x + 1.5, bounds.origin.y + 1.5, 7.0, 7.0));
			CGContextSetGrayStrokeColor(context, 0.2, 1.0);
			//CGContextSetGrayStrokeColor(context, 1.0, 1.0);
		} else {
			CGContextSetGrayFillColor(context, 0.85, 1.0);
			CGContextFillRect(context, bounds);
			CGContextSetGrayStrokeColor(context, 0.75, 1.0);	
		}
		CAC_drawBorderForRect(&context, bounds);
	}
}

- (void)addColor:(NSColor *)aColor
{
	if (aColor) {
		if ([CHV_colors count] > 0) {
			if (NSNotFound != [CHV_colors indexOfObject:aColor]) {
				return;
			}
		}
		[CHV_colors insertObject:aColor atIndex:0];
		if ([CHV_colors count] > 36) {
			[CHV_colors removeLastObject];
		}
		[self setNeedsDisplay:YES];
		[self displayIfNeeded];
	}
}

- (void)saveColors
{
	if (CHV_colors) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSKeyedArchiver archivedDataWithRootObject:CHV_colors]
				forKey:kColibriUserDefaultsColorHistoryKey
			];
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint locationInView;
	NSUInteger count;
	if([theEvent clickCount] >= 2) {
		if((count = [CHV_colors count])) {
			locationInView = [self convertPoint:[theEvent locationInWindow] fromView:[self superview]];
			NSUInteger index = CHV_indexAtLocation(locationInView, CHV_colorBounds, count);
			if (index != NSNotFound) {
				[CHV_colors removeObjectAtIndex:index];
				[self setNeedsDisplay:YES];
				[self displayIfNeeded];
				[[[NSApplication sharedApplication] delegate] performSelector:@selector(redrawMagnifier)];
			}
		}
	}
	[super mouseUp:theEvent];
	return;
}

- (void)mouseDragged:(NSEvent*)theEvent
{
	NSPoint locationInView;
	NSUInteger count;
	if((count = [CHV_colors count])) {
		locationInView = [self convertPoint:[theEvent locationInWindow] fromView:[self superview]];
		NSUInteger index = CHV_indexAtLocation(locationInView, CHV_colorBounds, count);
		if (index != NSNotFound) {
			if (CHV_currentDraggedColor) {
				[CHV_currentDraggedColor release];
			}
			CHV_currentDraggedColor = [[CHV_colors objectAtIndex:index] retain];
			NSSize size = NSMakeSize(15, 15);
			NSImage *dragImage = [CHV_currentDraggedColor imageWithSize:size ignoreAlpha:NO drawBorder:YES];
			if (dragImage) {
				NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
				[pasteboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, NSTIFFPboardType, NSColorPboardType, nil] owner:self];
				[pasteboard addTypes:[NSArray arrayWithObject:NSFilesPromisePboardType] owner:self];
				locationInView.x -= 7.5;
				locationInView.y -= 7.5;
				[self dragImage:dragImage at:locationInView offset:size event:theEvent pasteboard:pasteboard source:self slideBack:YES];
			}
		}
	}
	[super mouseDragged:theEvent];
	return;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
	[sender setData:[CHV_currentDraggedColor TIFFDataWithSize:NSMakeSize(100, 100)] forType:NSTIFFPboardType];
	if([type isEqualToString:NSTIFFPboardType]) {
		return;
	} else if([type isEqualToString:NSColorPboardType]) {
		[sender setData:[NSKeyedArchiver archivedDataWithRootObject:CHV_currentDraggedColor] forType:type];
	} else if([type isEqualToString:NSStringPboardType]) {
		[sender setString:[CHV_currentDraggedColor hexaValue] forType:type];
	} else if([type isEqualToString:NSFilesPromisePboardType]) {
		[sender setPropertyList:[NSArray arrayWithObject:@"ColibriFilePromisePboardType"] forType:type];
	}
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationCopy;
}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
	NSString *promisedName = [[[NSApplication sharedApplication] delegate] 
		performSelector:@selector(saveHistoryColor:rootDestination:)
		withObject:CHV_currentDraggedColor
		withObject:[dropDestination path]
	];
	return [NSArray arrayWithObject:promisedName];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)theEvent
{ 
	return YES; 
}

- (BOOL)ignoreModifierKeysWhileDragging 
{
	return YES; 
}

@end
