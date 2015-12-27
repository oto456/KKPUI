//
//  ViewController.m
//  KKPUI
//
//  Created by 刘特风 on 15/12/27.
//  Copyright © 2015年 kakapo. All rights reserved.
//

#import "ViewController.h"
#import "KKPSwipeCardView.h"
#import "FrameAccessor.h"
#import "KKPHobbyPersonalCard.h"

@interface ViewController () <KKPSwipeViewDelegate, KKPSwipeViewDataSource>

@property (nonatomic, strong) KKPSwipeCardView *swipeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configSwipeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - draggable view

- (void)configSwipeView
{
    CGFloat swipeViewWidth = self.view.width * 0.8;
    CGFloat swipeVIewHeight = [self isIphone4or4S] ? 180+80 : swipeViewWidth + 80;
    
    self.swipeView = [[KKPSwipeCardView alloc] initWithFrame:CGRectMake(0,
                                                                       40 + 64,
                                                                       swipeViewWidth,
                                                                       swipeVIewHeight)];
    self.swipeView.centerX = self.view.centerX;
    [self.swipeView registerClass:[KKPHobbyPersonalCard class] forCellReuseIdentifier:kKKPHobbyPersonalCardCellIdentifier];
    
    self.swipeView.delegate = self;
    self.swipeView.dataSource = self;
    [self.view addSubview:self.swipeView];
}

- (BOOL)isIphone4or4S
{
    CGFloat maxLenght = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    return maxLenght < 568.0;
}

#pragma mark - SwipeViewDataSource

- (NSUInteger)numberOfDraggabelCards:(KKPSwipeCardView *)swipeView
{
    return 10;
}


- (KKPHobbyDraggableView *)swipeView:(KKPSwipeCardView *)swipeView
              draggableViewForIndex:(NSUInteger)index
{
    KKPHobbyPersonalCard *card = (KKPHobbyPersonalCard *)[self.swipeView dequeueReusableCellWithIdentifier:kKKPHobbyPersonalCardCellIdentifier];
    [card configWithDic:@{kKKPHobbyPersonalCardName : @"哈哈哈哈 funny",
                          kKKPHobbyPersonalCardAvatar : @"",
                          kKKPHobbyPersonalCardSummary : @"再要阿萨德拉斯加法拉克水煎服刻录机啊搜酷路附近阿斯利康积分卡拉是健康路附",
                          kKKPHobbyPersonalCardGender : @"",
                          kKKPHobbyPersonalCardBiggie : @""}];
    return card;
}


#pragma mark - SwipeView Delegate

- (void)swipeView:(KKPSwipeCardView *)swipeView didSelectFontCard:(KKPHobbyDraggableView *)draggableView index:(NSInteger)index
{
    NSLog(@"tap index : %@", @(index));
}


- (void)swipeView:(KKPSwipeCardView *)swipeView draggabelView:(KKPHobbyDraggableView *)view willSwippedOutInDirection:(KKPHobbySwipeDirection)direction
{
    
    
}

- (void)swipeView:(KKPSwipeCardView *)swipeView draggabelView:(KKPHobbyDraggableView *)view didSwippedOutInDirection:(KKPHobbySwipeDirection)direction
{
    
}

- (void)swipeView:(KKPSwipeCardView *)swipeView draggableView:(KKPHobbyDraggableView *)draggableView draggedWithFinishPercent:(CGFloat)percent
{
    
}

- (void)swipeView:(KKPSwipeCardView *)swipeView willResetWithDraggabelView:(KKPHobbyDraggableView *)view
{
    
}



@end
