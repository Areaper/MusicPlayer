
#import "PlayMusicVC.h"
#import "UIImageView+WebCache.h"
#import "LrcModel.h"
#import "MusicAudioManager.h"
#import "MusicManager.h"
#import <AVFoundation/AVFoundation.h>
#define kScreenHeight self.view.bounds.size.height
#define kScreenWidth self.view.bounds.size.width

@interface PlayMusicVC ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, MusicAudioManagerDelegate>

@property (nonatomic, strong) NSMutableArray *setBtnArray; // 存放设置的button

@property (nonatomic, strong) UIImageView *backImageView; // 背景图片
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIVisualEffectView *blurView; // 毛玻璃
@property (nonatomic, strong) UIButton *backButton; // 后退button
@property (nonatomic, strong) UIImageView *rotateImage; // 旋转的image
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, strong) UITableView *lrcTV; // 歌词TV
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *singerLabel;
@property (nonatomic, strong) UISlider *timeSlider; // 进度条
@property (nonatomic, strong) UIButton *lastSongBtn;
@property (nonatomic, strong) UIButton *playBtn; // 播放按钮
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UISlider *soundSlider; // 声音大小slider

@property (nonatomic, strong) NSMutableArray *lrcArr; // 存放每条歌词的数组


@end

@implementation PlayMusicVC

#pragma mark - life circle



- (void)viewDidLoad {
    [super viewDidLoad];
    // 把VC设置成单例的代理
    [MusicAudioManager shareManager].delegate = self;
    
    [self drawUI];
    // 利用NSTimer 旋转
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotateAnimation) userInfo:nil repeats:YES];
    
    // 更新数据
    [self reloadData];
    
    // 音乐播放
    [self musicPlay];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - delegate method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageController.currentPage = (scrollView.contentOffset.x + kScreenWidth / 2) / kScreenWidth;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LrcModel *lm = [LrcModel shareLRC];
    return [lm returnLrcAmont];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hehe"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hehe"];
    }
    LrcModel *lm = [LrcModel shareLRC];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [lm returnLrcWithNumber:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    cell.selectedBackgroundView = [UIView new];
    return cell;
}
#pragma mark - MusicAudioManagerDelegate
-(void)audioPlayWithProgress:(float)progress
{
    self.timeSlider.value = progress;
    self.rotateImage.transform = CGAffineTransformRotate(self.rotateImage.transform, M_PI / 360);
}


