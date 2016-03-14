//
//  LockGestureView.h
//  TouchAndGesture
//
//  Created by LIAN on 16/3/10.
//  Copyright (c) 2016年 com.Alice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LockGestureView;

@protocol LockGestureDelegate <NSObject>

@optional

-(void)lockGestureSetResult:(NSString *)result andGestureView:(LockGestureView *)gestureView;
-(void)lockGesturePasswordRight:(LockGestureView *)gestureView;
-(void)lockGesturePasswordWrong:(LockGestureView *)gestureView;
-(void)lockGesturePasswordShort:(LockGestureView *)gestureView;
-(void)lockGesturePasswordReset:(LockGestureView *)gestureView;
-(void)lockGesturePasswordTwiceDifferent:(LockGestureView *)gestureView;


@end

@interface LockGestureView : UIView

@property (strong,nonatomic) NSMutableArray *selectedBtns;
@property (nonatomic) CGPoint currentPoint;
@property (weak,nonatomic) id<LockGestureDelegate> delegate;

@property (strong,nonatomic) NSString *resultRight;

@property (nonatomic) BOOL isResetPW;

-(instancetype)initWithFrame:(CGRect)frame;


@end
