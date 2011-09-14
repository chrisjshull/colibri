//
//  ColibriPreferencesViewController.h
//  Colibri
//
//  Created by mmw on 11/16/08.
//  Copyright 2008 Cucurbita. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AUPreferencesSingleItem.h"

@interface ColibriPreferencesViewController : NSViewController <AUPreferencesSingleItemController> {

@private
	BOOL CPVC_sync;
	NSString *CPVC_label;

@public
	NSSlider *zoom;
	NSPopUpButton *saveto;
	NSMatrix *format;
}

@property (assign) IBOutlet NSSlider *zoom;
@property (assign) IBOutlet NSPopUpButton *saveto;
@property (assign) IBOutlet NSMatrix *format;

- (id)initWithLabel:(NSString *)label;
- (IBAction)updateZoom:(id)sender;
- (IBAction)openDocument:(id)sender;
- (IBAction)setImageFileFormat:(id)sender;
- (NSString *)label;
- (NSView *)contentView;

@end

/* EOF */