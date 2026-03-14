// ExceptionHandler.h
#import <Foundation/Foundation.h>

/// n ObjC @try/@catch block exposed via a C function — is the standard and recommended approach for catching
/// Objective-C exceptions in Swift. Swift has no native @try/@catch mechanism, so a bridging function like this is
/// necessary.
void ExceptionCatcherOperation(void (^_Nonnull tryBlock)(void), void (^_Nullable catchBlock)(NSException *_Nonnull));
