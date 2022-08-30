#import <Foundation/Foundation.h>
#import <ProgrammaticAccessLibrary/PALDefines.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
#error The ProgrammaticAccessLibrary SDK requires a deployment target of iOS 8.0 or later.
#endif

#import <ProgrammaticAccessLibrary/PALNonceError.h>
#import <ProgrammaticAccessLibrary/PALNonceLoader.h>
#import <ProgrammaticAccessLibrary/PALNonceManager.h>
#import <ProgrammaticAccessLibrary/PALNonceRequest.h>
#import <ProgrammaticAccessLibrary/PALSettings.h>
