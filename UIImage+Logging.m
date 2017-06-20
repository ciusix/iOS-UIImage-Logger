//
//  UIImage+Logging.m
//
//  Created by Justinas Rumševičius on 16-10-14.
//

#import "UIImage+Logging.h"

@implementation UIImage (Logging)

- (void)logImage
{
    [self logUIImage:self];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)logUIImage:(UIImage *)image {
    if (image) {
        
        CGFloat newWidth = 0;
        CGFloat newHeight = 0;
        CGFloat maxSize = 50;
        
        if (image.size.width > image.size.height && image.size.width > maxSize)
        {
            newWidth = maxSize;
            newHeight = (maxSize / image.size.width) * image.size.height;
        }
        else if (image.size.height > maxSize)
        {
            newWidth = (maxSize / image.size.height) * image.size.width;
            newHeight = maxSize;
        }
        
        image = [self imageWithImage:image scaledToSize:CGSizeMake(newWidth * 2, newHeight)];
        
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
                CGFloat red   = (((CGFloat) rawData[byteIndex]     ) / 255.0f) * alpha;
                CGFloat green = (((CGFloat) rawData[byteIndex + 1] ) / 255.0f) * alpha;
                CGFloat blue  = (((CGFloat) rawData[byteIndex + 2] ) / 255.0f) * alpha;
                
                int grayscale = 0.2989 * red * 255 + 0.5870 * green * 255 + 0.1140 * blue * 255;
                
                if (grayscale < 25) {
                    [resultString appendString:@"@"];
                } else if (grayscale < 50) {
                    [resultString appendString:@"%"];
                } else if (grayscale < 75) {
                    [resultString appendString:@"#"];
                } else if (grayscale < 100) {
                    [resultString appendString:@"*"];
                } else if (grayscale < 125) {
                    [resultString appendString:@"+"];
                } else if (grayscale < 150) {
                    [resultString appendString:@"="];
                } else if (grayscale < 175) {
                    [resultString appendString:@"-"];
                } else if (grayscale < 200) {
                    [resultString appendString:@":"];
                } else if (grayscale < 225) {
                    [resultString appendString:@"."];
                } else {
                    [resultString appendString:@" "];
                }
            }
            [resultString appendString:@"\n"];
        }
        printf("%s\n", [resultString UTF8String]);
    }
}

@end
