//
//  KKPHobbyDraggableView.m
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/23.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import "KKPHobbyDraggableView.h"
#import <QuartzCore/QuartzCore.h>


static const CGFloat kRotationMax                           = 1.0;
static const CGFloat kDefaultRotationAngle                  = (M_PI) / 10.0;
static const CGFloat kScaleMin                              = 0.8;
static const CGFloat kDraggableSwipeActionAnimationDuration = 0.30;
static const CGFloat kDraggableResetAnimationDuration       = 0.30;

#define defaultActionFlagMargin (self.bounds.size.width / 4);

@interface KKPHobbyDraggableView ()

@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, readwrite, assign) CGPoint originalLocation;
@property (nonatomic, readwrite) UIView *customView;
@property (nonatomic, assign) CGFloat xDistanceFromCenter;
@property (nonatomic, assign) CGFloat yDistanceFromCenter;
@property (nonatomic, assign) CGFloat animationDirection;
@property (nonatomic, assign) CGPoint tempCenter;

@end

@implementation KKPHobbyDraggableView

#pragma mark - public Method

//- (instancetype)initWithFrame:(CGRect)frame cutsomeView:(UIView *)view
//{
//    if (self = [super initWithFrame:frame]) {
//        [self setCustomView:view];
//    }
//    return self;
//}

- (void)swipeOutInDirection:(KKPHobbySwipeDirection)direction
{
    switch (direction) {
        case KKPHobbySwipeDirectionRight:
        {
            [self swipeOutInDirection:KKPHobbySwipeDirectionRight complete:self.rightBlock];
            break;
        }
        case KKPHobbySwipeDirectionLeft:
        {
            [self swipeOutInDirection:KKPHobbySwipeDirectionLeft complete:self.leftBlock];
            break;
        }
        default:
            break;
    }

}

- (void)swipeOutInDirection:(KKPHobbySwipeDirection)direction
                   complete:(void(^)(KKPHobbyDraggableView *draggableView))block;
{
    if (self.isDragging) { //如果拖拽中。不可再执行动画
        return;
    }
    
    CGPoint finishPoint;
    CGFloat rotate;
    switch (direction) {
        case KKPHobbySwipeDirectionRight:
        {
            finishPoint =  CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 2, self.center.y);
            rotate = M_PI_4;
            break;
        }
        case KKPHobbySwipeDirectionLeft:
        {
            finishPoint =  CGPointMake( - CGRectGetWidth([UIScreen mainScreen].bounds) * 2, self.center.y);
            rotate = - M_PI_4;
            break;
        }
        default:
        {
            break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(draggabelView:willSwippedOutInDirection:)]) {
        [self.delegate draggabelView:self willSwippedOutInDirection:direction];
    }
    [UIView animateWithDuration:kDraggableResetAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(rotate);
                         return;
                     } completion:^(BOOL finished) {
                         if (block) {
                             block(self);
                         }
                         [self removeFromSuperview];
                         if ([self.delegate respondsToSelector:@selector(draggabelView:didSwippedOutInDirection:)]) {
                             [self.delegate draggabelView:self didSwippedOutInDirection:direction];
                         }
                         return;
                     }];
}

- (void)swipBackToOriginalStateFromDirection:(KKPHobbySwipeDirection)direction
{
    [self swipeBackFromDirection:direction];
}

#pragma mark - lifeCirecle & override

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self generateProperty];
        [self addGestureRecognizerForCard];
        
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.customView.frame = self.bounds;
    self.maskViewForFont.frame = self.bounds;
}

#pragma mark - privateMethod

- (void)generateProperty
{
    self.actionFlagMargin = defaultActionFlagMargin;
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.originalLocation = self.center;
    self.isDragging = NO;
    self.customView = [[UIView alloc] init];
    [self addSubview:self.customView];
}

- (void)addGestureRecognizerForCard
{
    [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(panGestureRecognized:)]];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(tapGestureRecognized:)]];
}


#pragma mark - getter & setter

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.originalLocation = self.center;
    if (self.actionFlagMargin <= 0) {
        self.actionFlagMargin = defaultActionFlagMargin;
    }
}


- (void)setFront:(BOOL)Front
{
    _Front = Front;
    self.userInteractionEnabled = _Front;
}


- (void)setMaskViewForFont:(UIView *)maskViewForFont
{
    [_maskViewForFont removeFromSuperview];
    _maskViewForFont = maskViewForFont;
    _maskViewForFont.frame = self.customView.bounds;
    _maskViewForFont.alpha = 0;
    _maskViewForFont.hidden = NO;
    [self.customView addSubview:_maskViewForFont];
}

#pragma mark - GestureHandler

