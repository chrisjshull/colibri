//
//  AUPreferencesSingleItem.m
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUPreferencesSingleItem.h"
#import "AUSingletonizeClass.h"

NSString *const AUPreferencesSingleItemWindowDidCloseNotification = @"Application Utility AUPreferencesSingleItem WindowDidClose Notification";

@implementation AUPreferencesSingleItem

#ifdef AUPREFERENCES_SINGLEITEM_SINGLETONIZED

#pragma mark singleton

AU_SINGLETONIZE_CLASS_USING_INSTANCE (
	AUPreferencesSingleItem, 
	defaultController
)

#endif

- (void)dealloc
{
	if (nil != _item) {
		[_item release];
	}
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		NSWindow *aWindow = [
			[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 480, 270) 
			styleMask:(NSTitledWindowMask|NSClosableWindowMask) 
			backing:NSBackingStoreBuffered defer:YES
		];
		
		[aWindow setShowsToolbarButton:NO];
		self.window = aWindow;
		[[self window] setDelegate:self];
		[aWindow release];

		_item = nil;
	}
	
	return self;
}

#pragma mark custom

- (void)setItemView:(id<AUPreferencesSingleItemController>)sender firstPaint:(BOOL)firstPaint;
{
	NSRect windowFrame;
	NSRect viewFrame;
	NSView *windowContentView = [[self window] contentView];
	NSView *senderContentView = [sender contentView];
	
	if (NSViewNotSizable != [senderContentView autoresizingMask]) {
		[senderContentView setAutoresizingMask:NSViewNotSizable];
	}
	
	if (!firstPaint && [[self window] isVisible]) {
		if ([[sender class] instancesRespondToSelector:@selector(contentViewWillAppear)]) {
			[sender performSelector:@selector(contentViewWillAppear)];
		}
	}
	
	if (!firstPaint) {
		if ([[windowContentView subviews] count])
			[[[windowContentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	viewFrame = [senderContentView frame];
	viewFrame.origin.y = 0;
	[senderContentView setFrame:viewFrame];
	
	windowFrame = [[self window] frameRectForContentRect:viewFrame];
	windowFrame.origin = [[self window] frame].origin;
	windowFrame.origin.y -= windowFrame.size.height - [[self window] frame].size.height;

	if (!NSEqualRects(windowFrame,[[self window] frame]))
		[[self window] setFrame:windowFrame display:YES animate:YES];
	else
		[[self window] displayIfNeeded];
	
	[windowContentView addSubview:senderContentView];
	[[self window] setTitle:[sender label]];
	
	if (!firstPaint && [[self window] isVisible]) {
		if ([[sender class] instancesRespondToSelector:@selector(contentViewDidAppear)]) {
			[sender performSelector:@selector(contentViewDidAppear)];
		}
	}
}

- (void)setItem:(id<AUPreferencesSingleItemController>)item
{
	BOOL firstPaint = YES;
	if (nil != _item) {
		if ([[self window] isVisible]) {
			if ([[_item class] instancesRespondToSelector:@selector(contentViewWillDisappear)]) {
				[_item performSelector:@selector(contentViewWillDisappear)];
			}
			
			if ([[_item class] instancesRespondToSelector:@selector(contentViewDidDisappear)]) {
				[_item performSelector:@selector(contentViewDidDisappear)];
			}
		}
		
		[_item release];
		_item = nil;
		firstPaint = NO;
	}
	
	if (item) {
		_item = [item retain];
		[self setItemView:_item firstPaint:firstPaint];
	}
}

- (id)item
{
	return _item;
}

#pragma mark window delegate

- (void)windowWillClose:(NSNotification *)aNotification
{
	if (nil == _item) {
		return;
	}
	
	if ([[_item class] instancesRespondToSelector:@selector(contentViewWillDisappear)]) {
		[_item performSelector:@selector(contentViewWillDisappear)];
	}
	
	if ([[_item class] instancesRespondToSelector:@selector(contentViewDidDisappear)]) {
		[_item performSelector:@selector(contentViewDidDisappear)];
	}
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:AUPreferencesSingleItemWindowDidCloseNotification
		object:self userInfo:nil
	];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	if (nil == _item) {
		return;
	}

	if ([[_item class] instancesRespondToSelector:@selector(contentViewWillAppear)]) {
		[_item performSelector:@selector(contentViewWillAppear)];
	}
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	if (nil == _item) {
		return;
	}
	
	if ([[_item class] instancesRespondToSelector:@selector(contentViewDidAppear)]) {
		[_item performSelector:@selector(contentViewDidAppear)];
	}
}

#pragma mark inherit

- (void)showWindow:(id)sender
{
	if (![[self window] isVisible]) {
		[[self window] center];
	}
	
	[super showWindow:sender];
}

#pragma mark bind command-w to the window

- (void)keyDown:(NSEvent *)theEvent
{
	if ([[self window] isVisible]) {
		if (NSCommandKeyMask & [theEvent modifierFlags]) {
			if ([theEvent keyCode] == 13) {
				[[NSNotificationCenter defaultCenter] 
					postNotificationName:NSWindowWillCloseNotification 
					object:[self window] userInfo:nil
				];
				[[self window] orderOut:nil];
				return;
			}
		}
		
		NSBeep();
	}
}

@end

/* EOF */