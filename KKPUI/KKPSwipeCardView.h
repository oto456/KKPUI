//
//  KKPSwipeCardView.h
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/24.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPHobbyDraggableView.h"


@protocol KKPSwipeViewDelegate, KKPSwipeViewDataSource;

@interface KKPSwipeCardView : UIView

@property (nonatomic, strong) UIView *maskViewForFont;

@property (nonatomic, assign) NSInteger visableCount;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, weak) id<KKPSwipeViewDelegate> delegate;
@property (nonatomic, weak) id<KKPSwipeViewDataSource> dataSource;

/**
 *  第一张往左飞走。并且removefromsuperView
 */
- (void)swipeFrontViewToLeft;

/**
 *  第一张往右飞走。并且removefromsuperView
 */
- (void)swipeFrontViewToRight;

/**
 *  重新加载数据
 */
- (void)reloadData;

/**
 *  撤销
 */
- (void)revoke;

/**
 *  用法和tableview的一样
 *
 *  @param identifier 重用标识
 *
 *  @return return value description
 */
- (KKPHobbyDraggableView *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

/**
 *  给对应的重用标示注册Class
 *
 *  @param aClass     class
 *  @param identifier identifier description
 */
- (void)registerClass:(Class)aClass forCellReuseIdentifier:(NSString *)identifier;

@end


@protocol KKPSwipeViewDataSource <NSObject>

@required

/**
 *  卡片View的数目。总数
 *
 *  @param swipeView swipeView description
 *
 *  @return 数目
 */
- (NSUInteger)numberOfDraggabelCards:(KKPSwipeCardView *)swipeView;

/**
 *  要放在卡片上的自定义View
 *
 *  @param swipeView swipeView description
 *  @param index     index description
 *
 *  @return return value description
 */
- (KKPHobbyDraggableView *)swipeView:(KKPSwipeCardView *)swipeView
              draggableViewForIndex:(NSUInteger)index;

@end

@protocol KKPSwipeViewDelegate <NSObject>

@optional

/**
 *  点击了第一张view。
 *
 *  @param swipeView     swipeView description
 *  @param draggableView draggableView description
 *  @param index         点击的卡片属于data中的第几个
 */
- (void)swipeView:(KKPSwipeCardView *)swipeView didSelectFontCard:(KKPHobbyDraggableView *)draggableView index:(NSInteger)index;

/**
 *  滑动时会调用的回调方法。自己去通过percent的正负去判断方向。负为左。正为右
 *
 *  @param swipeView     载体swipeView
 *  @param draggableView 在拖动的draggableView
 *  @param percent       当到了超过了100就是要飞走了。用正负判断方向
 */
- (void)swipeView:(KKPSwipeCardView *)swipeView draggableView:(KKPHobbyDraggableView *)draggableView draggedWithFinishPercent:(CGFloat)percent;

/**
 *  第一张卡片将要飞走
 *
 *  @param swipeView swipeView description
 *  @param view      view description
 *  @param direction 方向
 */
- (void)swipeView:(KKPSwipeCardView *)swipeView draggabelView:(KKPHobbyDraggableView *)view willSwippedOutInDirection:(KKPHobbySwipeDirection)direction;

/**
 *  第一张卡片飞走了
 *
 *  @param swipeView swipeView description
 *  @param view      view description
 *  @param direction direction description
 */
- (void)swipeView:(KKPSwipeCardView *)swipeView draggabelView:(KKPHobbyDraggableView *)view didSwippedOutInDirection:(KKPHobbySwipeDirection)direction;

/**
 *  第一张即将返回原位置
 *
 *  @param swipeView swipeView description
 *  @param view      view description
 *  @param direction direction description
 */
- (void)swipeView:(KKPSwipeCardView *)swipeView willResetWithDraggabelView:(KKPHobbyDraggableView *)view;

/**
 *  第一张已经返回位置
 *
 *  @param swipeView swipeView description
 *  @param view      view description
 *  @param direction direction description
 */
- (void)swipeView:(KKPSwipeCardView *)swipeView didResetWithDraggabelView:(KKPHobbyDraggableView *)view;

@required

@end