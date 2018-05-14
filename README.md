# CGImageIssueDemo
Core Graphics issue test

# What for

It seems that there are a strange crash for iOS 11.2+ about `CoreGraphics.framework`.

There are already a developer thread talk about this: [ERROR_CGDataProvider_BufferIsNotReadable crash
](https://forums.developer.apple.com/thread/94163). This is just a demo to test the issue.

# Issue

From iOS 11.2+ (Up to iOS 11.3.1 now), the `CGDataProviderRetainBytePtr` method which is called from public API `CGDataProviderCopyData`, will crash at the internal method `ERROR_CGDataProvider_BufferIsNotReadable`.

The crash seems that `ERROR_CGDataProvider_BufferIsNotReadable` is attempting to dereference a NULL pointer. Which cause a `EXC_BAD_ACCESS KERN_INVALID_ADDRESS 0x0000000000000000`.

# Steps to Reproduce
1. Create a `CGDataProviderCreateDirect` using `CGDataProviderCreateDirect`, which `getBytePointer` function callback return NULL buffer.

2. Create a new `CGImageRef` using the data provider above with valid args.

3. Call `CGDataProviderCopyData` public API, or implicitlly called from Core Animation during this image rendering in `UIImageView`

