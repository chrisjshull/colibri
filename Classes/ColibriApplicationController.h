//
//  ColibriApplicationController.h
//  Colibri
//
//  Created by mmw on 5/5/09.
//  Copyright 2009 Cucurbita. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ColibriMainWindow.h"
#import "ColibriMagnifierView.h"
#import "ColibriHistoryView.h"

@class AUPreferencesSingleItem;

@interface ColibriApplicationController : NSObject {

@private
	BOOL CAC_userPreferencesInitialized;
	AUPreferencesSingleItem *CAC_preferencesController;
	BOOL CAC_globalMouseEvents;

@public
	ColibriMainWindow *window;
	ColibriMagnifierView *magnifierView;
	ColibriHistoryView *historyView;
}

@property (assign) IBOutlet ColibriMainWindow *window;
@property (assign) IBOutlet ColibriMagnifierView *magnifierView;
@property (assign) IBOutlet ColibriHistoryView *historyView;

- (IBAction)noneAction:(id)sender;
- (IBAction)openSystemColors:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)setColorValueType:(id)sender;
- (IBAction)setLockForPosition:(id)sender;
- (IBAction)setWindowLevel:(id)sender;
- (IBAction)setWindowListenGlobally:(id)sender;
- (IBAction)zoomInMagnifier:(id)sender;
- (IBAction)zoomOutMagnifier:(id)sender;
- (IBAction)copyMagnifierColor:(id)sender;
- (IBAction)saveMagnifierColor:(id)sender;
- (NSString *)saveHistoryColor:(NSColor *)aColor rootDestination:(NSString *)rootDestination;
- (BOOL)writeColorToFile:(NSColor *)aColor size:(NSSize)size rootDestination:(NSString *)rootDestination name:(NSString **)name;
- (IBAction)saveMagnifierView:(id)sender;

@end

/* EOF */