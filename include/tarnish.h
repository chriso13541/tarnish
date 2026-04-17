#ifndef TARNISH_H
#define TARNISH_H

// Shared logging — writes to /tmp/tarnish.log
void tlog(NSString *fmt, ...);

// Phase 1 — Frame Scheduler
void install_frame_scheduler(void);

// Phase 2 — Visual Effect Shim (not yet implemented)
void install_visual_effect_shim(void);

#endif