//
//  GeneralMessageProtocol.h
//  rocknroll
//
//  Created by 김 강모 on 11. 11. 11..
//  Copyright (c) 2011년 강모소프트. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @brief For passing messages (1) from PauseLayer to StageScene, (2) from QuitConfirmLayer to PauseLayer 
 */
@protocol GeneralMessageProtocol <NSObject>
-(void) onMessage:(NSString*)message;
@end
