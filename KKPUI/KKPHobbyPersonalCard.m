//
//  KKPHobbyPersonalCard.m
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/23.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//



#import "KKPHobbyPersonalCard.h"
#import "Masonry.h"
#import "FrameAccessor.h"
#import "EXTScope.h"

NSString * const kKKPHobbyPersonalCardName = @"kKKPHobbyPersonalCardName";
NSString * const kKKPHobbyPersonalCardAvatar  = @"kKKPHobbyPersonalCardAvatar";
NSString * const kKKPHobbyPersonalCardSummary = @"kKKPHobbyPersonalCardSummary";
NSString * const kKKPHobbyPersonalCardGender = @"kKKPHobbyPersonalCardGender";
NSString * const kKKPHobbyPersonalCardBiggie = @"kKKPHobbyPersonalCardBiggie";


NSString * const kKKPHobbyPersonalCardCellIdentifier = @"kKKPHobbyPersonalCardCellIdentifier";

static const CGFloat textContainerHeight = 80;

static const CGFloat ViewCornerRadius     = 5;

static const CGFloat AvatarSpaceToBottom  = 10;
static const CGFloat AvatarCornerRadius   = 3;
//static const CGFloat AvatarHeight         = 200;

static const CGFloat SummarySpaceToTop    = AvatarSpaceToBottom;
static const CGFloat SummarySpaceToLeft   = 12;
static const CGFloat SummarySpaceToRight  = 12;

#define SummaryFont [UIFont systemFontOfSize:12]



@interface KKPHobbyPersonalCard ()

@property (nonatomic, assign) BOOL isIphone4or4S;
@property (nonatomic, strong) UIView *textContainer;
@property (nonatomic, strong) CALayer *shadowLayer;
@property (nonatomic, strong) UIView *maskLoading;
@property (nonatomic, strong) UIActivityIndicatorView *indcator;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) NSDictionary *configDic;

@end

@implementation KKPHobbyPersonalCard

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configUI];
//        [self forTest];
        [self addShadowLayer];
    }
    return self;
}

- (void)forTest
{
    self.avatar.image = [UIImage imageNamed:@"ico_个人默认头像"];
    self.nameTitle.text = @"了解该离开家";
    self.labelSummary.text = @"哈哈哈这个知识一个以阿斯科";
    self.genderImgV.image = [UIImage imageNamed:@"3_1引导_03"];
    self.genderImgV.image = [UIImage imageNamed:@"3_2引导_03"];
}

- (void)configUI
{
    self.customView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.customView.layer.cornerRadius = ViewCornerRadius;
    self.customView.clipsToBounds = YES;
    self.customView.layer.borderWidth = 0.5;
    self.customView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.textContainer = [[UIView alloc] init];
    self.textContainer.backgroundColor = [UIColor whiteColor];
   
    
    self.avatar = [[UIImageView alloc] init];
    self.avatar.layer.cornerRadius = AvatarCornerRadius;
    self.avatar.clipsToBounds = YES;
    self.avatar.image = [UIImage imageNamed:@"wallpaper"];
    [self.customView addSubview:self.avatar];
    
    self.nameTitle = [[UILabel alloc] init];
    self.nameTitle.font = [UIFont systemFontOfSize:16.];
    [self.textContainer addSubview:self.nameTitle];
    
    self.labelSummary = [[UILabel alloc] init];
    self.labelSummary.font = SummaryFont;
    self.labelSummary.numberOfLines = 2;
    self.labelSummary.textAlignment = NSTextAlignmentLeft;
    [self.textContainer addSubview:self.labelSummary];
    
    self.nameTitle = [[UILabel alloc] init];
    self.nameTitle.font = [UIFont systemFontOfSize:16.];
    [self.textContainer addSubview:self.nameTitle];
    
    self.genderImgV = [[UIImageView alloc] init];
    [self.textContainer addSubview:self.genderImgV];

    self.biggieImgV = [[UIImageView alloc] init];
    [self.textContainer addSubview:self.biggieImgV];
    
    [self.customView addSubview:self.textContainer];
    
}

