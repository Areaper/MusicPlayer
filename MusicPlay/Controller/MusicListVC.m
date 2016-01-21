//
//  MusicListVC.m
//  MusicPlay
//
//  Created by lanou on 1/21/16.
//  Copyright © 2016 Leon. All rights reserved.
//

#import "MusicListVC.h"
#import "MusicCell.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "MusicModel.h"
#import "UIImageView+WebCache.h"

@interface MusicListVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *musicArr;

@end

@implementation MusicListVC

- (NSMutableArray *)musicArr
{
    if (!_musicArr) {
        _musicArr = [NSMutableArray array];
    }
    return _musicArr;
}

#pragma mark - lifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音乐播放器";
    
    
    
    // 设置背景图片
    self.backImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    backImage.image = [UIImage imageNamed:@"1"];
    
    // visual 光学的 视觉的
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithFrame:self.view.bounds];
    
    // blur模糊的
    visualView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    [self.backImageView addSubview:visualView];
    
    
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIButton *customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBtn setImage:[UIImage imageNamed:@"music-s"] forState:UIControlStateNormal];
    [customBtn setImage:[UIImage imageNamed:@"music-s"] forState:UIControlStateHighlighted];
    [customBtn addTarget:self action:@selector(RightBtnTapHandle) forControlEvents:UIControlEventTouchUpInside];
    customBtn.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundView = self.backImageView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 下面这句话的作用: 当有导航的时候 00 点 顶着导航 2.没有导航的时候是顶着屏幕的00点
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.automaticallyAdjustsScrollViewInsets = YES;
    
    
    // 不要横线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 或者
//    self.tableView.tableFooterView = [UIView new];
    
    // 注册
    [self.tableView registerClass:[MusicCell class] forCellReuseIdentifier:@"reuse"];
    
    NSLog(@"isnet______%d", [self isnetWork]);
    if ([self isnetWork]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:self.view.bounds];
        hud.labelText = @"正在加载数据";
        [hud show:YES];
        [self.view addSubview:hud];
        [hud hide:YES afterDelay:3];
        NSArray *arr = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:@"http://project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist"]];
        
        
        
        for (int i = 0; i < arr.count; i++) {
            MusicModel *model = [MusicModel modelWithDic:arr[i]];
            [self.musicArr addObject:model];
        }
        NSLog(@"self.modelArray.count____%ld", self.musicArr.count);
        
        [self.backImageView sd_setImageWithURL:[NSURL URLWithString:[self.musicArr[0] blurPicUrl]]];
        
        
       
        [hud hide:YES];
        
    }
    else
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:self.view.bounds];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"网络状况不好, 请检查网络";
        [hud show:YES];
        [self.view addSubview:hud];
        [hud hide:YES afterDelay:2];
        
    }
    
    
    
    
}

#pragma mark - TapHandle
- (void)RightBtnTapHandle
{
    
    
    
}

#pragma mark - dataSource  TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.musicArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    [cell cellWithModel:_musicArr[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - netWork
- (BOOL)isnetWork
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    BOOL isnetwork;
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            NSLog(@"没网络");
            isnetwork = NO;
            break;
        case ReachableViaWiFi:
//            NSLog(@"");
            
            isnetwork = YES;
            break;
        case ReachableViaWWAN:
//            NSLog(@"没网络");
            
            isnetwork = YES;
            break;
            
        default:
            break;
    }
    return isnetwork;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:[self.musicArr[indexPath.row] blurPicUrl]]];
//    MusicCell *cell = 
    
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end