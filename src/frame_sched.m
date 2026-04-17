// src/frame_sched.m
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>

#define GPU_TIMEOUT_NS 8000000ULL  // 8ms timeout

static IMP original_waitUntilCompleted = NULL;

static void tarnish_waitUntilCompleted(id self, SEL _cmd) {
    id<MTLCommandBuffer> buf = (id<MTLCommandBuffer>)self;
    
    // Already done, return immediately
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
        // Timed out — GPU is overloaded, log it but don't stall
        // UI thread continues, frame may be dropped
        NSLog(@"[Tarnish] GPU timeout on waitUntilCompleted — dropping frame");
    }
}

void install_frame_scheduler(void) {
    Class igAccelClass = objc_getClass("MTLIGAccelCommandBuffer");
    if (!igAccelClass) {
        NSLog(@"[Tarnish] ERROR: MTLIGAccelCommandBuffer not found");
        return;
    }
    
    // Hook waitUntilCompleted directly on MTLIGAccelCommandBuffer
    // We confirmed all three classes share the same IMP so one hook covers all
    Method waitMethod = class_getInstanceMethod(igAccelClass, 
                                                @selector(waitUntilCompleted));
    if (waitMethod) {
        original_waitUntilCompleted = method_getImplementation(waitMethod);
        method_setImplementation(waitMethod, (IMP)tarnish_waitUntilCompleted);
        NSLog(@"[Tarnish] Hooked waitUntilCompleted on MTLIGAccelCommandBuffer");
    } else {
        NSLog(@"[Tarnish] ERROR: waitUntilCompleted method not found");
    }
}