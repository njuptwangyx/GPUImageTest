# GPUImageTest
My test learned from [简书](http://www.jianshu.com/nb/4268718) and [GitHub](https://github.com/loyinglin/GPUImage).

```
 28 #import "GPUImageBrightnessFilter.h"                //亮度
 29 #import "GPUImageExposureFilter.h"                  //曝光
 30 #import "GPUImageContrastFilter.h"                  //对比度
 31 #import "GPUImageSaturationFilter.h"                //饱和度
 32 #import "GPUImageGammaFilter.h"                     //伽马线
 33 #import "GPUImageColorInvertFilter.h"               //反色
 34 #import "GPUImageSepiaFilter.h"                     //褐色（怀旧）
 35 #import "GPUImageLevelsFilter.h"                    //色阶
 36 #import "GPUImageGrayscaleFilter.h"                 //灰度
 37 #import "GPUImageHistogramFilter.h"                 //色彩直方图，显示在图片上
 38 #import "GPUImageHistogramGenerator.h"              //色彩直方图
 39 #import "GPUImageRGBFilter.h"                       //RGB
 40 #import "GPUImageToneCurveFilter.h"                 //色调曲线
 41 #import "GPUImageMonochromeFilter.h"                //单色
 42 #import "GPUImageOpacityFilter.h"                   //不透明度
 43 #import "GPUImageHighlightShadowFilter.h"           //提亮阴影
 44 #import "GPUImageFalseColorFilter.h"                //色彩替换（替换亮部和暗部色彩）
 45 #import "GPUImageHueFilter.h"                       //色度
 46 #import "GPUImageChromaKeyFilter.h"                 //色度键
 47 #import "GPUImageWhiteBalanceFilter.h"              //白平横
 48 #import "GPUImageAverageColor.h"                    //像素平均色值
 49 #import "GPUImageSolidColorGenerator.h"             //纯色
 50 #import "GPUImageLuminosity.h"                      //亮度平均
 51 #import "GPUImageAverageLuminanceThresholdFilter.h" //像素色值亮度平均，图像黑白（有类似漫画效果）
 52 
 53 #import "GPUImageLookupFilter.h"                    //lookup 色彩调整
 54 #import "GPUImageAmatorkaFilter.h"                  //Amatorka lookup
 55 #import "GPUImageMissEtikateFilter.h"               //MissEtikate lookup
 56 #import "GPUImageSoftEleganceFilter.h"              //SoftElegance lookup

 61 #pragma mark - 图像处理 Handle Image
 62 
 63 #import "GPUImageCrosshairGenerator.h"              //十字
 64 #import "GPUImageLineGenerator.h"                   //线条
 65 
 66 #import "GPUImageTransformFilter.h"                 //形状变化
 67 #import "GPUImageCropFilter.h"                      //剪裁
 68 #import "GPUImageSharpenFilter.h"                   //锐化
 69 #import "GPUImageUnsharpMaskFilter.h"               //反遮罩锐化
 70 
 71 #import "GPUImageFastBlurFilter.h"                  //模糊
 72 #import "GPUImageGaussianBlurFilter.h"              //高斯模糊
 73 #import "GPUImageGaussianSelectiveBlurFilter.h"     //高斯模糊，选择部分清晰
 74 #import "GPUImageBoxBlurFilter.h"                   //盒状模糊
 75 #import "GPUImageTiltShiftFilter.h"                 //条纹模糊，中间清晰，上下两端模糊
 76 #import "GPUImageMedianFilter.h"                    //中间值，有种稍微模糊边缘的效果
 77 #import "GPUImageBilateralFilter.h"                 //双边模糊
 78 #import "GPUImageErosionFilter.h"                   //侵蚀边缘模糊，变黑白
 79 #import "GPUImageRGBErosionFilter.h"                //RGB侵蚀边缘模糊，有色彩
 80 #import "GPUImageDilationFilter.h"                  //扩展边缘模糊，变黑白
 81 #import "GPUImageRGBDilationFilter.h"               //RGB扩展边缘模糊，有色彩
 82 #import "GPUImageOpeningFilter.h"                   //黑白色调模糊
 83 #import "GPUImageRGBOpeningFilter.h"                //彩色模糊
 84 #import "GPUImageClosingFilter.h"                   //黑白色调模糊，暗色会被提亮
 85 #import "GPUImageRGBClosingFilter.h"                //彩色模糊，暗色会被提亮
 86 #import "GPUImageLanczosResamplingFilter.h"         //Lanczos重取样，模糊效果
 87 #import "GPUImageNonMaximumSuppressionFilter.h"     //非最大抑制，只显示亮度最高的像素，其他为黑
 88 #import "GPUImageThresholdedNonMaximumSuppressionFilter.h" //与上相比，像素丢失更多
 89 
 90 #import "GPUImageSobelEdgeDetectionFilter.h"        //Sobel边缘检测算法(白边，黑内容，有点漫画的反色效果)
 91 #import "GPUImageCannyEdgeDetectionFilter.h"        //Canny边缘检测算法（比上更强烈的黑白对比度）
 92 #import "GPUImageThresholdEdgeDetectionFilter.h"    //阈值边缘检测（效果与上差别不大）
 93 #import "GPUImagePrewittEdgeDetectionFilter.h"      //普瑞维特(Prewitt)边缘检测(效果与Sobel差不多，貌似更平滑)
 94 #import "GPUImageXYDerivativeFilter.h"              //XYDerivative边缘检测，画面以蓝色为主，绿色为边缘，带彩色
 95 #import "GPUImageHarrisCornerDetectionFilter.h"     //Harris角点检测，会有绿色小十字显示在图片角点处
 96 #import "GPUImageNobleCornerDetectionFilter.h"      //Noble角点检测，检测点更多
 97 #import "GPUImageShiTomasiFeatureDetectionFilter.h" //ShiTomasi角点检测，与上差别不大
 98 #import "GPUImageMotionDetector.h"                  //动作检测
 99 #import "GPUImageHoughTransformLineDetector.h"      //线条检测
100 #import "GPUImageParallelCoordinateLineTransformFilter.h" //平行线检测
101 
102 #import "GPUImageLocalBinaryPatternFilter.h"        //图像黑白化，并有大量噪点
103 
104 #import "GPUImageLowPassFilter.h"                   //用于图像加亮
105 #import "GPUImageHighPassFilter.h"                  //图像低于某值时显示为黑
106 
107 
108 #pragma mark - 视觉效果 Visual Effect
109 
110 #import "GPUImageSketchFilter.h"                    //素描
111 #import "GPUImageThresholdSketchFilter.h"           //阀值素描，形成有噪点的素描
112 #import "GPUImageToonFilter.h"                      //卡通效果（黑色粗线描边）
113 #import "GPUImageSmoothToonFilter.h"                //相比上面的效果更细腻，上面是粗旷的画风
114 #import "GPUImageKuwaharaFilter.h"                  //桑原(Kuwahara)滤波,水粉画的模糊效果；处理时间比较长，慎用
115 
116 #import "GPUImageMosaicFilter.h"                    //黑白马赛克
117 #import "GPUImagePixellateFilter.h"                 //像素化
118 #import "GPUImagePolarPixellateFilter.h"            //同心圆像素化
119 #import "GPUImageCrosshatchFilter.h"                //交叉线阴影，形成黑白网状画面
120 #import "GPUImageColorPackingFilter.h"              //色彩丢失，模糊（类似监控摄像效果）
121 
122 #import "GPUImageVignetteFilter.h"                  //晕影，形成黑色圆形边缘，突出中间图像的效果
123 #import "GPUImageSwirlFilter.h"                     //漩涡，中间形成卷曲的画面
124 #import "GPUImageBulgeDistortionFilter.h"           //凸起失真，鱼眼效果
125 #import "GPUImagePinchDistortionFilter.h"           //收缩失真，凹面镜
126 #import "GPUImageStretchDistortionFilter.h"         //伸展失真，哈哈镜
127 #import "GPUImageGlassSphereFilter.h"               //水晶球效果
128 #import "GPUImageSphereRefractionFilter.h"          //球形折射，图形倒立
129     
130 #import "GPUImagePosterizeFilter.h"                 //色调分离，形成噪点效果
131 #import "GPUImageCGAColorspaceFilter.h"             //CGA色彩滤镜，形成黑、浅蓝、紫色块的画面
132 #import "GPUImagePerlinNoiseFilter.h"               //柏林噪点，花边噪点
133 #import "GPUImage3x3ConvolutionFilter.h"            //3x3卷积，高亮大色块变黑，加亮边缘、线条等
134 #import "GPUImageEmbossFilter.h"                    //浮雕效果，带有点3d的感觉
135 #import "GPUImagePolkaDotFilter.h"                  //像素圆点花样
136 #import "GPUImageHalftoneFilter.h"                  //点染,图像黑白化，由黑点构成原图的大致图形
137 
138 
139 #pragma mark - 混合模式 Blend
140 
141 #import "GPUImageMultiplyBlendFilter.h"             //通常用于创建阴影和深度效果
142 #import "GPUImageNormalBlendFilter.h"               //正常
143 #import "GPUImageAlphaBlendFilter.h"                //透明混合,通常用于在背景上应用前景的透明度
144 #import "GPUImageDissolveBlendFilter.h"             //溶解
145 #import "GPUImageOverlayBlendFilter.h"              //叠加,通常用于创建阴影效果
146 #import "GPUImageDarkenBlendFilter.h"               //加深混合,通常用于重叠类型
147 #import "GPUImageLightenBlendFilter.h"              //减淡混合,通常用于重叠类型
148 #import "GPUImageSourceOverBlendFilter.h"           //源混合
149 #import "GPUImageColorBurnBlendFilter.h"            //色彩加深混合
150 #import "GPUImageColorDodgeBlendFilter.h"           //色彩减淡混合
151 #import "GPUImageScreenBlendFilter.h"               //屏幕包裹,通常用于创建亮点和镜头眩光
152 #import "GPUImageExclusionBlendFilter.h"            //排除混合
153 #import "GPUImageDifferenceBlendFilter.h"           //差异混合,通常用于创建更多变动的颜色
154 #import "GPUImageSubtractBlendFilter.h"             //差值混合,通常用于创建两个图像之间的动画变暗模糊效果
155 #import "GPUImageHardLightBlendFilter.h"            //强光混合,通常用于创建阴影效果
156 #import "GPUImageSoftLightBlendFilter.h"            //柔光混合
157 #import "GPUImageChromaKeyBlendFilter.h"            //色度键混合
158 #import "GPUImageMaskFilter.h"                      //遮罩混合
159 #import "GPUImageHazeFilter.h"                      //朦胧加暗
160 #import "GPUImageLuminanceThresholdFilter.h"        //亮度阈
161 #import "GPUImageAdaptiveThresholdFilter.h"         //自适应阈值
162 #import "GPUImageAddBlendFilter.h"                  //通常用于创建两个图像之间的动画变亮模糊效果
163 #import "GPUImageDivideBlendFilter.h"               //通常用于创建两个图像之间的动画变暗模糊效果
164 
165 
166 #pragma mark - 尚不清楚
167 #import "GPUImageJFAVoroniFilter.h"
168 #import "GPUImageVoroniConsumerFilter.h"
```