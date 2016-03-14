//
//  ViewController.h
//  TouchAndGesture
//
//  Created by LIAN on 16/3/10.
//  Copyright (c) 2016年 com.Alice. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LockGestureView.h"

@interface ViewController : UIViewController<LockGestureDelegate>

@property (strong,nonatomic) LockGestureView *lockUI;
@property (strong,nonatomic) UILabel *tipLabel;

@end

