//
//  SubViewController.m
//  Grocery
//
//  Created by Work on 8/29/17.
//  Copyright © 2017 Xiao Lu. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController ()
@property (weak, nonatomic) UIImageView *backgroundImageView;
@end

@implementation SubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor clearColor]];
    UIImage *backgroundImage = [UIImage imageNamed:@"background"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    self.backgroundImageView = backgroundImageView;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.image=backgroundImage;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
//    [self configureMotionEffect];
}

- (void) configureMotionEffect {
    CGFloat leftRightMin = -20.0f;
    CGFloat leftRightMax = 20.0f;
    
    // Horizontal Motion effect
    UIInterpolatingMotionEffect *leftRight = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    
    leftRight.minimumRelativeValue = @(leftRightMin);
    leftRight.maximumRelativeValue = @(leftRightMax);
    
    // Vertical Motion effect
    UIInterpolatingMotionEffect *upDown = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    upDown.minimumRelativeValue = @(leftRightMin);
    upDown.maximumRelativeValue = @(leftRightMax);
    
    // Create a motion effect group
    UIMotionEffectGroup *meGrup = [[UIMotionEffectGroup alloc] init];
    meGrup.motionEffects = @[leftRight, upDown];
    
    [self.backgroundImageView addMotionEffect:meGrup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
