//
//  ColibriApplicationController.m
//  Colibri
//
//  Created by mmw on 5/5/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#import "ColibriApplicationCommon.h"
#import "ColibriApplicationController.h"
#import "ColibriPreferencesViewController.h"
#import "AUColorAdditionExtra.h"
#import "AUColorAdditionRGB.h"
#import "AUPathUtilitiesAddition.h"

NSString *const kColibriUserDefaultsColorValueTypeKey = @"Colibri ColorValueType";
NSString *const kColibriUserDefaultsSaveToKey = @"Colibri SaveTo";
NSString *const kColibriUserDefaultsImageFormatKey = @"Colibri ImageFormat";
NSString *const kColibriUserDefaultsMainWindowLevelKey = @"Colibri MainWindowLevel";
NSString *const kColibriUserDefaultsAcceptEventGloballyKey = @"Colibri AcceptEventGlobally";
NSString *const kColibriUserDefaultsMagnifierDimensionKey = @"Colibri MagnifierDimension";
NSString *const kColibriUserDefaultsColorHistoryKey = @"Colibri ColorHistory";
NSString *const kColibriMenuActionZoomMagnifierNotificationName = @"Colibri Menu Action ZoomMagnifier";

extern NSString *const AUPreferencesSingleItemWindowDidCloseNotification;

@interface ColibriApplicationController (ColibriApplicationControllerUnexposed)

- (oneway void)setActivatesMouseMovedEvents:(BOOL)activate;
- (void)setNewDimension;
- (void)redrawMagnifier;

@end

@implementation ColibriApplicationController

@synthesize window, magnifierView, historyView;

- (void)dealloc 
{
	[super dealloc];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return NSTerminateNow;
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[self.historyView saveColors];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
		name:NSApplicationDidHideNotification 
		object:[NSApplication sharedApplication]];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
		name:NSApplicationDidUnhideNotification 
		object:[NSApplication sharedApplication]];

	[[NSApplication sharedApplication] terminate:self];
}

- (void)windowDidMiniaturize:(NSNotification *)aNotification {
	[self setActivatesMouseMovedEvents:NO];
}

- (void)windowDidDeminiaturize:(NSNotification *)aNotification {
	[self setActivatesMouseMovedEvents:YES];
}

- (void)windowDidHide:(NSNotification *)aNotification {
	[self setActivatesMouseMovedEvents:NO];
}

- (void)windowDidUnhide:(NSNotification *)aNotification {
	[self setActivatesMouseMovedEvents:YES];
}

