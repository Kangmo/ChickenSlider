//
//  ParticleManager.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 20..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#include "ParticleManager.h"


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define PARTICLE_FIRE_NAME @"fire.pvr"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define PARTICLE_FIRE_NAME @"fire.png"
#endif

CCParticleSystemQuad * ParticleManager::createParticleEmitter(NSString* particleImage, int particleCount, float duration ) 
{
    // Particle emitter.
    CCParticleSystemQuad * emitter;
    //        [emitter resetSystem];
    
    //	ParticleSystem *emitter = [RockExplosion node];
    emitter = [[[CCParticleSystemQuad alloc] initWithTotalParticles:particleCount] autorelease];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: particleImage];
    
    // duration
    //	emitter.duration = -1; //continuous effect
    emitter.duration = duration;
    
    // gravity
    emitter.gravity = CGPointZero;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // speed of particles
    emitter.speed = 160;
    emitter.speedVar = 20;
    
    // radial
    emitter.radialAccel = -120;
    emitter.radialAccelVar = 0;
    
    // tagential
    emitter.tangentialAccel = 30;
    emitter.tangentialAccelVar = 0;
    
    // life of particles
    emitter.life = 1;
    emitter.lifeVar = 1;
    
    // spin of particles
    emitter.startSpin = 0;
    emitter.startSpinVar = 0;
    emitter.endSpin = 0;
    emitter.endSpinVar = 0;
    
    // color of particles
    ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColor = startColor;
    ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
    emitter.startColorVar = startColorVar;
    ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColor = endColor;
    ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
    emitter.endColorVar = endColorVar;
    
    // size, in pixels
    emitter.startSize = 20.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kParticleStartSizeEqualToEndSize;
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.life;
    // additive
    emitter.blendAdditive = YES;
    emitter.position = ccp(0,0); // setting emitter position
    
    return emitter;
}


ARCH_OPTIMAL_PARTICLE_SYSTEM * ParticleManager::createChickSaveParticle() {
    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:45] autorelease];

    // duration
    emitter.duration = 0.1f;
    
    emitter.emitterMode = kCCParticleModeGravity;
    
    // Gravity Mode: gravity
    emitter.gravity = ccp(0,0);
    
    // Gravity Mode: speed of particles
    emitter.speed = 200;
    emitter.speedVar = 40;
    
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 0;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // emitter position
    emitter.posVar = CGPointZero;
    
    // life of particles
    emitter.life = 0.5f;
    emitter.lifeVar = 0.3;
    
    // size, in pixels
    emitter.startSize = 15.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.duration;
    
    emitter.startColor = (ccColor4F) {1.0f, 1.0f, 1.0f, 0.7f};
    emitter.startColorVar = (ccColor4F) {0.0f, 0.0f, 0.0f, 0.3f};
    emitter.endColor = (ccColor4F) {1.0f, 1.0f, 0.0f, 0.0f };
    emitter.endColorVar = (ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f};
    
    // additive
    emitter.blendAdditive = NO;
    
//    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
//	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"savechick.png"];
	emitter.autoRemoveOnFinish = YES;
    
    return emitter;
}



ARCH_OPTIMAL_PARTICLE_SYSTEM * ParticleManager::createExplosion() {
    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:300] autorelease];
    
    // duration
    emitter.duration = 0.1f;
    
    emitter.emitterMode = kCCParticleModeGravity;
    
    // Gravity Mode: gravity
    emitter.gravity = ccp(0,0);
    
    // Gravity Mode: speed of particles
    emitter.speed = 200;
    emitter.speedVar = 100;
    
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 0;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // emitter position
    emitter.posVar = CGPointZero;
    
    // life of particles
    emitter.life = 2.0f;
    emitter.lifeVar = 0.5;
    
    // size, in pixels
    emitter.startSize = 15.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    
    // emits per second
    emitter.emissionRate = emitter.totalParticles/emitter.duration;
    
    emitter.startColor = (ccColor4F) {1.0f, 1.0f, 1.0f, 1.0f};
    emitter.startColorVar = (ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f};
    emitter.endColor = (ccColor4F) {0.5f, 0.5f, 0.5f, 0.3f };
    emitter.endColorVar = (ccColor4F) {0.5f, 0.5f, 0.5f, 0.2f};
    
    // additive
    emitter.blendAdditive = NO;
    
//	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"combo.png"];
	emitter.autoRemoveOnFinish = YES;
    
    return emitter;
}

