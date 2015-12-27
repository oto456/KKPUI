//
//  KKPSwipeCardView.m
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/24.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import "KKPSwipeCardView.h"
#import <objc/runtime.h>

#define DraggableViewYoffSet   ([UIScreen mainScreen].bounds.size.width > 320 ? 15 : 10)
static const CGFloat DraggableScaleOffset       = 0.05;
static const CGFloat DefaultVisableCount        = 3;

static const NSTimeInterval MoveFrontDuration   = 0.2;
static const NSTimeInterval MoveFrontDelay      = 0.05;
static const CGFloat MoveFrontSpringWithDamping = 0.6;
static const CGFloat MoveFrontInitVelocity      = 2;

@interface KKPSwipeCardView () <KKPHobbyDraggableDelegate>

@property (nonatomic, assign) NSInteger totalViewNum;
@property (nonatomic, strong) NSMutableArray *visableDraggableViews;
@property (nonatomic, strong) KKPHobbyDraggableView *draggableViewForReUse;

//重用
@property (nonatomic, strong) NSMutableDictionary *reusableDraggableViews;

//纪录数据的去向。为了后面做撤销用的。
@property (nonatomic, strong) NSMutableDictionary *destinationForIndex;

//存放注册的class
@property (nonatomic, strong) NSMutableDictionary *classForIdentifier;
@property (nonatomic, strong) NSMutableDictionary *indentifierForClass;

//默认和SwipeCardView等高等宽
@property (nonatomic, assign) CGSize originalDraggableViewSize;

@end

@implementation KKPSwipeCardView

#pragma mark - public Method

- (void)swipeFrontViewToLeft
{

    if (self.visableDraggableViews.count > 0) {
        KKPHobbyDraggableView *temp = self.visableDraggableViews[0];
        [temp swipeOutInDirection:KKPHobbySwipeDirectionLeft];
    }
}

- (void)swipeFrontViewToRight
{
    if (self.visableDraggableViews.count > 0) {
        KKPHobbyDraggableView *temp = self.visableDraggableViews[0];
        [temp swipeOutInDirection:KKPHobbySwipeDirectionRight];
    }
}

- (void)reloadData
{
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self generateProperty];
    [self generatePropertyFromDataSource];
    [self configUI];
}

- (void)revoke
{
    NSNumber *direction = self.destinationForIndex[@(self.currentIndex-1).stringValue];
    if (direction) {
        KKPHobbyDraggableView *temp = self.visableDraggableViews.lastObject;
        [self.visableDraggableViews removeObject:temp];
        [temp swipBackToOriginalStateFromDirection:direction.integerValue];
        [self bringSubviewToFront:temp];
    }
}

- (void)registerClass:(Class)aClass forCellReuseIdentifier:(NSString *)identifier
{
    NSAssert(!self.dataSource, @"兄弟， 答应我。先registerClass 再设置datasource 好么?");
    self.classForIdentifier[identifier] = NSStringFromClass(aClass); //把这个类名字记录下来。
    self.indentifierForClass[NSStringFromClass(aClass)] = identifier;  //为了放进冲用池时使用。。为了不反向查找。。
}

- (KKPHobbyDraggableView *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    NSAssert(self.classForIdentifier, @"还没register别随便用这个方法啊。会返回空的啊 兄弟");
    
    KKPHobbyDraggableView *dragView = self.reusableDraggableViews[identifier];
    if (dragView) {
        return dragView;  //如果有的话直接返回
    }
    //下面是找不到时的操作.
    
    NSString *classString = self.classForIdentifier[identifier];
    Class aclass = NSClassFromString(classString);
    dragView = [[aclass alloc] init];
    
    return dragView;
}

#pragma mark - lifeCircle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.originalDraggableViewSize = frame.size;
        [self generateProperty];
        [self generateClassDic];
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    return self;
}


- (void)generateProperty
{
    self.draggableViewForReUse = [[KKPHobbyDraggableView alloc] init];
    self.currentIndex = 0;
    self.visableCount = DefaultVisableCount;
    self.visableDraggableViews = [[NSMutableArray alloc] initWithCapacity:self.visableCount];
    self.destinationForIndex = [[NSMutableDictionary alloc] init];
    self.reusableDraggableViews = [[NSMutableDictionary alloc] init];
}