- (void)tapGestureRecognized:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.clickBlock) {
            self.clickBlock(self);
        }
        if ([self.delegate respondsToSelector:@selector(draggabelViewTapped:)]) {
            [self.delegate draggabelViewTapped:self];
        }
    }
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)pan
{
    self.xDistanceFromCenter = [pan translationInView:self].x;
    self.yDistanceFromCenter = [pan translationInView:self].y;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.layer.shouldRasterize = YES;
            [UIView animateWithDuration:.1 animations:^{
            }];  //强行结束当前动画
            
           //            self.originalLocation = self.center;
            self.tempCenter = self.center;
            self.animationDirection = 1.0;
            
            self.isDragging = YES;
            
        
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat tempX = self.xDistanceFromCenter + self.tempCenter.x - self.originalLocation.x;
            __unused CGFloat tempY = self.yDistanceFromCenter + self.tempCenter.y - self.originalLocation.y;
            CGFloat rotationStrength = MIN(tempX / self.frame.size.width, kRotationMax);
            CGFloat rotationAngle = self.animationDirection * kDefaultRotationAngle * rotationStrength;
            CGFloat scaleStrength = 1 - ((1 - kScaleMin) * fabs(rotationStrength));
            CGFloat scale = MAX(scaleStrength, kScaleMin);
            
            self.layer.rasterizationScale = scale * [UIScreen mainScreen].scale;
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngle);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            self.transform = scaleTransform;
            self.center = CGPointMake(self.tempCenter.x + self.xDistanceFromCenter,
                                      self.tempCenter.y + self.yDistanceFromCenter);
            
            if ([self.delegate respondsToSelector:@selector(draggabelView:draggedWithFinishPercent:)]) {
                
                CGFloat percent = self.xDistanceFromCenter * 100 / self.actionFlagMargin;
                [self.delegate draggabelView:self
                    draggedWithFinishPercent:percent];
            }
        
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            self.layer.shouldRasterize = NO;
            [self swipeAction];
            self.isDragging = NO;
        
            break;
        }
        default:
        {
            break;
        }
    }
}


#pragma mark - Swipe Animation

//拖动之后的补全。即飞走或者回到原处
- (void)swipeAction
{
    CGFloat percent = self.xDistanceFromCenter * 100 / self.actionFlagMargin;
    if (percent > 100) {
        [self rightAction];
    } else if (percent < -100) {
        [self leftAction];
    } else {
        [self resetViewToOriginalState];
    }
}

- (void)rightAction
{
    CGFloat finishY = self.originalLocation.y + self.yDistanceFromCenter;
    CGPoint finishPoint = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 2, finishY);
    if ([self.delegate respondsToSelector:@selector(draggabelView:willSwippedOutInDirection:)]) {
        [self.delegate draggabelView:self willSwippedOutInDirection:KKPHobbySwipeDirectionRight];
    }
    [UIView animateWithDuration:kDraggableSwipeActionAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
        self.center = finishPoint;
    } completion:^(BOOL finished) {
        self.isDragging = NO;
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(draggabelView:didSwippedOutInDirection:)]) {
            [self.delegate draggabelView:self didSwippedOutInDirection:KKPHobbySwipeDirectionRight];
        }
    }];
}

- (void)leftAction
{
    CGFloat finishY = self.originalLocation.y + self.yDistanceFromCenter;
    CGPoint finishPoint = CGPointMake(-CGRectGetWidth([UIScreen mainScreen].bounds), finishY);
    if ([self.delegate respondsToSelector:@selector(draggabelView:willSwippedOutInDirection:)]) {
        [self.delegate draggabelView:self willSwippedOutInDirection:KKPHobbySwipeDirectionLeft];
    }
    [UIView animateWithDuration:kDraggableSwipeActionAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
        self.center = finishPoint;
    } completion:^(BOOL finished) {
        self.isDragging = NO;
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(draggabelView:didSwippedOutInDirection:)]) {
            [self.delegate draggabelView:self didSwippedOutInDirection:KKPHobbySwipeDirectionLeft];
        }
    }];
}

- (void)resetViewToOriginalState
{

    if ([self.delegate respondsToSelector:@selector(draggabelViewWillReset:)]) {
        [self.delegate draggabelViewWillReset:self];
    }

    UIViewAnimationOptions option = UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction;
    
    [UIView animateWithDuration:kDraggableResetAnimationDuration delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:2
                        options:option
                     animations:^{
        self.transform = CGAffineTransformMakeRotation(0);
        self.center = self.originalLocation;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
        if ([self.delegate respondsToSelector:@selector(draggabelViewDidReset:)]) {
            [self.delegate draggabelViewDidReset:self];
        }
    }];
}

- (void)swipeBackFromDirection:(KKPHobbySwipeDirection)direction
{
    CGPoint fromPoint;
    CGFloat rotate;
    switch (direction) {
        case KKPHobbySwipeDirectionRight:
        {
            fromPoint =  CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) * 2, self.center.y);
            rotate = M_PI_4;
            break;
        }
        case KKPHobbySwipeDirectionLeft:
        {
            fromPoint =  CGPointMake( - CGRectGetWidth([UIScreen mainScreen].bounds) * 2, self.center.y);
            rotate = - M_PI_4;
            break;
        }
        default:
        {
            break;
        }
    }
    self.center = fromPoint;
    self.transform = CGAffineTransformMakeRotation(rotate);
    
    

    
    
    [UIView animateWithDuration:kDraggableSwipeActionAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = self.originalLocation;
                         self.transform = CGAffineTransformMakeRotation(0);
                         return;
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(draggabelView:DidSwipeBackFromDirection:)]) {
                             [self.delegate draggabelView:self DidSwipeBackFromDirection:direction];
                         }
                         return;
                     }];

}

@end
