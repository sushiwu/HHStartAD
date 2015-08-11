//
//  HHStartAD.m
//  HHStartAD_Demo
//
//  Created by hxy on 15/8/9.
//  Copyright (c) 2015年 huangdong. All rights reserved.
//

#import "HHStartAD.h"
#import <AFNetworking.h>
#import <Masonry.h>

@implementation HHADModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.adid forKey:@"adid"];
    [aCoder encodeInteger:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.start_date forKey:@"start_date"];
    [aCoder encodeObject:self.end_date forKey:@"end_date"];
    [aCoder encodeObject:self.imgurl forKey:@"imgurl"];
    [aCoder encodeInteger:self.adtype forKey:@"adtype"];
    [aCoder encodeObject:self.targeturl forKey:@"targeturl"];
    [aCoder encodeBool:self.available forKey:@"available"];
    [aCoder encodeObject:self.image forKey:@"image"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if(self){
        self.adid = [aDecoder decodeIntegerForKey:@"adid"];
        self.duration = [aDecoder decodeIntegerForKey:@"duration"];
        self.start_date = [aDecoder decodeObjectForKey:@"start_date"];
        self.end_date = [aDecoder decodeObjectForKey:@"end_date"];
        self.imgurl = [aDecoder decodeObjectForKey:@"imgurl"];
        self.adtype = [aDecoder decodeIntegerForKey:@"adtype"];
        self.targeturl = [aDecoder decodeObjectForKey:@"targeturl"];
        self.available = [aDecoder decodeBoolForKey:@"available"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
    }
    
    return self;
}

@end


@interface HHPassButton()

@end

@implementation HHPassButton

- (id)initWithDuration:(NSInteger)duration
{
    if (self = [super init]) {
        self.duration = duration;
        [self configUI];
        
    }
    return self;
}

- (void)configUI
{
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8f];
    
    self.passLabel = [[UILabel alloc] init];
    self.passLabel.textAlignment = NSTextAlignmentCenter;
    self.passLabel.textColor = [UIColor colorWithRed:64.0/255 green:64.0/255 blue:64.0/255 alpha:1];
    self.passLabel.font = [UIFont systemFontOfSize:12];
    self.passLabel.text = @"跳过";
    [self addSubview:self.passLabel];
    
    self.secondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    self.secondsLabel.textAlignment = NSTextAlignmentCenter;
    self.secondsLabel.textColor = [UIColor redColor];
    self.secondsLabel.font = [UIFont systemFontOfSize:12];
    self.secondsLabel.text = @"3s";
    if(self.duration){
        self.secondsLabel.text = [NSString stringWithFormat:@"%zds",self.duration];
    }
    [self addSubview:self.secondsLabel];
    
    [self setConstraints];
    
}



- (void)setConstraints
{
    [self.passLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(12);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.secondsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-9);
        make.centerX.mas_equalTo(self);
    }];
}


@end

@interface HHADView()

@property (nonatomic,strong) NSTimer * timer;

@end

@implementation HHADView
{
    NSInteger _count;
}

static CGFloat WIDTG = 50;

- (id)initWithFrame:(CGRect)frame andDuration:(NSInteger)duration
{
    if (self = [super initWithFrame:frame]) {
        self.duration = duration;
        _count = duration;
        [self configUI];
        [self startCountdown];
    }
    return self;
}

- (void)configUI
{
    self.userInteractionEnabled = YES;
    
    self.passButton = [[HHPassButton alloc] initWithDuration:self.duration];
    self.passButton.layer.cornerRadius = WIDTG/2;
    self.passButton.layer.masksToBounds = YES;
    self.passButton.layer.borderWidth = 5;
    self.passButton.layer.borderColor = [UIColor grayColor].CGColor;
    [self.passButton addTarget:self action:@selector(passButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.passButton];
    
    self.passButton.duration = self.duration;
    
    [self.passButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(WIDTG, WIDTG));
    }];
    
}

- (void)startCountdown
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownAction:) userInfo:nil repeats:YES];

}

- (void)countdownAction:(NSDictionary *)info
{
    self.passButton.secondsLabel.text = [NSString stringWithFormat:@"%zds",--_count];
    if (_count == 0) {
        [self passButtonClick:nil];
    }
}


- (void)passButtonClick:(UIControl *)control
{
    if (self.passBlock) {
        self.passBlock();
    }
    self.passBlock = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch end ");
    __weak __typeof(&*self) ws = self;
    if (self.touchADBlock) {
        self.touchADBlock();
        //广告页消失
        [ws passButtonClick:nil];
    }
}


@end


@interface HHStartAD()

@property (nonatomic,strong) HHADView * adView;

@property (nonatomic,copy) NSString * path;

@property (nonatomic,strong) HHADModel * model;

