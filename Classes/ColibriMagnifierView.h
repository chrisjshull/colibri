//
//  ColibriMagnifierView.h
//  Colibri
//
//  Created by mmw on 5/5/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColibriMagnifierView : NSView {

@private
	CGImageRef CMW_cgImage;
	NSPoint CMW_location;
	size_t CMW_dimension;
	NSColor *CMW_color;
	NSDictionary *CMW_fontattr;
	struct CMW__Flags {
		BOOL _Xlocked;
		BOOL _Ylocked;
		BOOL _XYlocked;
		unsigned char _posX;
		unsigned char _posY;
	} CMW_Flags;

@public
	NSView *colorView;
}

@property (assign) IBOutlet NSView *colorView;

- (void)awakeFromController;
- (void)displayWithNewDimension;
- (void)displayWithNewDisplay;
- (void)redraw;
- (BOOL)canZoomIn;
- (BOOL)canZoomOut;
- (BOOL)zoomIn;
- (BOOL)zoomOut;

- (void)setLockPositionX:(BOOL)locked;
- (void)setLockPositionY:(BOOL)locked;
- (void)setLockPositionXY:(BOOL)locked;

- (NSColor *)currentColor;
- (NSString *)colorValue;
- (NSBitmapImageRep *)captureView;

@end

/* EOF */
