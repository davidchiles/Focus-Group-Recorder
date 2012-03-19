//
//  UBCAppDelegate.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCAppDelegate.h"

#import "UBCMainViewController.h"
#import "UBCsecret.h"

@implementation UBCAppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mainViewController = [[UBCMainViewController alloc] initWithNibName:@"UBCMainViewController" bundle:nil];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    
    DBSession* dbSession =
    [[DBSession alloc]
      initWithAppKey:[UBCsecret getAppKey]
      appSecret:[UBCsecret getAppSecret]
      root:kDBRootDropbox // either kDBRootAppFolder or kDBRootDropbox
      ];
    [DBSession setSharedSession:dbSession];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLinked" object:nil];
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

@end