- (void)awakeFromNib
{
	CAC_userPreferencesInitialized = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(windowDidHide:) 
		name:NSApplicationDidHideNotification 
		object:[NSApplication sharedApplication]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(windowDidUnhide:) 
		name:NSApplicationDidUnhideNotification 
		object:[NSApplication sharedApplication]];
	
	if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsColorValueTypeKey]) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:COLOR_VALUE_TYPE_HEXADECIMAL] 
			forKey:kColibriUserDefaultsColorValueTypeKey
		];
	}	
	if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsSaveToKey]) {
		NSString *desktopDirectory; 
		if (desktopDirectory = AUUserDesktopDirectory()) {
			[[NSUserDefaults standardUserDefaults] setObject:
				desktopDirectory
				forKey:kColibriUserDefaultsSaveToKey
			];
		}
	}
	if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsImageFormatKey]) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:0] 
			forKey:kColibriUserDefaultsImageFormatKey
		];
	}	
	if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsMainWindowLevelKey]) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:NSFloatingWindowLevel] 
			forKey:kColibriUserDefaultsMainWindowLevelKey
		];
	}
	if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsAcceptEventGloballyKey]) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithBool:YES] 
			forKey:kColibriUserDefaultsAcceptEventGloballyKey
		];
	}	
	if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsMagnifierDimensionKey]) {
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:MAGNIFIER_DEFAULT_DIMENSION] 
			forKey:kColibriUserDefaultsMagnifierDimensionKey
		];
	}
	[window setDelegate:self];
	NSMenu *mainMenu, *submenu;
	NSMenuItem *mainItem, *subItem;
	mainMenu = [[NSApplication sharedApplication] mainMenu];
	NSNumber *windowLevel = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsMainWindowLevelKey
	];	
	if (NSFloatingWindowLevel == [windowLevel integerValue]) {
		if ((mainItem = [mainMenu itemWithTag:IB_WINDOW_MENU_TAG])) {
			if ((submenu = [mainItem submenu])) {
				if ((subItem = [submenu itemWithTag:IB_WINDOW_MENU_ITEM_FLOAT_TOP_TAG])) {
					[subItem setState:NSOnState];
					[window setLevel:NSFloatingWindowLevel];
				}
			}
		}
	} else {
		[window setLevel:NSNormalWindowLevel];
	}
	NSNumber *colorValueType = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsColorValueTypeKey
	];
	NSInteger colorType = [colorValueType integerValue];	
	if ((mainItem = [mainMenu itemWithTag:IB_COLOR_MENU_TAG])) {
		if ((submenu = [mainItem submenu])) {
			if ((subItem = [submenu itemWithTag:IB_COLOR_MENU_ITEM_VALUE_AS_TAG])) {
				if (
					colorType != COLOR_VALUE_TYPE_ACTUAL && 
					colorType != COLOR_VALUE_TYPE_PERCENTAGE && 
					colorType != COLOR_VALUE_TYPE_HEXADECIMAL && 
					colorType != COLOR_VALUE_TYPE_HSL
				) {
					colorType = COLOR_VALUE_TYPE_HEXADECIMAL;
					[[NSUserDefaults standardUserDefaults] setObject:
						[NSNumber numberWithInteger:COLOR_VALUE_TYPE_HEXADECIMAL] 
						forKey:kColibriUserDefaultsColorValueTypeKey
					];
				}
				[[[subItem submenu] itemWithTag:colorType] setState:NSOnState];
			}
		}
	}
	
	[self.magnifierView awakeFromController];
	
	if (![self.magnifierView canZoomIn]) {
		if ((mainItem = [mainMenu itemWithTag:IB_VIEW_MENU_TAG])) {
			if ((submenu = [mainItem submenu])) {
				if ((subItem = [submenu itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_IN_TAG])) {
					[subItem setEnabled:NO];
				}
			}
		}	
	}
	
	if (![self.magnifierView canZoomOut]) {
		if ((mainItem = [mainMenu itemWithTag:IB_VIEW_MENU_TAG])) {
			if ((submenu = [mainItem submenu])) {
				if ((subItem = [submenu itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_OUT_TAG])) {
					[subItem setEnabled:NO];
				}
			}
		}	
	}
	
	NSNumber *acceptEventGlobally = [[NSUserDefaults standardUserDefaults] 
		objectForKey:kColibriUserDefaultsAcceptEventGloballyKey
	];

	if ([acceptEventGlobally boolValue]) {
		if ((mainItem = [mainMenu itemWithTag:IB_WINDOW_MENU_TAG])) {
			if ((submenu = [mainItem submenu])) {
				if ((subItem = [submenu itemWithTag:IB_WINDOW_MENU_ITEM_GLOBAL_TAG])) {
					[subItem setState:NSOnState];
					CAC_globalMouseEvents = YES;
				}
			}
		}
	} else {
		CAC_globalMouseEvents = NO;
	}
	[NSTimer scheduledTimerWithTimeInterval:0.5 
		target:self 
		selector:@selector(awakeMouseEvents:) 
		userInfo:nil 
		repeats:NO
	];
}

- (void)awakeMouseEvents:(NSTimer *)timer
{
	if (CAC_globalMouseEvents) {
		[window setAcceptsMouseMovedEvents:YES global:YES receiver:self.magnifierView];
	} else {
		[window setAcceptsMouseMovedEvents:YES global:NO receiver:nil];
	}
	[timer invalidate];
	return;
}

- (IBAction)noneAction:(id)sender {}

- (IBAction)openSystemColors:(id)sender
{
	NSColorPanel *panel = [NSColorPanel sharedColorPanel];
	[panel setLevel:NSNormalWindowLevel];
	[panel becomeKeyWindow];
	[panel orderFront:self];
}

- (IBAction)openPreferences:(id)sender
{
	if (!CAC_userPreferencesInitialized) {
		ColibriPreferencesViewController *preferenceGeneralViewController = [
			[ColibriPreferencesViewController alloc] 
				initWithLabel:NSLocalizedString(@"Colibri Preferences", @"Colibri Preferences")
		];
		CAC_preferencesController = [AUPreferencesSingleItem defaultController];
		[CAC_preferencesController setItem:preferenceGeneralViewController];
		[preferenceGeneralViewController release];
		CAC_userPreferencesInitialized = YES;
	}
	[CAC_preferencesController showWindow:self];
}

