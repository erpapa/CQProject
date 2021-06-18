//
//  AppDelegate.m
//  CQProject
//
//  Created by CharType on 2020/7/20.
//  Copyright © 2020 CharType. All rights reserved.
//

#import "AppDelegate.h"
@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    JSObjectionInjector *injector = [JSObjection createInjector];
    [JSObjection setDefaultInjector:injector];
    
    return YES;
}


@end
