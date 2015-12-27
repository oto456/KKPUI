//
//  KKPHobbyPersonalCard.h
//  hobbyDemo
//
//  Created by 刘特风 on 15/8/23.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPHobbyDraggableView.h"

FOUNDATION_EXTERN NSString * const kKKPHobbyPersonalCardName;
FOUNDATION_EXTERN NSString * const kKKPHobbyPersonalCardAvatar;
FOUNDATION_EXTERN NSString * const kKKPHobbyPersonalCardSummary;
FOUNDATION_EXTERN NSString * const kKKPHobbyPersonalCardGender;
FOUNDATION_EXTERN NSString * const kKKPHobbyPersonalCardBiggie;


FOUNDATION_EXTERN NSString * const kKKPHobbyPersonalCardCellIdentifier;

@interface KKPHobbyPersonalCard : KKPHobbyDraggableView;

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameTitle;
@property (nonatomic, strong) UILabel *labelSummary;
@property (nonatomic, strong) UIImageView *genderImgV;
@property (nonatomic, strong) UIImageView *biggieImgV;
@property (nonatomic, strong) id model;

- (void)configWithDic:(NSDictionary *)dic;

@end
