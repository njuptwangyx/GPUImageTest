//
//  ViewController.m
//  GPUImageTest
//
//  Created by wangyuxiang on 2017/4/24.
//  Copyright © 2017年 wangyuxiang. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "GPUImageBeautifyFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>

// strong/weak transform macro; learn from Reactive cocoa.
#ifndef weakify_self
#if __has_feature(objc_arc)
#define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
#else
#define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
#endif
#endif

#ifndef strongify_self
#if __has_feature(objc_arc)
#define strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
#else
#define strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
#endif
#endif


@interface ViewController ()

@property (nonatomic, assign) int testMode;

@property (nonatomic, copy) NSString *moviePath;
@property (nonatomic, strong) NSURL *movieURL;


/********************/
@property (nonatomic, strong) GPUImageSepiaFilter *sepiaFilter;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) GPUImageTiltShiftFilter *tiltShiftFilter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *mTimer;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) GPUImageMovie *movieFile;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.moviePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    self.movieURL = [NSURL fileURLWithPath:self.moviePath isDirectory:NO];
    
    _testMode = 7;
    
    switch (_testMode) {
        case 1: [self test1]; break;
        case 2: [self test2]; break;
        case 3: [self test3]; break;
        case 4: [self test4]; break;
        case 5: [self test5]; break;
        case 6: [self test6]; break;
        case 7: [self test7]; break;
            
        default: break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"didReceiveMemoryWarning");
}

//test1: 给图片加上滤镜
- (void)test1 {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    
    self.sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    UIImage *image = [UIImage imageNamed:@"testimage"];
    imageView.image = [self.sepiaFilter imageByFilteringImage:image];
}


//test2: 给相机加上滤镜
- (void)test2 {
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:imageView];
    
    //GPUImageVideoCamera要写成全局变量，让self持有。如果是局部变量，方法走完可能被释放了，相机就显示不出来了。
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    GPUImageSepiaFilter *filter = nil;
    filter = [[GPUImageSepiaFilter alloc] init];
    [filter addTarget:imageView];
    
    if (filter) {
        [self.videoCamera addTarget:filter];
    } else {
        [self.videoCamera addTarget:imageView];
    }
    
    [self.videoCamera startCameraCapture];
}


//test3: 录制视频，添加美颜滤镜，保存到相册
- (void)test3 {
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:imageView];
    
    unlink([self.moviePath UTF8String]);//unlink函数:删除文件
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(720, 1280)];
    self.movieWriter.encodingLiveVideo = YES;
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.videoCamera startCameraCapture];
    
    GPUImageBeautifyFilter *filter = nil;
    filter = [[GPUImageBeautifyFilter alloc] init];
    if (filter) {
        [self.videoCamera addTarget:filter];
        [filter addTarget:imageView];
        [filter addTarget:self.movieWriter];
    } else {
        [self.videoCamera addTarget:imageView];
        [self.videoCamera addTarget:self.movieWriter];
    }
    
    [self.movieWriter startRecording];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [filter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
        [self saveMovieToLibrary];
    });
}


//test4: 条纹模糊，中间清晰，上下模糊的效果。根据touch实时改变模糊位置。
- (void)test4 {
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.view = primaryView;
    
    self.tiltShiftFilter = [[GPUImageTiltShiftFilter alloc] init];
    self.tiltShiftFilter.blurRadiusInPixels = 40.0;
    [self.tiltShiftFilter forceProcessingAtSize:primaryView.sizeInPixels];
    [self.tiltShiftFilter addTarget:primaryView];
    
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"testimage"]];
    [self.sourcePicture addTarget:self.tiltShiftFilter];
    [self.sourcePicture processImage];

    // GPUImageContext相关的数据显示 
    GLint size = [GPUImageContext maximumTextureSizeForThisDevice];
    GLint unit = [GPUImageContext maximumTextureUnitsForThisDevice];
    GLint vector = [GPUImageContext maximumVaryingVectorsForThisDevice];
    NSLog(@"%d %d %d", size, unit, vector);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_testMode == 4) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        float rate = point.y / self.view.frame.size.height;
        [self.tiltShiftFilter setTopFocusLevel:rate - 0.1];
        [self.tiltShiftFilter setBottomFocusLevel:rate + 0.1];
        [self.sourcePicture processImage];
    }
}


