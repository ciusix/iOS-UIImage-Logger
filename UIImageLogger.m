//
//  UIImageLogger.m
//
//  Created by Justinas Rumševičius on 16-10-14.
//

#import "UIImageLogger.h"

@implementation UIImageLogger

+ (void)logUIImage:(UIImage *)image {
    if (image) {
        
        CGImageRef imageRef = [image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);

        NSMutableString *resultString = [[NSMutableString alloc] initWithString:@"\n"];
        for (NSUInteger y = 0; y < height; y++) {
            for (NSUInteger x = 0; x < width; x++) {
                NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
                CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
                CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
                CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
                CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
                
                int grayscale = 0.2989 * red * 255 + 0.5870 * green * 255 + 0.1140 * blue * 255;
                
                if (grayscale < 50) {
                   [resultString appendString:@" "];
                } else if (grayscale < 100) {
                    [resultString appendString:@"."];
                } else if (grayscale < 150) {
                    [resultString appendString:@":"];
                } else if (grayscale < 200) {
                    [resultString appendString:@"X"];
                } else {
                     [resultString appendString:@"#"];
                }
            }
            [resultString appendString:@"\n"];
        }
        printf("%s\n", [resultString UTF8String]);
    }
}

@end
