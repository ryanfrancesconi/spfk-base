// ExceptionHandler.h
#import <Foundation/Foundation.h>

void ExceptionCatcherOperation(void (^ _Nonnull tryBlock)(void),
                               void (^ _Nullable catchBlock)(NSException * _Nonnull));
