//
//  GOInnerShadowLayer.h
//  EmitterDemo
//
//  Created by QinChuancheng on 2020/7/4.
//  Copyright © 2020 caohouhong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

//如果中间修改了属性  需要调用 setNeedsDisplay

@interface GOInnerShadowLayer : CALayer

/* 路径 */
@property (nonatomic, strong) UIBezierPath *go_shadowPath;
/* 颜色 */
@property (nonatomic, strong) UIColor *go_shadowColor;
/* 透明度 */
@property (nonatomic, assign) CGFloat go_shadowOpacity;
/* 半径（大小）*/
@property (nonatomic, assign) CGFloat go_shadowRadius;
/* 偏移 */
@property (nonatomic, assign) CGSize go_shadowOffset;


@end

