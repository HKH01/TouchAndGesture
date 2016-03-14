//
//  LockGestureView.m
//  TouchAndGesture
//
//  Created by LIAN on 16/3/10.
//  Copyright (c) 2016年 com.Alice. All rights reserved.
//

#import "LockGestureView.h"


#define HEIGHT_TEMP 6

@implementation LockGestureView

@synthesize selectedBtns = _selectedBtns;
@synthesize currentPoint = _currentPoint;
@synthesize resultRight = _resultRight;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _selectedBtns = [NSMutableArray arrayWithCapacity:9];
        //排布按钮
        float tempgap = self.frame.size.width/13;
        float radius = tempgap*3;
        for (int i = 0; i < 9; i++) {
            int row = i/3;
            int col = i%3;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(col*(tempgap +radius)+tempgap, row*(tempgap+radius)+tempgap, radius, radius);
            btn.tag = i+1;
            [btn setImage:[self drawImageUnselectedwithRaidius:radius] forState:UIControlStateNormal];
            [btn setImage:[self drawImageSelectedwithRadius:radius] forState:UIControlStateSelected];
            btn.userInteractionEnabled = NO;
            [self addSubview:btn];
        }
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    UIBezierPath *path;
    if (_selectedBtns.count == 0) {
        return;
    }
    path = [UIBezierPath bezierPath];
    path.lineWidth = HEIGHT_TEMP;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    
    if (self.userInteractionEnabled) {
        [[UIColor blueColor]set];
    }
    else
    {
        [[UIColor orangeColor]set];
    }
    for (int i = 0; i < _selectedBtns.count; i ++) {
        UIButton *btn = _selectedBtns[i];
        
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else
        {
            [path addLineToPoint:btn.center];
        }
    }
    [path addLineToPoint:_currentPoint];
    [path stroke];
}
/**
 *  恢复原状
 */
-(void)resetView
{
    for (UIButton *btn  in _selectedBtns) {
        btn.selected = NO;
    }
    [_selectedBtns  removeAllObjects];
    [self setNeedsDisplay];
    
}
//设置密码
- (void)setRigthResult:(NSString *)rightResult
{
    _resultRight = rightResult;
}

/**
 *     密码输入错误
 */
-(void)wrongPWwithArray:(NSArray *)array
{
    self.userInteractionEnabled = YES;
    for (UIButton *btn in array) {
        float tempgap = self.frame.size.width/13;
        float radius = tempgap*3;
        [btn setImage:[self drawImageSelectedwithRadius:radius] forState:UIControlStateSelected];

    }
    [self resetView];
}
#pragma mark === Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point)) {
            btn.selected = YES;
            if (![_selectedBtns containsObject:btn]) {
                [_selectedBtns addObject:btn];
            }
        }
    }
    [self resetView];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _currentPoint = point;
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point)) {
            btn.selected = YES;
            if (![_selectedBtns containsObject:btn]) {
                [_selectedBtns addObject:btn];
            }
        }
    }
    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableString *resultStr = [[NSMutableString alloc]initWithCapacity:0];
    for (UIButton *btn in _selectedBtns) {
        [resultStr appendFormat:@"%ld",(long)btn.tag];
    }
    UIButton *lastBtn = [_selectedBtns lastObject];
    _currentPoint = lastBtn.center;
    
    if (resultStr.length < 4) {
        [self.delegate lockGesturePasswordShort:self];
        for (UIButton *btn in _selectedBtns) {
            float tempgap = self.frame.size.width/13;
            float radius = tempgap*3;
            [btn setImage:[self drawImageWrongwithRadius:radius] forState:UIControlStateSelected];
        }
        
        [self performSelector:@selector(wrongPWwithArray:) withObject:[NSArray arrayWithArray:_selectedBtns] afterDelay:1.0f];
        self.userInteractionEnabled = NO;
        [self setNeedsDisplay];
        return;
    }
    
     NSString *key = [[NSUserDefaults standardUserDefaults]objectForKey:@"KEY"];
    if (key) {
        if ([resultStr isEqualToString:key]) {
            if (self.isResetPW) {
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"TWICE"];
                [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"KEY"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self.delegate lockGesturePasswordReset:self];
                [self resetView];
                self.isResetPW = NO;
            }
            else{
                NSLog(@"密码正确！%@",resultStr);
                [self.delegate lockGesturePasswordRight:self];
                [self resetView];
            }
        }
        else
        {
            [self.delegate lockGesturePasswordWrong:self];
            NSLog(@"密码错误！");

            
            for (UIButton *btn in _selectedBtns) {
                float tempgap = self.frame.size.width/13;
                float radius = tempgap*3;
                [btn setImage:[self drawImageWrongwithRadius:radius] forState:UIControlStateSelected];
            }

            [self performSelector:@selector(wrongPWwithArray:) withObject:[NSArray arrayWithArray:_selectedBtns] afterDelay:1.0f];
            self.userInteractionEnabled = NO;
            [self setNeedsDisplay];
            
            
        }
       
    }
    else
    {
        self.isResetPW = NO;
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"TWICE"]){
            if (!_resultRight) {
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"TWICE"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self.delegate lockGestureSetResult:resultStr andGestureView:self];
                
            }
        }
        else{
            if (_resultRight) {
                if ([_resultRight isEqualToString:resultStr]) {
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    [def setObject:resultStr forKey:@"KEY"];
                    [def synchronize];
                    [self.delegate lockGesturePasswordRight:self];
                    
                }
                else{
                    //两次输入不一致
                    [self.delegate lockGesturePasswordTwiceDifferent:self];
                }
            }
            else
            {
                [self.delegate lockGestureSetResult:resultStr andGestureView:self];
            }
        }
        [self resetView];
    }
    
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark === CGContext

