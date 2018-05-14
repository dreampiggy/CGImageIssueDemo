//
//  ViewController.m
//  CGImageIssueDemo
//
//  Created by lizhuoli on 2018/5/14.
//  Copyright © 2018年 cocoapods. All rights reserved.
//

#import "ViewController.h"

static void * ProviderInfo = &ProviderInfo;
static size_t BufferWidth = 1;
static size_t BufferHeight = 1;
static uint8_t PixelBuffer[4] = {255, 128, 128, 128};

// This `GetBytePointerCallback` return is nullable, however, when return a NULL pointer, it will cause crash during Core Animation rendering. This only occurred after iOS 11.2+
// Using public API `CGDataProviderCopyData` will also cause crash

static const void * GetBytePointerCallback(void *info) {
    NSCParameterAssert(info == ProviderInfo);
    return NULL;
    //    return PixelBuffer;
}

static size_t GetBytesAtPositionCallback(void *info, void *buffer, off_t pos, size_t cnt) {
    NSCParameterAssert(info == ProviderInfo);
    return 0;
}

static void ReleaseBytePointerCallback(void *info, const void *pointer) {
    NSCParameterAssert(info == ProviderInfo);
}

static void ReleaseInfoCallback(void *info) {
    NSCParameterAssert(info == ProviderInfo);
}

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    
    [self testProviderCreateDirect];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testProviderCreateDirect {
    CGDataProviderDirectCallbacks callbacks = {
        .getBytePointer = GetBytePointerCallback,
        .getBytesAtPosition = GetBytesAtPositionCallback,
        .releaseBytePointer = ReleaseBytePointerCallback,
        .releaseInfo = ReleaseInfoCallback,
        .version = 0,
    };
    size_t size = 100000;
    CGDataProviderRef provider = CGDataProviderCreateDirect(ProviderInfo, size, &callbacks);
    
    // Using public API `CGDataProviderCopyData` will also cause crash
//    CFDataRef dataRef = CGDataProviderCopyData(provider);
    
    CGImageRef imageRef = [self createImageRefWithDataProvider:provider];
    NSParameterAssert(imageRef);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    self.imageView.image = image;
}

- (nullable CGImageRef)createImageRefWithDataProvider:(nonnull CGDataProviderRef)provider {
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytePerRow = BufferWidth * bitsPerPixel / 8;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault;
    CGColorRenderingIntent intent = kCGRenderingIntentDefault;
    
    CGImageRef image = CGImageCreate(BufferWidth, BufferHeight, bitsPerComponent, bitsPerPixel, bytePerRow, space, bitmapInfo, provider, NULL, YES, intent);
    CGColorSpaceRelease(space);
    
    return image;
}


@end