#pragma mark - private method
- (void)drawUI
{
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.blurView];
    [self.view addSubview:self.backButton];
    [self.scrollView addSubview:self.rotateImage];
    [self.view addSubview:self.pageController];
    [self.scrollView addSubview:self.lrcTV];
    [self.blurView addSubview:self.leftTimeLabel];
    [self.blurView addSubview:self.rightTimeLabel];
    [self.blurView addSubview:self.titleLabel];
    [self.blurView addSubview:self.singerLabel];
    [self.view addSubview:self.timeSlider];
    [self.blurView addSubview:self.lastSongBtn];
    [self.blurView addSubview:self.playBtn];
    [self.blurView addSubview:self.nextBtn];
    [self.blurView addSubview:self.soundSlider];
    NSArray *normalPicname = @[@"loop", @"shuffle", @"singleloop", @"music"];
    float space = (kScreenWidth - 40 - 25 * 4) / 3;
    for (int i = 0; i < 4; i++) {
        UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        setBtn.backgroundColor = [UIColor clearColor];
        [setBtn setImage:[[UIImage imageNamed:normalPicname[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        NSString *highName = [NSString stringWithFormat:@"%@-s", normalPicname[i]];
        [setBtn setImage:[[UIImage imageNamed:highName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        setBtn.frame = CGRectMake(20 + 25 * i + space * i, kScreenHeight - 45, 25, 25);
        [setBtn addTarget:self action:@selector(SetBtnTapHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:setBtn];
        [self.setBtnArray addObject:setBtn];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}
// 旋转动画
//- (void)rotateAnimation
//{
//    self.rotateImage.transform = CGAffineTransformRotate(self.rotateImage.transform, M_PI / 360);
//}
// 计时器 控制时间label  时间slider
- (void)timerAction
{
    NSInteger secondT = [[MusicAudioManager shareManager] returnCurrentTime];
    NSInteger currenT = (NSInteger)(secondT + 0.5);
    NSInteger minute = currenT / 60;
    NSInteger second = currenT % 60;
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%ld:%ld", minute, second];
    
    NSInteger musicDuration = [self.music.duration integerValue];
    if (!(musicDuration == 0 && secondT == 0)) {
        NSInteger leftT = (NSInteger)(musicDuration - secondT + 0.5) / 1000;
        NSInteger leftMinute = leftT / 60;
        NSInteger leftSecond = leftT % 60;
        self.rightTimeLabel.text = [NSString stringWithFormat:@"-%ld:%ld", leftMinute, leftSecond];
    }
    
//    self.timeSlider.value = secondT;
    
    LrcModel *lm = [LrcModel shareLRC];
    NSInteger row = [lm returnNumberWithCurrentTime:secondT];
    if (row) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.lrcTV selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
}
// 刷新歌词单例中的数组
- (void)reloadData
{
    LrcModel *lm = [LrcModel shareLRC];
    [lm parserWithString:self.music.lyric];
    
    // 使用单例类 加载音乐播放器
    
    MusicManager *mm = [MusicManager shareManager];
    self.music = [mm returnModelWithIndexpath:self.currentIndex];
    
    // 使用单例类 加载音乐播放器
    // 每次传进来不一样的时候在去重新音频
    if (![[MusicAudioManager shareManager] isplayCurrentAudioWithURL:self.music.mp3Url]) {
        [[MusicAudioManager shareManager] setMusicAudioWithMusicUrl:self.music.mp3Url];
    }
    
}
// 音乐播放方法
- (void)musicPlay
{
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [path stringByAppendingPathComponent:@"songs"];
//    
//    NSString *songPath = [filePath stringByAppendingFormat:@"/%@.mp3", self.music.name];
//    NSData *data = [NSData dataWithContentsOfFile:songPath];
//    if (data) {
//    }
//    
//    NSURL *mp3Url = [NSURL URLWithString:self.music.mp3Url];
//    dispatch_queue_t concurrent = dispatch_queue_create("downloadMusic", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(concurrent, ^{
//        NSData *musicData = [NSData dataWithContentsOfURL:mp3Url];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.player = [[AVAudioPlayer alloc] initWithData:musicData error:nil];
//            [self.player play];
//        });
//        
//    });
}

#pragma mark - event response
- (void)pageControlValueChange
{
    self.scrollView.contentOffset = CGPointMake(kScreenWidth * self.pageController.currentPage, 0);
}
- (void)backButtonTapHandle:(UIButton *)button
{
//    [self.player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)SetBtnTapHandle:(UIButton *)button
{
    for (UIButton *btn in _setBtnArray) {
        btn.selected = NO;
    }
    button.selected = YES;
    button.tintColor = [UIColor clearColor]; // 默认背景色是蓝色, 改成透明的
}
// 播放暂停点击事件
- (void)playBtnTapHandle:(UIButton *)button
{
    MusicAudioManager *mam = [MusicAudioManager shareManager];
    
    if (mam.isPlaying == YES) {
        [mam pause];
        [button setImage:[[UIImage imageNamed:@"play"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"play-h"] forState:UIControlStateHighlighted];
    }
    else
    {
        [mam play];
        [button setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"pause-h"] forState:UIControlStateHighlighted];
    }
}
- (void)forwardBtnTapHandle:(UIButton *)button
{
    self.currentIndex--;
    if (self.currentIndex < 0) {
        self.currentIndex = [[MusicManager shareManager] returnModelNumber] - 1;
    }
    [self reloadData];
}
- (void)nextBtnTapHandle:(UIButton *)button
{
    self.currentIndex++;
    if (self.currentIndex > [[MusicManager shareManager] returnModelNumber] - 1) {
        self.currentIndex = 0;
    }
    [self reloadData];
}
// SoundSlider响应方法
- (void)soundSliderValueChangeHandle:(UISlider *)soundSlider
{
    [[MusicAudioManager shareManager] setVolume:soundSlider.value];
    
}
// timeSlider响应方法
- (void)timeSliderValueChangeHandle:(UISlider *)timeSlider
{
    MusicAudioManager *mam = [MusicAudioManager shareManager];
    [mam pause];
    [mam seekToTimePlay:timeSlider.value];
    [mam play];
}

#pragma mark - setter and getter
- (UIImageView *)backImageView
{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        NSURL *blurPicUrl = [NSURL URLWithString:self.music.blurPicUrl];
        [_backImageView sd_setImageWithURL:blurPicUrl];
    }
    return _backImageView;
}
- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight / 9 * 4)];
        _scrollView.contentSize = CGSizeMake(kScreenWidth * 2, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}
- (UIVisualEffectView *)blurView
{
    if (_blurView == nil) {
        _blurView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, kScreenHeight / 9 * 4, kScreenWidth, kScreenHeight / 9 * 5)];
        _blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    return _blurView;
}
- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _backButton.frame = CGRectMake(20, 20, 30, 30);
        [_backButton setImage:[UIImage imageNamed:@"arrowdown"] forState:UIControlStateNormal];
        _backButton.layer.cornerRadius = 30 / 2;
        _backButton.backgroundColor = [UIColor whiteColor];
        _backButton.tintColor = [UIColor blackColor];
        [_backButton addTarget:self action:@selector(backButtonTapHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
- (UIImageView *)rotateImage
{
    if (_rotateImage == nil) {
        _rotateImage = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - (kScreenHeight / 9 * 4 - 80)) / 2, 40, kScreenHeight / 9 * 4 - 80, kScreenHeight / 9 * 4 - 80)];
        NSURL *rotateImageUrl = [NSURL URLWithString:self.music.picUrl];
        [_rotateImage sd_setImageWithURL:rotateImageUrl];
        _rotateImage.backgroundColor = [UIColor redColor];
        _rotateImage.layer.cornerRadius = (kScreenHeight / 9 * 4 - 80) / 2;
        _rotateImage.clipsToBounds = YES;
        _rotateImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _rotateImage.layer.borderWidth = 1.5;
    }
    return _rotateImage;
}

- (UIPageControl *)pageController
{
    if (_pageController == nil) {
        _pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kScreenHeight / 9 * 4 - 30, kScreenWidth, 25)];
        _pageController.numberOfPages = 2;
        _pageController.currentPage = 0;
        _pageController.backgroundColor = [UIColor clearColor];
        [_pageController addTarget:self action:@selector(pageControlValueChange) forControlEvents:UIControlEventValueChanged];
    }
    return _pageController;
}
- (UITableView *)lrcTV
{
    if (_lrcTV == nil) {
        _lrcTV = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth, 50, kScreenWidth, kScreenHeight / 9 * 4 - 50) style:UITableViewStylePlain];
        _lrcTV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _lrcTV.backgroundColor = [UIColor clearColor];
        _lrcTV.delegate = self;
        _lrcTV.dataSource = self;
        
    }
    return _lrcTV;
}
- (UILabel *)leftTimeLabel
{
    if (_leftTimeLabel == nil) {
        _leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 70, 20)];
        _leftTimeLabel.backgroundColor = [UIColor clearColor];
        _leftTimeLabel.text = @"0:0";
        _leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        _leftTimeLabel.textColor = [UIColor blackColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _leftTimeLabel;
}
- (UILabel *)rightTimeLabel
{
    if (_rightTimeLabel == nil) {
        _rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 70, 30, 70, 20)];
        _rightTimeLabel.backgroundColor = [UIColor clearColor];
        _rightTimeLabel.textAlignment = NSTextAlignmentCenter;
        _rightTimeLabel.textColor = [UIColor blackColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:12];
    }
    NSInteger time = [self.music.duration intValue];
    
    
    
    NSInteger leftT = time / 1000;
    NSInteger leftMinute = leftT / 60;
    NSInteger leftSecond = leftT % 60;
    _rightTimeLabel.text = [NSString stringWithFormat:@"-%ld:%ld", leftMinute, leftSecond];
    
    return _rightTimeLabel;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 160) / 2 , 70, 160, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = self.music.name;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}
