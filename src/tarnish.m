#import "include/tarnish.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

extern void install_frame_scheduler(void);

__attribute__((constructor))
static void tarnish_init(void) {
    NSLog(@"[Tarnish] Loading into %@",
          [[NSProcessInfo processInfo] processName]);
    
    // Force Metal to initialize so the driver classes are registered
    // before we try to swizzle them
    id<MTLDevice> dev = MTLCreateSystemDefaultDevice();
    if (!dev) {
        NSLog(@"[Tarnish] ERROR: No Metal device found");
        return;
    }
    
    install_frame_scheduler();
}