//test5: 可以手动开始、停止录制视频，实时改变滤镜效果
- (void)test5 {
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, self.view.frame.size.height - 100, 100, 100)];
    [button setTitle:@"录制" forState:UIControlStateNormal];
    [button setTitle:@"停止" forState:UIControlStateSelected];
    [button addTarget:self action:@selector(test5_pressButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100 - 20, 20, 100, 30)];
    self.timeLabel.font = [UIFont systemFontOfSize:30];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.hidden = YES;
    self.timeLabel.text = @"0";
    [self.view addSubview:self.timeLabel];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.videoCamera startCameraCapture];
    
    self.sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    [self.sepiaFilter addTarget:imageView];
    [self.videoCamera addTarget:self.sepiaFilter];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 20, self.timeLabel.frame.origin.x - 30 , 30)];
    slider.value = 1;
    [slider addTarget:self action:@selector(test5_sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(test5_displayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)test5_pressButton:(UIButton *)button {
    
    if (button.selected) {
        //停止录制
        [self.movieWriter finishRecording];
        self.videoCamera.audioEncodingTarget = nil;
        [self.sepiaFilter removeTarget:self.movieWriter];
        self.movieWriter = nil;
        
        self.timeLabel.hidden = YES;
        self.timeLabel.text = @"0";
        if (_mTimer) {
            [_mTimer invalidate];
            _mTimer = nil;
        }
        [self saveMovieToLibrary];
    } else {
        //开始录制
        //把上一次文件删除，要不然writer会报错
        unlink([self.moviePath UTF8String]);
        
        //每次录新视频都要创建新的witer对象，参考AVAssetWriter文档
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(720, 1280)];
        self.movieWriter.encodingLiveVideo = YES;
        self.videoCamera.audioEncodingTarget = self.movieWriter;
        [self.sepiaFilter addTarget:self.movieWriter];
        [self.movieWriter startRecording];
        
        self.timeLabel.hidden = NO;
        self.mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            self.timeLabel.text = [NSString stringWithFormat:@"%d", ([self.timeLabel.text intValue] + 1)];
        }];
    }
    button.selected = !button.selected;
}

- (void)test5_sliderChanged:(UISlider *)slider {
    [self.sepiaFilter setIntensity:slider.value];
}

- (void)test5_displayLink:(CADisplayLink *)displayLink {
    //NSLog(@"displayLink");
}


