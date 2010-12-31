//
//  ColibriMainWindow.m
//  Colibri
//
//  Created by mmw on 5/7/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#import "ColibriMainWindow.h"

@implementation ColibriMainWindow

static CFMachPortRef CMW_portRef = NULL;
// main thread looper
static CGEventRef CMW_TapEventCallback(
	CGEventTapProxy proxy, 
	CGEventType type, 
	CGEventRef event, 
	void *refcon) 
{
	if (kCGEventMouseMoved & type || kCGEventKeyDown & type) { 
		// || kCGEventLeftMouseUp & type || kCGEventLeftMouseDown & type) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if (refcon) {
			id obj = (id)refcon;
			BOOL canPerformSelector = NO;			
			if ([obj isKindOfClass:[NSView class]]) {
				canPerformSelector = [[obj window] isMiniaturized] ? NO : YES;
			}
			if ([obj isKindOfClass:[NSWindow class]] && kCGEventMouseMoved & type) {
				canPerformSelector = [obj isMiniaturized] ? NO : YES;
			}
			if (canPerformSelector && kCGEventMouseMoved & type) {
				if ([obj respondsToSelector:@selector(mouseMoved:)]) {
					[obj performSelector:@selector(mouseMoved:) withObject:[NSEvent eventWithCGEvent:event]];
				}
			}
			if (canPerformSelector && kCGEventKeyDown & type) {
				if ([obj respondsToSelector:@selector(keyUp:)]) {
					[obj performSelector:@selector(keyUp:) withObject:[NSEvent eventWithCGEvent:event]];
				}
			}
		}
		[pool drain];
	}
	if (kCGEventTapDisabledByTimeout == type) {
		if (CMW_portRef) {
			if (!CGEventTapIsEnabled(CMW_portRef)) {
				CGEventTapEnable(CMW_portRef, true);
			}
		}
	}
	
	if (kCGEventTapDisabledByUserInput == type) {
		if (CMW_portRef) {
			if (!CGEventTapIsEnabled(CMW_portRef)) {
				CGEventTapEnable(CMW_portRef, true);
			}
		}
	}
	
	if (kCGEventNull == type) {
		NSLog(@"kCGEventNull");
	}
	
	return event;
}

- (void)dealloc
{
	if (CMW_portRef) {
		if (CGEventTapIsEnabled(CMW_portRef)) {
			CGEventTapEnable(CMW_portRef, false);
		}
		if (CFRunLoopContainsSource(CFRunLoopGetCurrent(), CMW_loopSourceRef, kCFRunLoopCommonModes)) {
			CFRunLoopRemoveSource(CFRunLoopGetCurrent(), CMW_loopSourceRef, kCFRunLoopCommonModes);
		}
		CFRelease(CMW_portRef);
		CFRelease(CMW_loopSourceRef);
		CMW_portRef = NULL;
		CMW_loopSourceRef = NULL;
	}
	
	[super dealloc];
}

#ifdef HUD_MODE

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	NSUInteger _windowStyle = NSHUDWindowMask|NSTitledWindowMask|NSUtilityWindowMask|NSClosableWindowMask;
	if ((self = [super initWithContentRect:contentRect styleMask:_windowStyle backing:bufferingType defer:deferCreation])) {
		return self;
	}
	return nil;
}

#endif

- (void)becomeKeyWindow {
	[super becomeKeyWindow];
	BOOL global;
	if ([self acceptsMouseMovedEvents:&global] && global) {
		if (CMW_portRef) {
			if (!CGEventTapIsEnabled(CMW_portRef)) {
				CGEventTapEnable(CMW_portRef, true);
			}
		}
	}
}

- (BOOL)acceptsMouseMovedEvents:(BOOL *)global
{
	*global = CMW_global;
	if (!CMW_global) {
		return [self acceptsMouseMovedEvents];
	}
	return CMW_global;
}

- (void)setAcceptsMouseMovedEvents:(BOOL)acceptMouseMovedEvents global:(BOOL)global receiver:(id)receiver;
{
	if (global) {
		CMW_global = NO;
		[self setAcceptsMouseMovedEvents:NO];
		if (!CMW_portRef) {
			if ((CMW_portRef = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, kCGEventTapOptionListenOnly, 
				 	CGEventMaskBit(kCGEventMouseMoved) | CGEventMaskBit(kCGEventKeyDown) , CMW_TapEventCallback, (!receiver ? self : receiver)))) {
				/*| CGEventMaskBit(kCGEventLeftMouseUp)  | CGEventMaskBit(kCGEventLeftMouseDown)*/
				if ((CMW_loopSourceRef = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, CMW_portRef, 0))) {
					CFRunLoopAddSource(CFRunLoopGetCurrent(), CMW_loopSourceRef, kCFRunLoopCommonModes);
					CGEventTapEnable(CMW_portRef, true);
					CMW_global = YES;
				} else {
					CFRelease(CMW_portRef);
					CMW_portRef = NULL;
					CMW_global = NO;
				}					
			}
		} else {
			CMW_global = YES;
		}
	} else {
		CMW_global = NO;
		if (CMW_portRef) {
			if (CGEventTapIsEnabled(CMW_portRef)) {
				CGEventTapEnable(CMW_portRef, false);
			}
			if (CFRunLoopContainsSource(CFRunLoopGetCurrent(), CMW_loopSourceRef, kCFRunLoopCommonModes)) {
				CFRunLoopRemoveSource(CFRunLoopGetCurrent(), CMW_loopSourceRef, kCFRunLoopCommonModes);
			}
			CFRelease(CMW_portRef);
			CFRelease(CMW_loopSourceRef);
			CMW_portRef = NULL;
			CMW_loopSourceRef = NULL;
		}
		[self setAcceptsMouseMovedEvents:acceptMouseMovedEvents];
	}
}

- (BOOL)isMovableByWindowBackground
{
	return NO;
}

@end

/* EOF */