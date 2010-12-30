//
//  AUColorAdditionExtra.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUCommonGround.h"

@interface NSColor(AUColorAdditionExtra)

- (NSImage *)imageWithSize:(NSSize)size;
- (NSImage *)imageWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha;
- (NSImage *)imageWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha drawBorder:(BOOL)drawBorder;
- (NSData *)PNGDataWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha;
- (NSData *)PNGDataWithSize:(NSSize)size;
- (NSData *)TIFFDataWithSize:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha;
- (NSData *)TIFFDataWithSize:(NSSize)size;
- (BOOL)writeToPNGFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size;
- (BOOL)writeToPNGFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha;
- (BOOL)writeToTIFFFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size;
- (BOOL)writeToTIFFFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size ignoreAlpha:(BOOL)ignoreAlpha;
- (BOOL)writeToJPEGFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size;
- (BOOL)writeToGIFFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size;
- (BOOL)writeToBMPFile:(NSString *)path atomically:(BOOL)flag size:(NSSize)size;

@end

/* EOF */