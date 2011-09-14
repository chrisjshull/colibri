//
//  AUPreferencesSingleItem.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUCommonGround.h"

#define AUPREFERENCES_SINGLEITEM_SINGLETONIZED

@protocol AUPreferencesSingleItemController <NSObject>

- (NSString *)label;
- (NSView *)contentView;

@optional
- (void)contentViewWillAppear;
- (void)contentViewDidAppear;
- (void)contentViewWillDisappear;
- (void)contentViewDidDisappear;

@end

@interface AUPreferencesSingleItem : NSWindowController
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)
<NSWindowDelegate>
#endif
{
@private
	id<AUPreferencesSingleItemController> _item;

}

#ifdef AUPREFERENCES_SINGLEITEM_SINGLETONIZED
+ (AUPreferencesSingleItem *)defaultController;
#endif

- (void)setItem:(id<AUPreferencesSingleItemController>)item;

@end

/* EOF */