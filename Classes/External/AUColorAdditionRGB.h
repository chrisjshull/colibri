//
//  AUColorAdditionRGB.h
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUCommonGround.h"

@interface NSColor(AUColorAdditionRGB)

- (BOOL)isRGBColor;
- (BOOL)isRGBColor:(NSString **)colorSpaceName;
- (NSColor *)setRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

@end

@interface NSColor(AUColorAdditionRGBComplementary)

- (NSColor *)complementaryColor;

@end

@interface NSColor(AUColorAdditionRGBGrayScale)

- (CGFloat)grayScaleComponent;
- (NSColor *)grayScaleColor;

@end

@interface NSColor(AUColorAdditionRGBStringRepresentation)

- (NSString *)hexaValueOfRedComponent;
- (NSString *)hexaValueOfGreenComponent;
- (NSString *)hexaValueOfBlueComponent;

- (NSString *)actualValueOfRedComponent;
- (NSString *)actualValueOfGreenComponent;
- (NSString *)actualValueOfBlueComponent;

- (NSString *)percentageValueOfRedComponent;
- (NSString *)percentageValueOfGreenComponent;
- (NSString *)percentageValueOfBlueComponent;

- (NSString *)hexaValue;
- (NSString *)actualValue;
- (NSString *)percentageValue;
- (NSString *)hslValue;




@end

/* EOF */