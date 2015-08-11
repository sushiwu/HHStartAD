//
//  HHStartAD.h
//  HHStartAD_Demo
//
//  Created by hxy on 15/8/9.
//  Copyright (c) 2015年 huangdong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HHADModel;

typedef void(^TouchADBlock)();
typedef void(^TouchADModelBlock)(HHADModel * model);
typedef void(^PassBlock)();

#pragma mark - 广告对象
@interface HHADModel : NSObject<NSCoding>
//广告ID
@property (nonatomic,assign) NSInteger adid;
//倒计时秒数
@property (nonatomic,assign) NSInteger duration;
//开始时间
@property (nonatomic,copy) NSString * start_date;
//结束时间
@property (nonatomic,copy) NSString * end_date;
//图片地址
@property (nonatomic,copy) NSString * imgurl;
//广告类型
@property (nonatomic,assign) NSInteger adtype;
//目标url
@property (nonatomic,copy) NSString * targeturl;
//广告是否可用
@property (nonatomic,assign) BOOL available;
//图片
@property (nonatomic,strong) UIImage * image;

@end

#pragma mark - 跳过按钮
@interface HHPassButton : UIControl
//显示"跳过"
@property (nonatomic,strong) UILabel * passLabel;
//显示秒数
@property (nonatomic,strong) UILabel * secondsLabel;
//倒计时
@property (nonatomic,assign) NSInteger duration;

@end

#pragma mark - 广告View
@interface HHADView : UIImageView
//跳过按钮，其实基类是UIControl
@property (nonatomic,strong) HHPassButton * passButton;
//点击跳过出发的block
@property (nonatomic,copy) PassBlock passBlock;
//点击广告触发的block，不带model
@property (nonatomic,copy) TouchADBlock touchADBlock;
//倒计时
@property (nonatomic,assign) NSInteger duration;

@end


@interface HHStartAD : NSObject
//显示的图片
@property (nonatomic,strong) UIImage * image;
//点击广告触发的block，带model
@property (nonatomic,copy) TouchADModelBlock touchADModelBlock;
//单例
+ (id)sharedInstance;

- (void)getStartWithTouchBlock:(TouchADModelBlock)block;


@end