ARCH_OPTIMAL_PARTICLE_SYSTEM * ParticleManager::createMeteor() {
    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:60] autorelease];
    
    // Meter
	/*
    // duration
    emitter.duration = kCCParticleDurationInfinity;
    
    // Gravity Mode
    emitter.emitterMode = kCCParticleModeGravity;
    
    // Gravity Mode: gravity
    emitter.gravity = ccp(-240,0);
    
    // Gravity Mode: speed of particles
    emitter.speed = 15;
    emitter.speedVar = 5;
    
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 0;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // emitter position
    emitter.posVar = CGPointZero;
    
    // life of particles
    emitter.life = 2;
    emitter.lifeVar = 1;
    
    // size, in pixels
    emitter.startSize = 40.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    
    // emits per second
    emitter.emissionRate = 0;
    
    // color of particles
    emitter.startColor = (ccColor4F) {0.2f, 0.4f, 0.7f, 1.0f};
    emitter.startColorVar = (ccColor4F) {0.0f, 0.0f, 0.2f, 0.1f};
    emitter.endColor = (ccColor4F) {0.0f, 0.0f, 0.0f, 1.0f };
    emitter.endColorVar = (ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f};
    
    // additive
    emitter.blendAdditive = YES;

	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
    */
    
    
    // duration
    emitter.duration = kCCParticleDurationInfinity;
    
    // Gravity Mode
    emitter.emitterMode = kCCParticleModeGravity;
    
    // Gravity Mode: gravity
    emitter.gravity = ccp(0,0);
    
    // Gravity Mode: speed of particles
    emitter.speed = 120;
    emitter.speedVar = 30;
    
    // Gravity Mode: radial
    emitter.radialAccel = -80;
    emitter.radialAccelVar = 0;
    
    // Gravity Mode: tagential
    emitter.tangentialAccel = 80;
    emitter.tangentialAccelVar = 0;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // emitter position
    emitter.posVar = CGPointZero;
    
    // life of particles
    emitter.life = 2;
    emitter.lifeVar = 1;
    
    // size, in pixels
    emitter.startSize = 37.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    
    // emits per second
    emitter.emissionRate = 0;
    
    // color of particles
    emitter.startColor = (ccColor4F) {0.12f, 0.25f, 0.76f, 1.0f};
    emitter.startColorVar = (ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f};
    emitter.endColor = (ccColor4F) {0.0f, 0.0f, 0.0f, 1.0f };
    emitter.endColorVar = (ccColor4F) {0.0f, 0.0f, 0.0f, 0.0f};
    
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
    
    // additive
    emitter.blendAdditive = YES;

    return emitter;
}



ARCH_OPTIMAL_PARTICLE_SYSTEM * ParticleManager::createDust() {

    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:300] autorelease];
    // duration
    emitter.duration = kCCParticleDurationInfinity;
    
    // Gravity Mode
    emitter.emitterMode = kCCParticleModeGravity;
    
    // Gravity Mode: gravity
    emitter.gravity = ccp(-240,0);
    
    // Gravity Mode: speed of particles
    emitter.speed = 0;
    emitter.speedVar = 0;
    
    // Gravity Mode: radial
    emitter.radialAccel = 0;
    emitter.radialAccelVar = 0;
    
    // Gravity Mode: tagential
    emitter.tangentialAccel = 0;
    emitter.tangentialAccelVar = 0;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 360;
    
    // emitter position
    emitter.posVar = CGPointZero;
    
    // life of particles
    emitter.life = 0.5;
    emitter.lifeVar = 0.1;
    
    // size, in pixels
    emitter.startSize = 12.0f;
    emitter.startSizeVar = 7.0f;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    
    // emits per second
    emitter.emissionRate = 0;
    
    // color of particles
    emitter.startColor = (ccColor4F) {0.3f, 0.3f, 0.3f, 1.0f};
    emitter.startColorVar = (ccColor4F) {0.1f, 0.1f, 0.1f, 0.1f};
    emitter.endColor = (ccColor4F) {0.2f, 0.2f, 0.2f, 0.0f };
    emitter.endColorVar = (ccColor4F) {0.1f, 0.1f, 0.1f, 0.0f};
    
    // additive
    //emitter.blendAdditive = YES;
    
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];

    return emitter;
}


ARCH_OPTIMAL_PARTICLE_SYSTEM * ParticleManager::createRotatingStars() {
    
    ARCH_OPTIMAL_PARTICLE_SYSTEM * emitter = [[[ARCH_OPTIMAL_PARTICLE_SYSTEM alloc] initWithTotalParticles:150] autorelease];

	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"last.png"];
	
	// duration
	emitter.duration = kCCParticleDurationInfinity;
	
	// Set "Gravity" mode (default one)
	emitter.emitterMode = kCCParticleModeGravity;
    
	// Gravity mode: gravity
	emitter.gravity = CGPointZero;
	
	// Gravity mode: speed of particles
	emitter.speed = 260;
	emitter.speedVar = 80;
	
	// Gravity mode: radial
	emitter.radialAccel = -120;
	emitter.radialAccelVar = 0;
	
	// Gravity mode: tagential
	emitter.tangentialAccel = 30;
	emitter.tangentialAccelVar = 0;
	
	// emitter position
	emitter.position = ccp(160,240);
	emitter.posVar = CGPointZero;
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 360;
    
	// life of particles
	emitter.life = 2;
	emitter.lifeVar = 0.5;
    
	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 2000;
	
	// color of particles
	ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.0f, 0.0f, 0.0f, 0.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.5f, 0.5f, 0.5f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.5f, 0.5f, 0.5f, 0.2f};	
	emitter.endColorVar = endColorVar;
    
	// size, in pixels
	emitter.startSize = 10.0f;
	emitter.startSizeVar = 5.0f;
	emitter.endSize = 30.0f;
	emitter.endSizeVar = 10.0f;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;
    
	// additive
	emitter.blendAdditive = NO;
    
    emitter.autoRemoveOnFinish = YES;
    
    return emitter;

}
