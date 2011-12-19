//
//  DeviceHardware.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 18..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_DeviceInfo_h
#define rocknroll_DeviceInfo_h

#include <sys/types.h>
#include <sys/sysctl.h>

class DeviceInfo {
private:
    static NSString * getPlatformVersion();

public :
    static NSString * getUUID();
    static NSString * getPlatform();
    static NSString * getOSVersion();
    static NSString * getOSBuild();
};


#endif
