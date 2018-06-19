//
//  ViewController.m
//  SWSAlertView
//
//  Created by 施文松 on 2018/6/19.
//  Copyright © 2018年 施文松. All rights reserved.
//

#import "ViewController.h"
#import "SWSAlertView.h"

/**
 获取颜色
 @param rgbValue 0x999999
 @return UIColor
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define white_Color UIColorFromRGB(0xffffff) // 白色
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define sws_randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256)) //随机色
@interface ViewController ()
- (IBAction)buttonOnClick:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = sws_randomColor;
	
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
	
	[self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (IBAction)buttonOnClick:(UIButton *)sender {
	[[SWSAlertView shareInstance] sws_showInView:self.navigationController.view withTitle:@"温馨提示！" withMessage:@"今天在下雨，记得带伞！" withCancelButtonTitle:@"取消" otherButtonTitles:@"好的" withComplete:^(NSInteger type) {
		NSLog(@"点击回调");
	}];
}
@end
