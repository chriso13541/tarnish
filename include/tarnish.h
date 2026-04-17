// include/tarnish.h
#ifndef TARNISH_H
#define TARNISH_H

// Phase 1 — Frame Scheduler
// Hooks MTLIGAccelCommandBuffer waitUntilCompleted to prevent GPU stalls
// from blocking the UI thread
void install_frame_scheduler(void);

// Phase 2 — Visual Effect Shim (not yet implemented)
// Will hook NSVisualEffectView to replace expensive blur with flat textures
void install_visual_effect_shim(void);

#endif