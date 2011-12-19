//
//  AppAnalytics.h
//  rocknroll
//
//  Created by 김 강모 on 11. 12. 18..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#ifndef rocknroll_AppAnalytics_h
#define rocknroll_AppAnalytics_h

#import <UIKit/UIKit.h>
#import "FlurryAnalytics.h"
#import "Util.h"
#include "DeviceInfo.h"

class AppAnalytics {
protected :
    NSMutableDictionary * eventParams;

    AppAnalytics() {
        eventParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
public :
    virtual ~AppAnalytics() {
        [eventParams release];
    }
    
    static AppAnalytics & sharedAnalytics();
    
    void startSession(const std::string & appKey) {
        [FlurryAnalytics startSession:[Util toNSString:appKey]];
    }
    void beginEventProperty() {
        [eventParams removeAllObjects];
    }

    void addEventProperty(const std::string & key, const std::string & value ) {
        [eventParams setValue:[Util toNSString:value] forKey:[Util toNSString:key]];
    }

    void addEventProperty(const std::string & key, NSString * value ) {
        [eventParams setValue:value forKey:[Util toNSString:key]];
    }

    void addEventProperty(const std::string & key, const int value ) {
        NSString * strValue = [NSString stringWithFormat:@"%d", value];
        [eventParams setValue:strValue forKey:[Util toNSString:key]];
    }

    void addEventProperty(const std::string & key, const float value ) {
        NSString * strValue = [NSString stringWithFormat:@"%f", value];
        [eventParams setValue:strValue forKey:[Util toNSString:key]];
    }

    void endEventProperty() {
        assert([eventParams count] > 0);
    }

    void logEvent(const std::string & eventString) {
        if ([eventParams count] > 0) {
            [FlurryAnalytics logEvent:[Util toNSString:eventString] withParameters:eventParams];
            [eventParams removeAllObjects];
        }
        else {
            [FlurryAnalytics logEvent:[Util toNSString:eventString] ];
        }
    }

    void beginTimedEvent(const std::string & eventString) {
        if ([eventParams count] > 0) {
            [FlurryAnalytics logEvent:[Util toNSString:eventString] withParameters:eventParams timed:YES];
            [eventParams removeAllObjects];
        } 
        else {
            [FlurryAnalytics logEvent:[Util toNSString:eventString] timed:YES ];
        }
    }
    
    void endTimedEvent(const std::string & eventString) {
        if ( [eventParams count] > 0 ) {
            [FlurryAnalytics endTimedEvent:[Util toNSString:eventString] withParameters:eventParams];
            [eventParams removeAllObjects];
        }
        else
        {
            [FlurryAnalytics endTimedEvent:[Util toNSString:eventString] withParameters:nil];
        }
    }
    
    void addDeviceProperties() {
        addEventProperty("UUID", DeviceInfo::getUUID());
        addEventProperty("Platform", DeviceInfo::getPlatform());
        addEventProperty("OSVersion", DeviceInfo::getOSVersion());
        addEventProperty("OSBuild", DeviceInfo::getOSBuild());
    }
    
    void addStageNameEventProperty(NSString * mapName, int level) {
        NSString * stageName = [NSString stringWithFormat:@"%@-%02d", mapName, level ];
        addEventProperty("StageName", [Util toStdString:stageName] );
    }
    
    void addDifficultyEventProperty() {
        int difficulty = [Util loadDifficulty];
        std::string difficultyStr = (difficulty==0)?"EASY":"HARD";
        addEventProperty("Difficulty", difficultyStr );
    }

};


#endif
