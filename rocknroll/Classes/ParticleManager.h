//
//  ParticleManager.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 20..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_ParticleManager_h
#define rocknroll_ParticleManager_h

#import <Foundation/Foundation.h>
#import "Cocos2d.h"

class ParticleManager {
public :
    static CCParticleSystemQuad * createParticleEmitter(NSString* particleImage, int particleCount, float duration );
    
    static ARCH_OPTIMAL_PARTICLE_SYSTEM * createChickSaveParticle();
    static ARCH_OPTIMAL_PARTICLE_SYSTEM * createExplosion();
    static ARCH_OPTIMAL_PARTICLE_SYSTEM * createMeteor();
    static ARCH_OPTIMAL_PARTICLE_SYSTEM * createDust();
    static ARCH_OPTIMAL_PARTICLE_SYSTEM * createRotatingStars();
    
};

#endif
