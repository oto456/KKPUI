//
//  KKPHobbyDraggableDelegate.h
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/23.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KKPHobbySwipeDirection) {
    KKPHobbySwipeDirectionNone = 0,
    KKPHobbySwipeDirectionLeft,
    KKPHobbySwipeDirectionRight
};

@class KKPHobbyDraggableView;

@protocol KKPHobbyDraggableDelegate <NSObject>

@optional

- (void)draggabelView:(KKPHobbyDraggableView *)view draggedWithFinishPercent:(CGFloat)percent;
- (void)draggabelView:(KKPHobbyDraggableView *)view willSwippedOutInDirection:(KKPHobbySwipeDirection)direction;
- (void)draggabelView:(KKPHobbyDraggableView *)view didSwippedOutInDirection:(KKPHobbySwipeDirection)direction;
- (void)draggabelViewWillReset:(KKPHobbyDraggableView *)view;
- (void)draggabelViewDidReset:(KKPHobbyDraggableView *)view;
- (void)draggabelViewTapped:(KKPHobbyDraggableView *)view;
- (void)draggabelView:(KKPHobbyDraggableView *)view DidSwipeBackFromDirection:(KKPHobbySwipeDirection)direction;

@end
