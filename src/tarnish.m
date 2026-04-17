#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "include/tarnish.h"

void tlog(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    
    NSString *line = [NSString stringWithFormat:@"[Tarnish] %@\n", msg];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:@"/tmp/tarnish.log"];
    [fh seekToEndOfFile];
    [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

__attribute__((constructor))
static void tarnish_init(void) {
    // Create log file if it doesn't exist
    [[NSFileManager defaultManager] createFileAtPath:@"/tmp/tarnish.log"
                                            contents:nil
                                          attributes:nil];

    tlog(@"Loading into %@", [[NSProcessInfo processInfo] processName]);

    id<MTLDevice> dev = MTLCreateSystemDefaultDevice();
    if (!dev) {
        tlog(@"ERROR: No Metal device found");
        return;
    }

    tlog(@"Metal device: %@", dev.name);
    install_frame_scheduler();
}