//
//  AppAnalytics.cpp
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 18..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#include "AppAnalytics.h"

AppAnalytics & AppAnalytics::sharedAnalytics() {
    static AppAnalytics theAnalytics;
    return theAnalytics;
}