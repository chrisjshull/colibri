//
//  AUCommonGround.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#ifdef __OBJC__
	#import <Foundation/Foundation.h>
	#import <AppKit/AppKit.h>
#endif

#if !defined(__APPLICATIONUTILITY_AUCOMMONGROUND__)
#define __APPLICATIONUTILITY_AUCOMMONGROUND__ 1

#ifdef __OBJC__
	#define AU_INLINE NS_INLINE
	#define AU_EXPORT FOUNDATION_EXPORT
	
	AU_INLINE id _AUReinterpretCastCFtoNS(CFTypeRef obj)
	{
		return (id)obj;
	}

	AU_INLINE CFTypeRef _AUReinterpretCastNStoCF(id obj)
	{
		return (CFTypeRef)obj;
	}
#else
	#define AU_INLINE static inline
	#define AU_EXPORT extern
#endif

#define AU_STABILE static

#define u_byte u_char

#endif /* ! __APPLICATIONUTILITY_AUCOMMONGROUND__ */

/* EOF */