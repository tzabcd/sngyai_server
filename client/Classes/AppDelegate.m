//
//  AppDelegate.m
//  LiZhuan
//
//  Created by sngyai on 14-8-27.
//
//

#import "AppDelegate.h"
#import <AdSupport/ASIdentifierManager.h>
#import "Reachability.h"
#import "ASIHTTPRequest.h"


@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NSLog(@"HELLO, WORLD**********Server State%d", [r currentReachabilityStatus]);
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWWAN:
            [self loadView];
            break;
        case ReachableViaWiFi:
            [self loadView];
            break;
    }
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"HELLO, WORLD applicationDidEnterBackground");
    __block UIBackgroundTaskIdentifier background_task;
    //Create a task object
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        [self hold];
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
}

- (void)hold
{
    NSLog(@"hold enter");
    _isBackGround = YES;
    NSLog(@"hold inner");
    while (_isBackGround) {
        NSLog(@"running ~~~~~~~~~~~~~~");
        [NSThread sleepForTimeInterval:1];
        /** clean the runloop for other source */
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
    }
    NSLog(@"hold exit");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"enter foreground");
    _isBackGround = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LocalNotification" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
    NSDictionary* dic = [[[NSDictionary alloc]init]autorelease];
    //这里可以接受到本地通知中心发送的消息
    dic = notification.userInfo;
    NSLog(@"user info = %@",[dic objectForKey:@"key"]);
    
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"HELLO, WORLD applicationWillResignActive");
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

- (void)loadView
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    TaskTableViewController *TaskController = [[[TaskTableViewController alloc] init] autorelease];
    UINavigationController *TaskNav = [[UINavigationController alloc] initWithRootViewController:TaskController];
    InfoTableViewController *InfoController = [[[InfoTableViewController alloc] init] autorelease];
    UINavigationController *InfoNav = [[UINavigationController alloc] initWithRootViewController:InfoController];
    
    //获取IDFA
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSLog(@"HELLO, WORLD *********IDFA: %@", adId);
    
    tabBar = [[[RootViewController alloc] init]autorelease];
    tabBar.delegate = self;
    tabBar.score = 0;
    NSURL *url = [NSURL URLWithString:@"http://123.57.9.112:8088/user/?msg=1001"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"HELLO, WORLD *********** RESPONSE:%@", response);
        NSData *data = [request responseData];
        NSLog(@"HELLO, WORLD *********** DATA:%@", data);
    }
    NSArray* controllerArray = [[NSArray alloc]initWithObjects:TaskNav,InfoNav,nil];
    tabBar.viewControllers = controllerArray;
    
    [[tabBar.tabBar.items objectAtIndex:0] setTitle:@"利赚-手机赚钱"];
    [(UITabBarItem *)[tabBar.tabBar.items objectAtIndex:1] setTitle:@"用户中心"];
    
    self.window.rootViewController = tabBar;
    
    [self.window makeKeyAndVisible];
}

@end