- (IBAction)setColorValueType:(id)sender
{
	if (NSOffState == [sender state]) {
		[sender setState:NSOnState];
		
		[[NSUserDefaults standardUserDefaults] setObject:
			[NSNumber numberWithInteger:[sender tag]] 
			forKey:kColibriUserDefaultsColorValueTypeKey
		];
	
		for (NSMenuItem *item in [[sender menu] itemArray]) {
			if ([item tag] != [sender tag]) {
				[item setState:NSOffState];
			}
		}
		
		[self.magnifierView redraw];
	}
}

- (IBAction)setLockForPosition:(id)sender
{
	BOOL lockX = NO, lockY = NO, lockXY = NO;
	
	if (NSOffState == [sender state]) {
		[sender setState:NSOnState];
		
		for (NSMenuItem *item in [[sender menu] itemArray]) {
			if ([item tag] != [sender tag]) {
				[item setState:NSOffState];
			}
		}
	
		switch ([sender tag]) {
			case IB_VIEW_MENU_ITEM_POSITION_MENU_ITEM_LOCKXY_TAG:
				lockX = NO;
				lockY = NO;
				lockXY = YES;
			break;
			case IB_VIEW_MENU_ITEM_POSITION_MENU_ITEM_LOCKX_TAG:
				lockX = YES;
				lockY = NO;
				lockXY = NO;
			break;
			case IB_VIEW_MENU_ITEM_POSITION_MENU_ITEM_LOCKY_TAG:
				lockX = NO;
				lockY = YES;
				lockXY = NO;
			break;
			default:
			break;
		}
	} else {
		[sender setState:NSOffState];
	}
	
	[self.magnifierView setLockPositionX:lockX];
	[self.magnifierView setLockPositionY:lockY];
	[self.magnifierView setLockPositionXY:lockXY];
}

- (IBAction)setWindowLevel:(id)sender
{
	NSInteger level, state;
	if (NSFloatingWindowLevel == [window level]) {
		state = NSOffState;
		level = NSNormalWindowLevel;
	} else {
		state = NSOnState;
		level = NSFloatingWindowLevel;
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:
		[NSNumber numberWithInteger:level] 
		forKey:kColibriUserDefaultsMainWindowLevelKey
	];
		
	[sender setState:state];
	[window setLevel:level];
}

- (IBAction)setWindowListenGlobally:(id)sender
{
	BOOL global;
	
	if ([window acceptsMouseMovedEvents:&global] && global) {
		[sender setState:NSOffState];
		[window setAcceptsMouseMovedEvents:YES global:NO receiver:nil];
	} else {
		[sender setState:NSOnState];
		[window setAcceptsMouseMovedEvents:YES global:YES receiver:self.magnifierView];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:
		[NSNumber numberWithBool:!global] 
		forKey:kColibriUserDefaultsAcceptEventGloballyKey
	];
}

- (IBAction)zoomInMagnifier:(id)sender
{
	BOOL zoom = [self.magnifierView zoomIn];
	if (!zoom) {
		[sender setEnabled:NO];
	}
	if(![[[sender menu] itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_OUT_TAG] isEnabled]) {
		[[[sender menu] itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_OUT_TAG] setEnabled:YES];
	}
}

- (IBAction)zoomOutMagnifier:(id)sender
{
	BOOL zoom = [self.magnifierView zoomOut];	
	if (!zoom) {
		[sender setEnabled:NO];
	}
	if(![[[sender menu] itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_IN_TAG] isEnabled]) {
		[[[sender menu] itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_IN_TAG] setEnabled:YES];
	}
}

- (IBAction)copyMagnifierColor:(id)sender
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSArray *pasteboardTypes = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pasteboard declareTypes:pasteboardTypes owner:self];
	[pasteboard setString:[self.magnifierView colorValue] forType:NSStringPboardType];
	[self.historyView addColor:[self.magnifierView currentColor]];
	
}

- (IBAction)saveMagnifierColor:(id)sender
{
	[self writeColorToFile:[self.magnifierView currentColor] size:NSMakeSize(100.0, 100.0) rootDestination:nil name:nil];
}

- (NSString *)saveHistoryColor:(NSColor *)aColor rootDestination:(NSString *)rootDestination
{
	NSString *name;
	if ([self writeColorToFile:aColor size:NSMakeSize(100.0, 100.0) rootDestination:rootDestination name:&name]) {
		return name;
	}	
	return [NSString stringWithString:@"unknown"];
}