- (UILabel *)singerLabel
{
    if (_singerLabel == nil) {
        _singerLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 130) / 2, 110, 130, 30)];
        _singerLabel.text = self.music.singer;
        _singerLabel.textAlignment = NSTextAlignmentCenter;
        _singerLabel.textColor = [UIColor grayColor];
        _singerLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return _singerLabel;
}

- (UISlider *)timeSlider
{
    if (_timeSlider == nil) {
        _timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, kScreenHeight / 9 * 4 - 10, kScreenWidth, 20)];
        _timeSlider.backgroundColor = [UIColor clearColor];
        _timeSlider.maximumValue = [self.music.duration floatValue] / 1000;
        [_timeSlider setThumbImage:[UIImage imageNamed:@"thumb@2x.png"] forState:UIControlStateNormal];
        _timeSlider.minimumTrackTintColor = [UIColor redColor];
        _timeSlider.value = 0;
        [_timeSlider addTarget:self action:@selector(timeSliderValueChangeHandle:) forControlEvents:UIControlEventValueChanged];
    }
    return _timeSlider;
}
- (UIButton *)lastSongBtn
{
    if (_lastSongBtn == nil) {
        _lastSongBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _lastSongBtn.frame = CGRectMake(45, 150, 30, 20);
        _lastSongBtn.backgroundColor = [UIColor clearColor];
        [_lastSongBtn setImage:[[UIImage imageNamed:@"rewind.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_lastSongBtn addTarget:self action:@selector(forwardBtnTapHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastSongBtn;
}
- (UIButton *)playBtn
{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _playBtn.frame = CGRectMake((kScreenWidth - 20) / 2 , 150, 20, 20);
        [_playBtn setImage:[[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playBtnTapHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
- (UIButton *)nextBtn
{
    if (_nextBtn == nil) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _nextBtn.frame = CGRectMake(kScreenWidth - 75, 150, 30, 20);
        [_nextBtn setImage:[[UIImage imageNamed:@"forward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextBtnTapHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}
- (UISlider *)soundSlider
{
    if (_soundSlider == nil) {
        _soundSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 190, kScreenWidth - 60, 10)];
        _soundSlider.backgroundColor = [UIColor clearColor];
        [_soundSlider setThumbImage:[UIImage imageNamed:@"volumn_slider_thumb@2x"] forState:UIControlStateNormal];
        _soundSlider.minimumTrackTintColor = [UIColor blackColor];
        _soundSlider.maximumTrackTintColor = [UIColor blackColor];
        _soundSlider.maximumValueImage = [UIImage imageNamed:@"volumehigh@2x"];
        _soundSlider.minimumValueImage = [UIImage imageNamed:@"volumelow@2x"];
        
        _soundSlider.maximumValue = 1;
        _soundSlider.minimumValue = 0;
        [_soundSlider addTarget:self action:@selector(soundSliderValueChangeHandle:) forControlEvents:UIControlEventValueChanged];
        _soundSlider.value = 0.5;
        [self soundSliderValueChangeHandle:_soundSlider];
    }
    return _soundSlider;
}
- (NSMutableArray *)setBtnArray
{
    if (_setBtnArray == nil) {
        _setBtnArray = [NSMutableArray array];
    }
    return _setBtnArray;
}




@end
