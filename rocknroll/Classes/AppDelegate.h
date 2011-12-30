#import <UIKit/UIKit.h>
#import "AdManager.h"
#import "AdWhirlWebBrowserController.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, AdWhirlWebBrowserControllerDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    AdManager           *adManager;
    BOOL                appDelegateCalledPause;

}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;
// For opening web pages in the app to show URLs such as twitter/facebook/g+.
@property (nonatomic, retain) AdWhirlWebBrowserController * webBrowserController;

-(void) pauseApp ;
-(void) resumeApp ;

-(void)openWebView:(NSString*)URLString;

@end