- (BOOL)writeColorToFile:(NSColor *)aColor size:(NSSize)size rootDestination:(NSString *)rootDestination name:(NSString **)name 
{
	NSNumber *imageFileFormat;
	NSString *filepath;
	NSString *fileExtension;
	NSString *dest;
	if (aColor) {
		imageFileFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsImageFormatKey];
		fileExtension = [imageFileFormat integerValue] ? @"tiff" : @"png";
		if (nil != rootDestination) {
			dest = rootDestination;
		} else {
			dest = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsSaveToKey];
		}
		if (dest) {
			if (![[NSFileManager defaultManager] isWritableFileAtPath:dest]) {
				dest = nil;
				dest = AUUserDesktopDirectory();
			}	
			if (nil != name) {
				*name = [NSString stringWithFormat:@"%@.%@", [aColor hexaValue], fileExtension];
			}
			filepath = [NSString stringWithFormat:@"%@/%@.%@", dest, [aColor hexaValue], fileExtension];
			if ([imageFileFormat integerValue]) {
				return [aColor writeToTIFFFile:filepath atomically:NO size:size];
			} else {
				return [aColor writeToPNGFile:filepath atomically:NO size:size];
			}
		}
	}
	return NO;
}

- (IBAction)saveMagnifierView:(id)sender
{
	NSData *data;
	NSString *filename;
	NSString *dest;
	NSString *bundleName;
	NSBitmapImageRep *imageRep = [self.magnifierView captureView];
	NSInteger i = 1;
	
	if (imageRep) {
		NSNumber *imageFileFormat = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsImageFormatKey];
		NSBitmapImageFileType storageType = [imageFileFormat integerValue] ? NSTIFFFileType : NSPNGFileType;
		NSString *fileExtension = [imageFileFormat integerValue] ? @"tiff" : @"png";
		if ((data = [imageRep representationUsingType:storageType properties:nil])) {
			if ((dest = [[NSUserDefaults standardUserDefaults] objectForKey:kColibriUserDefaultsSaveToKey])) {
				if (![[NSFileManager defaultManager] isWritableFileAtPath:dest]) {
					dest = nil;
					dest = AUUserDesktopDirectory();
				}
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
				bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
				filename = [NSString stringWithFormat:@"%@/%@ %lu.%@", dest, bundleName, i, fileExtension];
				if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
					filename = nil;
					while (true) {
						filename = [NSString stringWithFormat:@"%@/%@ %lu.%@", dest, bundleName, i++, fileExtension];
						if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
							break;
						}
						[pool release];
						pool = [[NSAutoreleasePool alloc] init];
					}
				}
				
				[data writeToFile:filename atomically:NO];
				[pool release];
			}
		}
	}
}

- (oneway void)setActivatesMouseMovedEvents:(BOOL)activate {
	if (activate) {
		NSNumber *acceptEventGlobally = [[NSUserDefaults standardUserDefaults] 
			objectForKey:kColibriUserDefaultsAcceptEventGloballyKey
		];
		if ([acceptEventGlobally boolValue]) {
			[window setAcceptsMouseMovedEvents:YES global:YES receiver:self.magnifierView];
		} else {
			[window setAcceptsMouseMovedEvents:YES global:NO receiver:nil];
		}
	} else {
		[window setAcceptsMouseMovedEvents:NO global:NO receiver:nil];
	}
	return;
}

- (void)setNewDimension
{	
	NSMenuItem *zoomInMenuItem, *zomOutMenuItem;
	BOOL canZoomIn, canZoomOut;
	[self.magnifierView displayWithNewDimension];	
	canZoomIn = [self.magnifierView canZoomIn];
	zoomInMenuItem = [[[[[NSApplication sharedApplication] mainMenu] 
			itemWithTag:IB_VIEW_MENU_TAG] submenu] 
			itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_IN_TAG
		];
	if (canZoomIn) {
		[zoomInMenuItem setEnabled:YES];
	} else {
		[zoomInMenuItem setEnabled:NO];
	}
	
	canZoomOut = [self.magnifierView canZoomOut];
	zomOutMenuItem = [[[[[NSApplication sharedApplication] mainMenu] 
			itemWithTag:IB_VIEW_MENU_TAG] submenu] 
			itemWithTag:IB_VIEW_MENU_ITEM_ZOOM_OUT_TAG
		];
	
	if (canZoomOut) {
		[zomOutMenuItem setEnabled:YES];
	} else {
		[zomOutMenuItem setEnabled:NO];
	}
}

- (void)redrawMagnifier
{
	[self.magnifierView displayWithNewDisplay];
}

@end

/* EOF */