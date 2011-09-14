//
//  ColibriApplicationCommon.h
//  Colibri
//
//  Created by mmw on 5/5/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#ifndef COLIBRIAPPLICATIONCOMMON_H
#define COLIBRIAPPLICATIONCOMMON_H

#define IB_COLOR_MENU_TAG 1
#define IB_COLOR_MENU_ITEM_VALUE_AS_TAG 0

#define COLOR_VALUE_TYPE_ACTUAL 0
#define COLOR_VALUE_TYPE_PERCENTAGE 1
#define COLOR_VALUE_TYPE_HEXADECIMAL 2
#define COLOR_VALUE_TYPE_HSL 3

#define IB_VIEW_MENU_TAG 2
#define IB_VIEW_MENU_ITEM_POSITION_MENU_ITEM_LOCKXY_TAG 0
#define IB_VIEW_MENU_ITEM_POSITION_MENU_ITEM_LOCKX_TAG 1
#define IB_VIEW_MENU_ITEM_POSITION_MENU_ITEM_LOCKY_TAG 2
#define IB_VIEW_MENU_ITEM_ZOOM_IN_TAG 1
#define IB_VIEW_MENU_ITEM_ZOOM_OUT_TAG 2

#define IB_WINDOW_MENU_TAG 3
#define IB_WINDOW_MENU_ITEM_FLOAT_TOP_TAG 1
#define IB_WINDOW_MENU_ITEM_GLOBAL_TAG 2

#define ZOOM_MIN_FACTOR_DIVISOR 2
#define ZOOM_MAX_FACTOR_DIVISOR 16
#define ZOOM_FACTOR(d) (int32_t)(128 / ((d) / 2))

#define MAGNIFIER_DEFAULT_DIMENSION 128
#define MAGNIFIER_DEFAULT_MAX_DIMENSION 128
#define MAGNIFIER_DEFAULT_MIN_DIMENSION 16

static inline void CAC_drawBorderForRect(CGContextRef *context, CGRect rect)
{	
	CGFloat x = rect.origin.x;
	CGFloat y = rect.origin.y;
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height;
	
	CGContextBeginPath(*context);
	CGContextMoveToPoint(*context, x, y);
	CGContextAddLineToPoint(*context, x + w, y);
	CGContextMoveToPoint(*context, x + w, y);
	CGContextAddLineToPoint(*context, x + w, y + h);
	CGContextMoveToPoint(*context, x + w, y + h);
	CGContextAddLineToPoint(*context, x, y + h);
	CGContextMoveToPoint(*context, x, y + h);
	CGContextAddLineToPoint(*context, x, y);
	CGContextStrokePath(*context);
}

#endif /* COLIBRIAPPLICATIONCOMMON_H */

/* EOF */