//初步排布的按钮

-(UIImage *)drawImageUnselectedwithRaidius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius +HEIGHT_TEMP, radius+HEIGHT_TEMP));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, CGRectMake(HEIGHT_TEMP/2, HEIGHT_TEMP/2, radius, radius)); //画个圈圈
    [[UIColor purpleColor]setStroke]; //颜色
    CGContextSetLineWidth(context, 5); //线条宽度
    
    CGContextDrawPath(context, kCGPathStroke); //路径
    
    UIImage *unselectIma = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext();
    return unselectIma;

}

//触摸选中的按钮
-(UIImage *)drawImageSelectedwithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+HEIGHT_TEMP, radius+HEIGHT_TEMP));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5); //线条宽度

    CGContextAddEllipseInRect(context, CGRectMake(HEIGHT_TEMP/2+radius*5/12, HEIGHT_TEMP/2+radius*5/12, radius/HEIGHT_TEMP, radius/HEIGHT_TEMP));//实心圆点
    [[UIColor blueColor]set];
    CGContextDrawPath(context, kCGPathFillStroke);//实心
    
    CGContextAddEllipseInRect(context, CGRectMake(HEIGHT_TEMP/2, HEIGHT_TEMP/2, radius, radius)); //画个圈圈
    [[UIColor blueColor]setStroke]; //颜色
    CGContextDrawPath(context, kCGPathStroke); //路径
    
    UIImage *selectIma = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext();
    
    return selectIma;
}

/**
 *  错误密码
 */

-(UIImage *)drawImageWrongwithRadius:(float)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius+HEIGHT_TEMP, radius+HEIGHT_TEMP));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 5);
    
    CGContextAddEllipseInRect(context, CGRectMake(HEIGHT_TEMP/2+radius*5/12, HEIGHT_TEMP/2+radius*5/12, radius/HEIGHT_TEMP, radius/HEIGHT_TEMP));
    [[UIColor redColor]set];
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextAddEllipseInRect(context, CGRectMake(HEIGHT_TEMP/2, HEIGHT_TEMP/2, radius, radius));
    [[UIColor redColor]setStroke];
     CGContextDrawPath(context, kCGPathStroke); //路径
    
    UIImage *wrongIma = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return wrongIma;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