- (void)generateClassDic
{
    self.indentifierForClass = [[NSMutableDictionary alloc] init];
    self.classForIdentifier = [[NSMutableDictionary alloc] init];
}


#pragma mark - about Getter&Setter

- (void)setDataSource:(id<KKPSwipeViewDataSource>)dataSource
{
    if (!dataSource) {
        return;
    }
    NSAssert(dataSource, @"DataSouce cant't be nil");
    _dataSource = dataSource;
    [self generatePropertyFromDataSource];
    [self configUI];
}


- (void)generatePropertyFromDataSource
{
    self.totalViewNum = [self.dataSource numberOfDraggabelCards:self];
    self.visableCount = MIN(self.visableCount, [self.dataSource numberOfDraggabelCards:self]);
    self.visableDraggableViews = [[NSMutableArray alloc] initWithCapacity:self.visableCount];
}

#pragma mark - PrivateMethod

- (void)configUI
{
    NSInteger dataIndex = self.currentIndex;
    for (NSInteger i = 0; i < self.visableCount; i++, dataIndex++) {
        KKPHobbyDraggableView *temp = [self.dataSource swipeView:self draggableViewForIndex:dataIndex];
        if(temp){
            temp.frame = (CGRect){0, 0, self.originalDraggableViewSize};

            if (0 == i) {
                temp.Front = YES;
                temp.maskViewForFont = self.maskViewForFont;
            }else{
                temp.Front = NO;
            }
            temp.delegate = self;
            [self layoutDraggableView:temp index:i];
            [self addSubview:temp];
            [self sendSubviewToBack:temp];
            [self.visableDraggableViews addObject:temp];
        }
    }
}

- (void)layoutDraggableView:(KKPHobbyDraggableView *)draggableView index:(NSInteger)index
{
    CGFloat draggableY = DraggableViewYoffSet * index;
    CGFloat scale = MAX(0.0, (1 - DraggableScaleOffset * index));
    draggableView.center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + draggableY};
    draggableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

#pragma mark - Animaiton

- (void)loadMoreDraggableView
{
    NSInteger index = self.currentIndex + 2;
    
    if (index < self.totalViewNum) {   //判断是否还有
        
        
        KKPHobbyDraggableView *temp = [self.dataSource swipeView:self draggableViewForIndex:index];
        temp.Front = NO;
        temp.alpha = 0;
        temp.delegate = self;          //别忘记设置delegate;
        [self addSubview:temp];
        [self sendSubviewToBack:temp];
        
        [self layoutDraggableView:temp index:self.visableCount];  //为了让这一张也有从下面升起来的感觉
        
        [self.visableDraggableViews addObject:temp];
    }
    
    for (NSInteger i = 0; i < self.visableDraggableViews.count; i++)
    {
        NSTimeInterval delay = MoveFrontDelay * i;     //添加一点延迟
        KKPHobbyDraggableView *temp = self.visableDraggableViews[i];
        if (0 == i) {
            temp.maskViewForFont = self.maskViewForFont;
        }
        [UIView animateWithDuration:MoveFrontDuration
                              delay:delay
             usingSpringWithDamping:MoveFrontSpringWithDamping
              initialSpringVelocity:MoveFrontInitVelocity
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                            temp.alpha = 1;
                            [self layoutDraggableView:temp index:i];
        } completion:^(BOOL finished) {
            if (0 == i) {
                temp.Front = YES;
                temp.maskViewForFont = self.maskViewForFont;
            }else{
                temp.Front = NO;
            }
        }];
    }
}

#pragma mark - positonTransform

//缓缓上升的效果这个没办法啦 只能传percent
- (void)layoutDraggableView:(KKPHobbyDraggableView *)draggableView index:(NSInteger)index percent:(CGFloat)percent
{
    CGFloat per = MIN(fabs(percent), 100);
    per = 100 - per;
    
    CGFloat temp = per / index ;
    temp = temp + (100 - 100 / index);
                   
    temp = temp / 100;
    //和前一张的距离
    
    CGFloat draggableY = DraggableViewYoffSet * index * temp ;
    CGFloat scale = MAX(0.0, 1 - DraggableScaleOffset * index * temp);
    draggableView.center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) + draggableY};
    draggableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

