// src/visual_effect.m
// NSVisualEffectView shim — Phase 2
// Targets the blur/vibrancy overhead causing System Settings slowness
// Not yet implemented — placeholder for next module

#import <Foundation/Foundation.h>

void install_visual_effect_shim(void) {
    // TODO: swizzle NSVisualEffectView updateLayer
    // to replace expensive backdrop blur with flat cached texture
    NSLog(@"[Tarnish] visual_effect shim not yet active");
}