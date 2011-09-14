//
//  AUColorAdditionRGB.m
//  Application Utility
//
//  Copyright Cucurbita. All rights reserved.
//

#import "AUColorAdditionRGB.h"

@implementation NSColor(AUColorAdditionRGB)

- (BOOL)isRGBColor
{	
	return [self isRGBColor:nil];
}

// you are the owner of (NSString **)colorSpaceName
- (BOOL)isRGBColor:(NSString **)colorSpaceName
{	
	NSString *space = [self colorSpaceName];
	BOOL isRGBSpace = [space isEqual:NSDeviceRGBColorSpace] || [space isEqual:NSCalibratedRGBColorSpace];
	
	if (isRGBSpace && nil != colorSpaceName) {
		*colorSpaceName = [space retain];
	}	
	return isRGBSpace;
}

- (NSColor *)setRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	NSString *colorSpaceName;
	BOOL isRGB = [self isRGBColor:&colorSpaceName];
	
	if (isRGB && colorSpaceName) {
		if ([colorSpaceName isEqual:NSDeviceRGBColorSpace]) {
			[colorSpaceName release];
			return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
		}
		
		if ([colorSpaceName isEqual:NSCalibratedRGBColorSpace]) {
			[colorSpaceName release];
			return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
		}
	}	
	return nil;
}

@end

@implementation NSColor(AUColorAdditionRGBComplementary)

- (NSColor *)complementaryColor
{
	CGFloat red, green, blue, alpha;
	
	if ([self isRGBColor]) {
		red = 1.0 - [self redComponent];
		green = 1.0 - [self greenComponent];
		blue = 1.0 - [self blueComponent];
		alpha = [self alphaComponent];
	
		return [self setRed:red green:green blue:blue alpha:alpha];
	}
	return nil;
}

@end

@implementation NSColor(AUColorAdditionRGBGrayScale)

- (CGFloat)grayScaleComponent
{
	if ([self isRGBColor]) {
		return (
			0.29900f * [self redComponent] + 
			0.58700f * [self greenComponent] +
			0.11400f * [self blueComponent]
		);
	}
	return 0.0;
}

- (NSColor *)grayScaleColor
{
	if ([self isRGBColor]) {
		CGFloat gray = [self grayScaleComponent];
		CGFloat alpha = [self alphaComponent];
	
		return [self setRed:gray green:gray blue:gray alpha:alpha];
	}
	return nil;
}

@end

@implementation NSColor(AUColorAdditionRGBStringRepresentation)

AU_INLINE NSString *au_hexa_value_of_component(CGFloat c)
{
	return [NSString stringWithFormat:@"%02X", (int32_t)(c * 255.9999f)];
}

AU_INLINE NSString *au_actual_value_of_component(CGFloat c)
{
	return [NSString stringWithFormat:@"%d", (int32_t)(c * 255.9999f)];
}

AU_INLINE NSString *au_percentage_value_of_component(CGFloat c)
{
	return [NSString stringWithFormat:@"%.1f", (c * 100.0f)];
}

- (NSString *)hexaValueOfRedComponent
{
	return au_hexa_value_of_component([self redComponent]);
}

- (NSString *)hexaValueOfGreenComponent
{
	return au_hexa_value_of_component([self greenComponent]);
}

- (NSString *)hexaValueOfBlueComponent
{
	return au_hexa_value_of_component([self blueComponent]);
}

- (NSString *)actualValueOfRedComponent
{
	return au_actual_value_of_component([self redComponent]);
}

- (NSString *)actualValueOfGreenComponent
{
	return au_actual_value_of_component([self greenComponent]);
}

- (NSString *)actualValueOfBlueComponent
{
	return au_actual_value_of_component([self blueComponent]);
}

- (NSString *)percentageValueOfRedComponent
{
	return au_percentage_value_of_component([self redComponent]);
}

- (NSString *)percentageValueOfGreenComponent
{
	return au_percentage_value_of_component([self greenComponent]);
}

- (NSString *)percentageValueOfBlueComponent
{
	return au_percentage_value_of_component([self blueComponent]);
}

- (NSString *)hexaValue
{
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	
	[self getRed:&red green:&green blue:&blue alpha:nil];

	return [NSString stringWithFormat:@"#%02X%02X%02X", 
			(int32_t)(red * 255.9999f),
			(int32_t)(green * 255.9999f),
			(int32_t)(blue * 255.9999f)
		];
}

- (NSString *)actualValue
{
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	
	[self getRed:&red green:&green blue:&blue alpha:nil];

	return [NSString stringWithFormat:@"rgba(%d,%d,%d,1)", 
			(int32_t)(red * 255.9999f),
			(int32_t)(green * 255.9999f),
			(int32_t)(blue * 255.9999f)
		];
}

- (NSString *)percentageValue
{
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	
	[self getRed:&red green:&green blue:&blue alpha:nil];

	return [NSString stringWithFormat:@"%.1f %.1f %.1f", 
			(red * 100.0f),
			(green * 100.0f),
			(blue * 100.0f)
		];
}

//based on researching: http://130.113.54.154/~monger/hsl-rgb.html, http://serennu.com/colour/rgbtohsl.php
- (NSString *)hslValue
{
    CGFloat h;
	CGFloat s;
	CGFloat l;
	
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	
	[self getRed:&red green:&green blue:&blue alpha:nil];
    
    CGFloat min = MIN(red,green);
    min = MIN(min,blue);
    CGFloat max = MAX(red,green);
    max = MAX(max,blue);
    
    CGFloat delta_max = max-min;
    
    l = (min+max)/2.0f;
    
    if (max==min) {
        h = 0.0f;
        s = 0.0f;
    }
    else {
        if (l<0.5f) {
            s = (delta_max)/(max+min);
        }
        else {
            s = (delta_max)/(2.0f-max-min);
        }
        
        CGFloat delta_r = (((max - red) / 6) + (delta_max / 2)) / delta_max;
        CGFloat delta_g = (((max - green) / 6) + (delta_max / 2)) / delta_max;
        CGFloat delta_b = (((max - blue) / 6) + (delta_max / 2)) / delta_max;
        
        if (red==max) {
            h = delta_b-delta_g;
        }
        else if (green==max){
            h = (1.0f / 3.0f) + delta_r - delta_b;
        }
        else if (blue==max){
            h = (2.0f / 3.0f) + delta_g - delta_r;
        }
    }
    
    if (h<0)
        h += 1;
    else if (h>1)
        h -= 1;
        
	return [NSString stringWithFormat:@"hsla(%.0f,%.0f%%,%.0f%%,1)", 
			(h * 360.0f),
			(s * 100.0f),
			(l * 100.0f)
            ];
	
}

@end

/* EOF */