@end

@implementation HHStartAD


static NSString * START_AD_MODEL = @"START_AD_MODEL";
static NSString * START_IMG_DIC = @"START_IMG_DIC";
static NSString * IMG_EXIST = @"IMG_EXIST";


static HHStartAD * _startAD;

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _startAD = [[HHStartAD alloc] init];
    });
    return _startAD;
}

- (void)getStartWithTouchBlock:(TouchADModelBlock)block
{
    self.touchADModelBlock = [block copy];
    //1.检测资源
    [self checkResource];
    
    //网络请求
    [self requestAD];
}

//检查资源
- (void)checkResource
{
    //图片是否存在、防止下载网络不好的话，就当作图片不存在
    BOOL exist = [[NSUserDefaults standardUserDefaults] boolForKey:IMG_EXIST];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.path] || exist == NO){
        return;
    }
    self.model = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
    
    if (self.model != nil) {
        
        BOOL available = self.model.available;
        
        NSString * startDateStr = self.model.start_date;
        NSString * endDateStr = self.model.end_date;
        
        if (available == YES && exist == YES && [self isDateAvailableWithStart:startDateStr andEnd:endDateStr]) {
            [self showAD];
        }
    }
}

//请求广告数据
- (void)requestAD
{
    //建议该字典从服务器获取，由于我不会服务器，所以先这样弄着吧
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:@{@"adid":@(1523),                        //广告id
                                                                                @"duration":@(4),                       //持续时间
                                                                                @"start_date":@"2015-8-9 00:00",        //有效开始时间
                                                                                @"end_date":@"2015-8-13 00:00",         //有效结束时间
                                                                                @"imgurl":@"http://7xkzrw.com1.z0.glb.clouddn.com/prologue_2@2x.jpg",                 //图片地址，有prologue_0、prologue_1、prologue_2
                                                                                @"adtype":@(0),                         //广告类型
                                                                                @"targeturl":@"http://www.baidu.com",   //目标链接
                                                                                @"available":@(1)                       //广告是否可用
                                                                                }];
    
    
    //如果获得的adid一样，说明广告不需要更新
    if(self.model.adid == [dic[@"adid"] integerValue] && 1 == [dic[@"available"] integerValue]){
        return;
    }
    
    //下载图片，并保存广告对象
    NSString * imgUrlStr = dic[@"imgurl"];

    __weak __typeof(&*self) ws = self;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:imgUrlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        if (!error) {
            _image = [UIImage imageWithData:[NSData dataWithContentsOfURL:filePath]];
            [dic setObject:_image forKey:@"image"];
            
            HHADModel * model = [[HHADModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            [ws saveModel:model];
            
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IMG_EXIST];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    [downloadTask resume];
    
}

//展现广告
- (void)showAD
{
    //需要在info.plist文件里面加一个字段：View controller-based status bar appearance 并设置为NO
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self.adView];
}

//消失广告
- (void)disMissADView
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.adView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.adView removeFromSuperview];
        self.adView.alpha = 1;
    }];
}

//归档保存广告模型
- (void)saveModel:(HHADModel *)model
{
    NSData * modelData = [NSKeyedArchiver archivedDataWithRootObject:model];
    
    BOOL isSuccess = [modelData writeToFile:self.path atomically:YES];
    NSLog(@"%d",isSuccess);
    //
    [[NSUserDefaults standardUserDefaults] setBool:isSuccess forKey:IMG_EXIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//判断当前是否在有效时间内
- (BOOL)isDateAvailableWithStart:(NSString *)startStr andEnd:(NSString *)endStr
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate * startDate = [formatter dateFromString:startStr];
    NSDate * endDate = [formatter dateFromString:endStr];
    NSDate * date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    if ([[localeDate earlierDate:startDate] isEqualToDate:startDate] && [[localeDate laterDate:endDate] isEqualToDate:endDate]) {
        return YES;
    }
    return NO;
}


- (HHADView *)adView
{
    if (!_adView) {
        NSInteger duration = 0;
        if (_model) {
            duration = _model.duration;
        }
        __weak __typeof(&*self) ws = self;
        _adView = [[HHADView alloc] initWithFrame:[UIScreen mainScreen].bounds andDuration:duration];
        _adView.image = _model.image;
        _adView.passBlock = ^(){
            NSLog(@"pass!");
            [ws disMissADView];
        };
        _adView.touchADBlock = ^(){
            if (ws.touchADModelBlock) {
                ws.touchADModelBlock(ws.model);
            }
        };
    }
    return _adView;
}

- (NSString *)path
{
    if (!_path) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        // Now we get the full path to the file
        _path = [documentsDirectory stringByAppendingPathComponent:START_AD_MODEL];
    }
    return _path;
}



@end
