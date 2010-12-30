//
//  ColibriMainWindow.h
//  Colibri
//
//  Created by mmw on 5/7/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef HUD_MODE
@interface ColibriMainWindow: NSPanel {
#else
@interface ColibriMainWindow: NSWindow {
#endif
	
@private
	CFRunLoopSourceRef CMW_loopSourceRef;
	BOOL CMW_global;	
}

- (void)setAcceptsMouseMovedEvents:(BOOL)acceptMouseMovedEvents global:(BOOL)global receiver:(id)receiver;
- (BOOL)acceptsMouseMovedEvents:(BOOL *)global;

@end

/* EOF */