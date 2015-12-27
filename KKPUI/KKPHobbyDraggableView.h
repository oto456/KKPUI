//
//  KKPHobbyDraggableView.h
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/23.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPHobbyDraggableDelegate.h"

@class KKPHobbyDraggableView;
typedef void (^KKPHobbyDraggableSwipeOutToDirectionRightComBlock)(KKPHobbyDraggableView *draggableView);
typedef void (^KKPHobbyDraggableSwipeOutToDirectionLeftComBlock)(KKPHobbyDraggableView *draggableView);
typedef void (^KKPHobbyDraggableClickComBlock)(KKPHobbyDraggableView *draggableView);

@interface KKPHobbyDraggableView : UIView

@property (nonatomic, weak) id<KKPHobbyDraggableDelegate> delegate;
@property (nonatomic, readonly) UIView *customView;
@property (nonatomic, strong) UIView *maskViewForFont;
@property (nonatomic, copy) KKPHobbyDraggableSwipeOutToDirectionRightComBlock leftBlock;
@property (nonatomic, copy) KKPHobbyDraggableSwipeOutToDirectionLeftComBlock rightBlock;
@property (nonatomic, copy) KKPHobbyDraggableClickComBlock clickBlock;
@property (nonatomic, assign, getter = isFront) BOOL Front;
@property (nonatomic, assign) CGFloat actionFlagMargin;


- (void)swipeOutInDirection:(KKPHobbySwipeDirection)direction;
- (void)swipeOutInDirection:(KKPHobbySwipeDirection)direction
                   complete:(void(^)(KKPHobbyDraggableView *draggableView))block;

- (void)swipBackToOriginalStateFromDirection:(KKPHobbySwipeDirection)direction;

@end
