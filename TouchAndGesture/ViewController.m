//
//  ViewController.m
//  TouchAndGesture
//
//  Created by LIAN on 16/3/10.
//  Copyright (c) 2016年 com.Alice. All rights reserved.
//


#define kUIWidth [UIScreen mainScreen].bounds.size.width
#define kUIHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize lockUI = _lockUI;
@synthesize tipLabel = _tipLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _lockUI = [[LockGestureView alloc]initWithFrame:CGRectMake(25, 150,kUIWidth-50 , kUIWidth-50)];
    _lockUI.delegate = self;
    [self.view addSubview:_lockUI];
    
    _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 80, kUIWidth-50, 30)];
    _tipLabel.text = @"请设置密码";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_tipLabel];
    
    UIButton *resetPW = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    resetPW.frame = CGRectMake(25, kUIWidth+120, 100, 30);
    [resetPW setTitle:@"重置密码" forState:UIControlStateNormal];
    [resetPW addTarget:self action:@selector(passwordReset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetPW];
    

    UIButton *touchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    touchBtn.frame = CGRectMake(150,  kUIWidth+120, 100, 30);
    [touchBtn setTitle:@"使用指纹" forState:UIControlStateNormal];
    [touchBtn addTarget:self action:@selector(addTouchID) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:touchBtn];
}
-(void)addTouchID
{
    LAContext *laContext = [[LAContext alloc]init];
    NSError *err = nil;
    //判断设备是否支持指纹识别
    BOOL isSupport = [laContext canEvaluatePolicy:
                      LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&err];
    if (isSupport) {
        NSLog(@"设备开启了指纹识别");
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:@"放置指纹" reply:^(BOOL success, NSError *error) {
                      if (success) {
                          _tipLabel.text = @"密码正确";
                          NSLog(@"成功开启");
                      }
                      else
                      {
                          NSLog(@"识别失败！原因是  %@",error);
                      }
                  }];
    }
    else
    {
        NSLog(@"设备不支持指纹识别，原因是 %@",err);
    }
}
-(void)passwordReset:(id)sender
{
    _lockUI.isResetPW = YES;
    _tipLabel.text =@"请输入原始密码";
}

#pragma mark === LockGestureDelegate
-(void)lockGesturePasswordRight:(LockGestureView *)gestureView
{
    _tipLabel.text = @"密码正确";
}
-(void)lockGesturePasswordWrong:(LockGestureView *)gestureView
{
    _tipLabel.text = @"密码错误请重新输入";
}
-(void)lockGestureSetResult:(NSString *)result andGestureView:(LockGestureView *)gestureView
{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"TWICE"]) {
        _tipLabel.text = @"请再次输入";
        [_lockUI setResultRight:result];
    }
    else
    {
        _tipLabel.text = @"请输入密码";
        [_lockUI setResultRight:result];
    }
}
-(void)lockGesturePasswordTwiceDifferent:(LockGestureView *)gestureView
{
    _tipLabel.text =@"两次手势不同请重新输入";
    [_lockUI setResultRight:nil];

}
-(void)lockGesturePasswordShort:(LockGestureView *)gestureView
{
    _tipLabel.text = @"至少是四位密码";
}
-(void)lockGesturePasswordReset:(LockGestureView *)gestureView
{
    _tipLabel.text = @"请重新输入新密码";
    [_lockUI setResultRight:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
