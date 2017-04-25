//
//  ViewController.m
//  GPUImageTest
//
//  Created by wangyuxiang on 2017/4/24.
//  Copyright © 2017年 wangyuxiang. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    int testMode = 2;
    
    
    if (testMode == 1) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:imageView];
        
        GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
        UIImage *image = [UIImage imageNamed:@"testimage"];
        imageView.image = [filter imageByFilteringImage:image];
    }
    

    if (testMode == 2) {
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
