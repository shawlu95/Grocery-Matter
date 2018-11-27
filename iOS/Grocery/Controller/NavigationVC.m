//
//  NavigationVC.m
//  Grocery
//
//  Created by Xiao on 7/5/16.
//  Copyright © 2016 Xiao Lu. All rights reserved.
//

#import "NavigationVC.h"

@interface NavigationVC ()

@end

@implementation NavigationVC

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}


@end
