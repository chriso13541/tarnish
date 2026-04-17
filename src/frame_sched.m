#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>

#define GPU_TIMEOUT_NS 8000000ULL  // 8ms

extern void tlog(NSString *fmt, ...);

static IMP original_waitUntilCompleted = NULL;

static void tarnish_waitUntilCompleted(id self, SEL _cmd) {
    id<MTLCommandBuffer> buf = (id<MTLCommandBuffer>)self;

    MTLCommandBufferStatus status = buf.status;
    if (status == MTLCommandBufferStatusCompleted ||
        status == MTLCommandBufferStatusError ||
        status == MTLCommandBufferStatusNotEnqueued) {
        return;
    }

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [buf addCompletedHandler:^(id<MTLCommandBuffer> b) {
        dispatch_semaphore_signal(sem);
    }];

    long result = dispatch_semaphore_wait(
        sem,
        dispatch_time(DISPATCH_TIME_NOW, GPU_TIMEOUT_NS)
    );

    if (result != 0) {
        tlog(@"GPU timeout on waitUntilCompleted — dropping frame");
    }
}

void install_frame_scheduler(void) {
    Class igAccelClass = objc_getClass("MTLIGAccelCommandBuffer");
    if (!igAccelClass) {
        tlog(@"ERROR: MTLIGAccelCommandBuffer not found");
        return;
    }

    Method waitMethod = class_getInstanceMethod(igAccelClass,
                                                @selector(waitUntilCompleted));
    if (waitMethod) {
        original_waitUntilCompleted = method_getImplementation(waitMethod);
        method_setImplementation(waitMethod, (IMP)tarnish_waitUntilCompleted);
        tlog(@"Hooked waitUntilCompleted on MTLIGAccelCommandBuffer");
    } else {
        tlog(@"ERROR: waitUntilCompleted not found");
    }
}