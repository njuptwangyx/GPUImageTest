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

@interface ViewController ()

@property (nonatomic, assign) int testMode;


@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@property (nonatomic, strong) GPUImageTiltShiftFilter *tiltShiftFilter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _testMode = 4;
    
    switch (_testMode) {
        case 1: [self test1]; break;
        case 2: [self test2]; break;
        case 3: [self test3]; break;
        case 4: [self test4]; break;
        
        default: break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//test1: 给图片加上滤镜
- (void)test1 {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    UIImage *image = [UIImage imageNamed:@"testimage"];
    imageView.image = [filter imageByFilteringImage:image];
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
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    NSString *moviePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([moviePath UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath isDirectory:NO];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720, 1280)];
    self.movieWriter.encodingLiveVideo = YES;
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
        
        //保存相册
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
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

@end
