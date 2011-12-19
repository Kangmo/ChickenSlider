//
//  DeviceInfo.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 18..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#include "DeviceInfo.h"

NSString * DeviceInfo::getPlatformVersion() {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*) malloc(size);
    assert(machine);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

NSString * DeviceInfo::getUUID() {
    NSString * uuid = [[UIDevice currentDevice] uniqueIdentifier];
    return uuid;
}


NSString * DeviceInfo::getPlatform() {
    
    NSString *platform = getPlatformVersion();
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return platform;
}

NSString * DeviceInfo::getOSVersion() 
{
    NSString * osversion = [[UIDevice currentDevice] systemVersion];
    return osversion;
}

NSString * DeviceInfo::getOSBuild() 
{
    int mib[2] = {CTL_KERN, KERN_OSVERSION};
    size_t size = 0;
    
    // Get the size for the buffer
    (void) sysctl(mib, 2, NULL, &size, NULL, 0);
    assert(size>0);
    
    char *answer = (char*)malloc(size);
    assert(answer);
    
    answer[0] = 0;
    (void) sysctl(mib, 2, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return results;  
}