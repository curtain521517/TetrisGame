//
//  ViewController.m
//  tetrisGame
//
//  Created by xufan on 2017/3/17.
//  Copyright © 2017年 xufan. All rights reserved.
//

#import "ViewController.h"

#import "TetrisGameView.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TetrisGameView *tetrisGameView = [[TetrisGameView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:tetrisGameView];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