- (void)moveBehindDraggableViewWithPercent:(CGFloat)percent
{
    /**
     *  从第二张开始,
     */
    for (NSInteger i = 1; i < self.visableDraggableViews.count ; i ++) {
        KKPHobbyDraggableView *temp = self.visableDraggableViews[i];
        [self layoutDraggableView:temp index:i percent:percent];
    }
}



#pragma mark - KKPHobbyDraggableViewDelegate

- (void)draggabelViewTapped:(KKPHobbyDraggableView *)view
{
    if ([self.delegate respondsToSelector:@selector(swipeView:didSelectFontCard:index:)]) {
        [self.delegate swipeView:self didSelectFontCard:view index:self.currentIndex];
    }
}

- (void)draggabelView:(KKPHobbyDraggableView *)view draggedWithFinishPercent:(CGFloat)percent
{
    //第一张拖动的时候就有上移动效果
    [self moveBehindDraggableViewWithPercent:percent];
    
    if ([self.delegate respondsToSelector:@selector(swipeView:draggableView:draggedWithFinishPercent:)]) {
        [self.delegate swipeView:self draggableView:view draggedWithFinishPercent:percent];
    }
}

- (void)draggabelView:(KKPHobbyDraggableView *)view willSwippedOutInDirection:(KKPHobbySwipeDirection)direction
{
    if ([self.delegate respondsToSelector:@selector(swipeView:draggabelView:willSwippedOutInDirection:)]) {
        [self.delegate swipeView:self draggabelView:view willSwippedOutInDirection:direction];
    }
}

- (void)draggabelView:(KKPHobbyDraggableView *)view didSwippedOutInDirection:(KKPHobbySwipeDirection)direction
{
    //将这个index的去向纪录下来
    self.destinationForIndex[@(self.currentIndex).stringValue] = @(direction);
    [self addDraggableViewToReuse:view];
    
    [self.visableDraggableViews removeObjectAtIndex:0];
    self.currentIndex ++;          //飞走一张之后代理方法 记得currentIndex++;
    [self loadMoreDraggableView];
    if ([self.delegate respondsToSelector:@selector(swipeView:draggabelView:didSwippedOutInDirection:)]) {
        [self.delegate swipeView:self draggabelView:view didSwippedOutInDirection:direction];
    }
}

- (void)addDraggableViewToReuse:(KKPHobbyDraggableView *)draggableView
{
    Class aclass = [draggableView class];
    NSString *classString = NSStringFromClass(aclass);
    NSString *identifier = self.indentifierForClass[classString];
    self.reusableDraggableViews[identifier] = draggableView;
}

- (void)draggabelViewWillReset:(KKPHobbyDraggableView *)view
{
    [UIView animateWithDuration:0.1 animations:^{
        for (NSInteger i = 1; i < self.visableDraggableViews.count; i ++) {
            KKPHobbyDraggableView *temp = self.visableDraggableViews[i];
            [self layoutDraggableView:temp index:i];
        }
    }];
    if ([self.delegate respondsToSelector:@selector(swipeView:willResetWithDraggabelView:)]) {
        [self.delegate swipeView:self willResetWithDraggabelView:view];
    }
}

- (void)draggabelViewDidReset:(KKPHobbyDraggableView *)view
{
    if ([self.delegate respondsToSelector:@selector(swipeView:didResetWithDraggabelView:)]) {
        [self.delegate swipeView:self didResetWithDraggabelView:view];
    }
}

- (void)draggabelView:(KKPHobbyDraggableView *)view DidSwipeBackFromDirection:(KKPHobbySwipeDirection)direction
{
    self.currentIndex = MAX((self.currentIndex - 1), 0);
    [self.visableDraggableViews insertObject:view atIndex:0];
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:2
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
        for (NSInteger i = 0; i < self.visableDraggableViews.count; i++) {
            KKPHobbyDraggableView *temp = self.visableDraggableViews[i];
            if (0 == i) {
                temp.Front = YES;
            }else {
                temp.Front = NO;
            }
            [self layoutDraggableView:self.visableDraggableViews[i] index:i];
        }
    } completion:^(BOOL finished) {
    }];
    
    
}

@end
