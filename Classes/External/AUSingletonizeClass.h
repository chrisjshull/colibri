//
//  AUSingletonizeClass.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

//
//  SynthesizeSingleton.h
//
//  Created by Matt Gallagher on 20/10/08.  All rights reserved.
//

#import "AUCommonGround.h"

#define AU_SINGLETONIZE_CLASS_RAISE_EXCEPTION \
	[NSException raise:NSInternalInconsistencyException format:@"Application Utility: Singleton Object"]
	
#define AU_SINGLETONIZE_CLASS(classname) \
	AU_SINGLETONIZE_CLASS_USING_INSTANCE(classname, shared##classname)
	
#define AU_SINGLETONIZE_CLASS_USING_INSTANCE(classname, instancename) \
 \
static classname *_au_shared##classname = nil; \
 \
+ (classname *)instancename \
{ \
	@synchronized(self) \
	{ \
		if (_au_shared##classname == nil) \
		{ \
			[[self alloc] init]; \
		} \
	} \
	 \
	return _au_shared##classname; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (_au_shared##classname == nil) \
		{ \
			_au_shared##classname = [super allocWithZone:zone]; \
			return _au_shared##classname; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	AU_SINGLETONIZE_CLASS_RAISE_EXCEPTION; \
	return self; \
} \
 \
- (id)copy \
{ \
	AU_SINGLETONIZE_CLASS_RAISE_EXCEPTION; \
	return self; \
} \
 \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (void)release \
{ \
 \
} \
 \
- (id)autorelease \
{ \
	AU_SINGLETONIZE_CLASS_RAISE_EXCEPTION; \
	return self; \
}

/* EOF */