- (void)addShadowLayer
{
    self.layer.shadowOffset = CGSizeMake(0, 0); //设置阴影的偏移量
    self.layer.shadowRadius = 5.0;  //设置阴影的半径
    self.layer.shadowColor = [UIColor blackColor].CGColor; //设置阴影的颜色为黑色
    self.layer.shadowOpacity = 0.15; //设置阴影的不透明度
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat AvatarX = 0;
    CGFloat AvatarY = 0;
    CGFloat AvatarWidth = self.bounds.size.width;
    CGFloat AvatarHeight = self.bounds.size.width;
    self.avatar.frame = (CGRect){AvatarX, AvatarY, AvatarWidth, AvatarHeight};
    
    self.nameTitle.x = SummarySpaceToLeft;
    self.nameTitle.y = SummarySpaceToTop;
    [self.nameTitle sizeToFit];
    
    self.genderImgV.width = 15;
    self.genderImgV.height = 15;
    self.genderImgV.x = self.nameTitle.right + 5;
    self.genderImgV.y = self.nameTitle.y;
    
    self.biggieImgV.width = 15;
    self.biggieImgV.height = 15;
    self.biggieImgV.x = self.genderImgV.right + 5;
    self.biggieImgV.y = self.nameTitle.y;
    
    self.labelSummary.x = SummarySpaceToLeft;
    self.labelSummary.y = self.nameTitle.bottom + 5;
    self.labelSummary.width = self.width - SummarySpaceToLeft - SummarySpaceToRight;
    [self.labelSummary sizeToFit];
    
    
    if ([self isIphone4or4S]) {
        self.textContainer.x = 0;
        self.textContainer.y = 180;
        self.textContainer.width = self.customView.width;
        self.textContainer.height = textContainerHeight;
    }else {
        self.textContainer.x = 0;
        self.textContainer.y = self.avatar.bottom;
        self.textContainer.width = self.customView.width;
        self.textContainer.height = textContainerHeight;
    }
    
    self.maskLoading.frame = self.avatar.bounds;
    self.indcator.centerX = CGRectGetMidX(self.maskLoading.bounds);
    self.indcator.centerY = CGRectGetMidY(self.maskLoading.bounds);
    self.retryButton.center = self.indcator.center;
}


- (void)configWithDic:(NSDictionary *)dic
{
    self.configDic = dic;
    id avatar = dic[kKKPHobbyPersonalCardAvatar];
    self.nameTitle.text = dic[kKKPHobbyPersonalCardName];
    self.labelSummary.text = dic[kKKPHobbyPersonalCardSummary];
    id genderImg = dic[kKKPHobbyPersonalCardGender];
    if ([genderImg isKindOfClass:[UIImage class]]) {
        self.genderImgV.image = genderImg;
    }
    id biggieImg = dic[kKKPHobbyPersonalCardBiggie];
    if ([biggieImg isKindOfClass:[UIImage class]]) {
        self.biggieImgV.image = biggieImg;
    }else {
        self.biggieImgV.image = nil;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - getter & setter 
- (UIView *)maskLoading
{
    if (!_maskLoading) {
        _maskLoading = [[UIView alloc] init];
        self.indcator = [[UIActivityIndicatorView alloc] initWithFrame:(CGRect){0, 0, 35, 35}];
        self.indcator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.indcator startAnimating];
        [_maskLoading addSubview:self.indcator];
        self.retryButton = [[UIButton alloc] init];
        self.retryButton.width = 70;
        self.retryButton.height = 70;
        [self.retryButton setImage:[UIImage imageNamed:@"ico_faild_to_load"] forState:UIControlStateNormal];
        [self.retryButton addTarget:self action:@selector(retryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.retryButton.hidden = YES;
        [_maskLoading addSubview:self.retryButton];
        _maskLoading.hidden = YES;
        [self.avatar addSubview:_maskLoading];
        self.avatar.userInteractionEnabled = YES;
    }
    return _maskLoading;
}

#pragma mark - Helper

- (BOOL)isIphone4or4S
{
    CGFloat maxLenght = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    return maxLenght < 568.0;
}

#pragma mark - Action retryClick

- (void)retryBtnClick:(UIButton *)button
{
    self.retryButton.hidden = YES;
    if (self.configDic[kKKPHobbyPersonalCardAvatar]) {
        id avatar = self.configDic[kKKPHobbyPersonalCardAvatar];
    }
}


@end
