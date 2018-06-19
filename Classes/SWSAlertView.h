//
//  SWSAlertView.h
//  SWSAlertView
//
//  Created by 施文松 on 2018/3/1.
//  Copyright © 2018年 施文松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSAlertView : UIView

@property (strong, nonatomic) UIView *whiteView;
@property (strong, nonatomic) UIView *grayView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *canleButton;
@property (strong, nonatomic) UIButton *otherButton;
@property (strong, nonatomic) UITextField *inputTextField;

+ (SWSAlertView *)shareInstance;

//MARK: - 显示（普通弹框）
- (void)sws_showInView:(UIView *)superView
			 withTitle:(NSString *)titleString
		   withMessage:(NSString *)message
 withCancelButtonTitle:(NSString *)canleButtonTitle
	 otherButtonTitles:(NSString *)otherButtonTitle
		  withComplete:(void(^)(NSInteger type))complete;


//MARK: - 输入(弹出输入框)
- (void)sws_showInputInView:(UIView *)superView
				  withTitle:(NSString *)titleString
		   withKeyboardType:(UIKeyboardType)keyboardType
			withPlaceHolder:(NSString *)placeHolder
	  withCancelButtonTitle:(NSString *)canleButtonTitle
		  otherButtonTitles:(NSString *)otherButtonTitle
			   withComplete:(void(^)(NSInteger type, NSString *inputString))complete;

@end


@interface UIView (AlertExtension)

/**
 *  这个是我们封装好的获取响应者链的一个方法
 *
 *  @return 返回我们根据响应者链找到的ViewController
 */
- (UIViewController *)findViewContrller;

@end