//test6:视频作为水印录像
- (void)test6 {
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:imageView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 30)];
    self.timeLabel.font = [UIFont systemFontOfSize:30];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.timeLabel];
    
    //摄像头
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.videoCamera.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    //视频文件
    self.movieFile = [[GPUImageMovie alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"testmovie" withExtension:@"mov"]];
    self.movieFile.runBenchmark = YES;
    self.movieFile.playAtActualSpeed = YES;
    
    //滤镜
    GPUImageDissolveBlendFilter *filter = [[GPUImageDissolveBlendFilter alloc] init];
    filter.mix = 0.5;
    
    //witer
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480, 640)];
    [self.movieWriter setAudioProcessingCallback:^(SInt16 **samplesRef, CMItemCount numSamplesInBuffer) {
        
    }];
    
    BOOL audioFromFile = NO;
    if (audioFromFile) {
        //响应连
        [self.movieFile addTarget:filter];
        [self.videoCamera addTarget:filter];
        
        self.movieWriter.shouldPassthroughAudio = YES;//是否使用源音源
        self.movieFile.audioEncodingTarget = self.movieWriter;
        [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    } else {
        //响应连
        [self.videoCamera addTarget:filter];
        [self.movieFile addTarget:filter];
        
        self.movieWriter.shouldPassthroughAudio = NO;
        self.videoCamera.audioEncodingTarget = self.movieWriter;//音频来源是文件
        self.movieWriter.encodingLiveVideo = NO;
    }
    
    //显示到界面
    [filter addTarget:imageView];
    [filter addTarget:self.movieWriter];
    
    unlink([self.moviePath UTF8String]);
    
    [self.videoCamera startCameraCapture];
    [self.movieFile startProcessing];
    [self.movieWriter startRecording];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(test6_updateProgress:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = NO;
    
    @weakify_self;
    self.movieWriter.completionBlock = ^() {
        @strongify_self;
        NSLog(@"writer complete!");
        [self.displayLink invalidate];
        [filter removeTarget:self.movieWriter];
        //TODO:这一步会卡住，暂时没找到原因
        [self.movieWriter finishRecording];
        [self.movieFile endProcessing];
        
        [self saveMovieToLibrary];
    };
}

- (void)test6_updateProgress:(CADisplayLink *)displayLink {
    self.timeLabel.text = [NSString stringWithFormat:@"progress:%d%%", (int)(self.movieFile.progress * 100)];
}


//test7:
- (void)test7 {
    GPUImageView *imageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    imageView.fillMode = kGPUImageFillModeStretch;
    [self.view addSubview:imageView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 30)];
    self.timeLabel.font = [UIFont systemFontOfSize:30];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.timeLabel];
    
    //视频文件
    self.movieFile = [[GPUImageMovie alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"testmovie" withExtension:@"mov"]];
    self.movieFile.runBenchmark = YES;
    self.movieFile.playAtActualSpeed = YES;
    
    //滤镜
    GPUImageDissolveBlendFilter *filter = [[GPUImageDissolveBlendFilter alloc] init];
    filter.mix = 0.5;
    
    //witer
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480, 640)];
    
    //水印
    UILabel *watermarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    watermarkLabel.text = @"我是水印";
    watermarkLabel.font = [UIFont systemFontOfSize:30];
    watermarkLabel.textColor = [UIColor redColor];
    [watermarkLabel sizeToFit];
    
    UIImageView *watermarkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"watermark"]];
    //watermarkImage.center = self.view.center;
    UIView *subView = [[UIView alloc] initWithFrame:self.view.bounds];
    subView.backgroundColor = [UIColor clearColor];
    [subView addSubview:watermarkLabel];
    [subView addSubview:watermarkImage];
    
    //把UIView对象转换成纹理对象
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    
    GPUImageFilter *processFilter = [[GPUImageFilter alloc] init];
    [self.movieFile addTarget:processFilter];
    [processFilter addTarget:filter];
    [uielement addTarget:filter];
    
    self.movieWriter.shouldPassthroughAudio = YES;
    self.movieFile.audioEncodingTarget = self.movieWriter;
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    
    //显示到界面
    [filter addTarget:imageView];
    [filter addTarget:self.movieWriter];
    
    unlink([self.moviePath UTF8String]);
    
    [self.movieWriter startRecording];
    [self.movieFile startProcessing];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(test6_updateProgress:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = NO;
    
    [processFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        CGRect frame = watermarkImage.frame;
        frame.origin.x += 5;
        frame.origin.y += 5;
        if (frame.origin.x > self.view.frame.size.width) {
            frame.origin.x = 0;
        }
        if (frame.origin.y > self.view.frame.size.height) {
            frame.origin.y = 0;
        }
        watermarkImage.frame = frame;
        [uielement updateWithTimestamp:time];
    }];
    
    @weakify_self;
    self.movieWriter.completionBlock = ^() {
        @strongify_self;
        NSLog(@"writer complete!");
        [self.displayLink invalidate];
        [filter removeTarget:self.movieWriter];
        [self.movieWriter finishRecording];
        [self.movieFile endProcessing];
        
        [self saveMovieToLibrary];
    };
}


//保存视频到相册
- (void)saveMovieToLibrary {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.moviePath)) {
        [library writeVideoAtPathToSavedPhotosAlbum:self.movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"movie saved fail" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"movie saved successfully" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            });
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"movie saved fail" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
