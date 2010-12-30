//
//  ColibriHistoryView.h
//  Colibri
//
//  Created by mmw on 7/3/10.
//  Copyright 2010 Cucurbita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColibriHistoryView : NSView {

@private
	NSMutableArray *CHV_colors;
	NSMutableArray *CHV_colorBounds;
	NSColor *CHV_currentDraggedColor;
	
}

- (void)addColor:(NSColor *)color;
- (void)saveColors;

@end
