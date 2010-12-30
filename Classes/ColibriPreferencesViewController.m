//
//  ColibriPreferencesViewController.m
//  Colibri
//
//  Created by mmw on 11/16/08.
//  Copyright 2008 Curcubita. All rights reserved.
//

#import "ColibriApplicationCommon.h"
#import "ColibriPreferencesViewController.h"
#import "AUPathUtilitiesAddition.h"

extern NSString *const kColibriUserDefaultsMagnifierDimensionKey;
extern NSString *const kColibriMenuActionZoomMagnifierNotificationName;
extern NSString *const kColibriUserDefaultsImageFormatKey;
extern NSString *const kColibriUserDefaultsSaveToKey;

@implementation ColibriPreferencesViewController

@synthesize zoom;
@synthesize saveto;
@synthesize format;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
		name:kColibriMenuActionZoomMagnifierNotificationName 
		object:[[NSApplication sharedApplication] delegate]
	];
	[CPVC_label release];
	[super dealloc];
}

- (id)initWithLabel:(NSString *)label
{
	if ((self = [super initWithNibName:@"PreferencesView" bundle:[NSBundle mainBundle]])) {
		CPVC_label = [label retain];
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(onEventMenuActionZoomMagnifier:) 
			name:kColibriMenuActionZoomMagnifierNotificationName 
			object:[[NSApplication sharedApplication] delegate]
		];
	}
	
	return self;
}

- (void)loadView
{
	NSString *dest, *displayName;
	NSNumber *imageFileFormat;
	NSImage *icon;
	[super loadView];	
	if ((imageFileFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsImageFormatKey])) {
		[[self format] selectCellAtRow:[imageFileFormat integerValue] ? 1 : 0 column:0];
	}
	[[self saveto] removeAllItems];
	[[self saveto] addItemWithTitle:NSLocalizedString(@"Desktop", @"Desktop")];
	if ((dest = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsSaveToKey])) {
		if (nil == (icon = [[NSWorkspace sharedWorkspace] iconForFile:dest])) {
			icon = [[NSWorkspace sharedWorkspace] iconForFile:[[NSBundle mainBundle] resourcePath]];
		}
		[icon setSize:NSMakeSize(16.0, 16.0)];
		[[[self saveto] itemAtIndex:0] setImage:icon];
		
		if ((displayName = AUFinderDisplayNameForPath(dest))) {
			[[[self saveto] itemAtIndex:0] setTitle:displayName];
		}
	}
	
	[[[self saveto] menu] addItem:[NSMenuItem separatorItem]];
	[[self saveto] addItemWithTitle: NSLocalizedString(@"Other...", @"Other...")];
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:kColibriMenuActionZoomMagnifierNotificationName 
		object:[[NSApplication sharedApplication] delegate] userInfo:nil
	];
}

- (void)onEventMenuActionZoomMagnifier:(NSNotification *)aNotification
{
	NSNumber *magnifierDimension = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsMagnifierDimensionKey
	];
	
	NSInteger val, dim = [magnifierDimension integerValue];
	switch(dim) {
		case 64: val = 1; break;
		case 32: val = 2; break;
		case 16: val = 3; break;
		default: val = 0;
	};
	[self.zoom setIntegerValue:val];
}

- (IBAction)updateZoom:(id)sender
{
	NSInteger dim;
	switch([sender integerValue]) {
		case 1: dim = 64; break;
		case 2: dim = 32; break;
		case 3: dim = 16; break;
		default: dim = 128;
	};
	
	[[NSUserDefaults standardUserDefaults] setObject:
		[NSNumber numberWithInteger:dim] 
		forKey:kColibriUserDefaultsMagnifierDimensionKey
	];
	[[[NSApplication sharedApplication] delegate] performSelector:@selector(setNewDimension)];
}

- (IBAction)openDocument:(id)sender
{
	if ([sender indexOfSelectedItem]) {
		NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
		[panel setCanChooseDirectories:YES];
		[panel setResolvesAliases:NO];
		[panel setAllowsMultipleSelection:NO];
		[panel setCanChooseFiles:NO];
		[panel beginSheetForDirectory:nil 
			file:nil 
			types:nil 
			modalForWindow:[[self view] window]
			modalDelegate:self
			didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
			contextInfo:nil
		];
	}
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(NSInteger)returnCode  contextInfo:(void  *)contextInfo
{
	if(returnCode == NSOKButton) {
		NSString *displayName = nil;
		NSString *dest = [[panel filenames] objectAtIndex:0];
		if ((displayName = AUFinderDisplayNameForPath(dest))) {
			[[NSUserDefaults standardUserDefaults] setObject:
				dest
				forKey:kColibriUserDefaultsSaveToKey
			 ];
			
			NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:dest];
			[icon setSize:NSMakeSize(16.0, 16.0)];
			[[[self saveto] itemAtIndex:0] setImage:icon];
			[[[self saveto] itemAtIndex:0] setTitle:displayName];
			CPVC_sync = YES;
		}
	}
	
	[[self saveto] selectItemAtIndex:0];
	[panel release];
}

- (IBAction)setImageFileFormat:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:
		[NSNumber numberWithInteger:[sender selectedRow]] 
		forKey:kColibriUserDefaultsImageFormatKey
	];
	
	CPVC_sync = YES;
}

#pragma mark protocol methods

- (NSString *)label
{
	return CPVC_label;
}

- (NSView *)contentView
{
	return [self view];
}

#pragma mark protocol delegates

- (void)contentViewWillAppear
{
	CPVC_sync = NO;
}

- (void)contentViewDidAppear
{
	//
}

- (void)contentViewWillDisappear
{
	//
}

- (void)contentViewDidDisappear
{
	if (CPVC_sync) {
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end

/* EOF */