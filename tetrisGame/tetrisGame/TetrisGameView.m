//
//  TetrisGameView.m
//  tetrisGame
//
//  Created by xufan on 2017/3/17.
//  Copyright © 2017年 xufan. All rights reserved.
//

#import "TetrisGameView.h"

#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height

#define kBoardWide          12 //方块横向有12块
#define kBoardHigh          20 //方块竖向有20块

#define kBoxWidth (kScreenWidth/kBoardWide)   //方块的宽度
#define kBoxHeight (kScreenWidth/kBoardWide)  //一样宽
#define kOriginY (kScreenHeight-(kBoardHigh * kBoxHeight)) //方块顶格的高度pt


/**
 * 数据结构为1表示有方块占据，反之是空的
 **/
int gBoard[kBoardHigh + 1][kBoardWide + 2] = {0};

const int gXFBox[19][4][4]={
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0},       //0
    {0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0},       //1
    {2,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0},       //2
    {2,2,0,0,0,2,0,0,0,2,0,0,0,0,0,0},       //3
    {0,0,0,0,0,0,2,0,2,2,2,0,0,0,0,0},       //4
    {2,0,0,0,2,0,0,0,2,2,0,0,0,0,0,0},       //5
    {3,3,0,0,3,0,0,0,3,0,0,0,0,0,0,0},       //6
    {3,3,3,0,0,0,3,0,0,0,0,0,0,0,0,0},       //7
    {0,0,3,0,0,0,3,0,0,3,3,0,0,0,0,0},       //8
    {0,0,0,0,3,0,0,0,3,3,3,0,0,0,0,0},       //9
    {4,4,0,0,0,4,4,0,0,0,0,0,0,0,0,0},       //10
    {0,4,0,0,4,4,0,0,4,0,0,0,0,0,0,0},       //11
    {0,5,5,0,5,5,0,0,0,0,0,0,0,0,0,0},       //12
    {5,0,0,0,5,5,0,0,0,5,0,0,0,0,0,0},       //13
    {0,6,0,0,6,6,6,0,0,0,0,0,0,0,0,0},       //14
    {6,0,0,0,6,6,0,0,6,0,0,0,0,0,0,0},       //15
    {0,0,0,0,6,6,6,0,0,6,0,0,0,0,0,0},       //16
    {0,6,0,0,6,6,0,0,0,6,0,0,0,0,0,0},       //17
    {7,7,0,0,7,7,0,0,0,0,0,0,0,0,0,0}        //18
};



@interface TetrisGameView ()<UIAlertViewDelegate>

@property(nonatomic, assign) NSInteger score; //分数
@property(nonatomic, assign) NSInteger level; //级别
@property(nonatomic, assign) CGFloat speed;   //速度
@property(nonatomic, assign, getter=isGamaOver) BOOL gameOver; //游戏是否结束
@property(nonatomic, assign) NSInteger boxId; //方块id编号
@property(nonatomic, assign) CGPoint currentBoxPoint; //悬浮方块坐标基于4*4左上角位置
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation TetrisGameView

#pragma mark - getters/setters

- (BOOL)isGameOver
{
    return _gameOver;
}

- (void)setScore:(NSInteger)score
{
    _score = score;
    
    self.level = _score/100 + 1;
    NSString *scoreInfoString = [NSString stringWithFormat:@"分数:%ld",_score];
    [scoreInfoString drawAtPoint:CGPointMake(130, 20) withAttributes:nil];
}

- (void)setLevel:(NSInteger)level
{
    _level = level;
    
    _level = _level==0?1:_level;
    
    CGFloat speedArray[]={0.9,0.85,0.8,0.75,0.6,0.5};
    
    self.speed = _level <=6 ? speedArray[_level-1] : 0.4;
    
    NSString *levelInfoString = [NSString stringWithFormat:@"级别:%ld",_level];
    [levelInfoString drawAtPoint:CGPointMake(70, 20) withAttributes:nil];
    
}

- (void)setSpeed:(CGFloat)speed
{
    CGFloat oldSpeed = _speed;
    _speed = speed;
    
    if (_speed != oldSpeed) {
        [self startTimer];
    }
}


#pragma mark - 显示信息

- (void)showInfo
{
    NSString *scoreInfoString = [NSString stringWithFormat:@"分数:%ld",_score];
    [scoreInfoString drawAtPoint:CGPointMake(130, 30) withAttributes:nil];
    
    NSString *levelInfoString = [NSString stringWithFormat:@"级别:%ld",_level];
    [levelInfoString drawAtPoint:CGPointMake(70, 30) withAttributes:nil];
}

#pragma mark - init

- (void)initial
{
    _speed = 0.9;
    _score = 0;
    _gameOver = NO;
    _level = 1;

    int i,j;
    
    memset(gBoard, 0, sizeof(int)*14*21);
    
    //bottom set 1
    for(j = 0 ; j < kBoardWide + 2 ; j++)
         gBoard[kBoardHigh][j] = 1;
    
    //both side set 1
    for(i = 0 ; i < kBoardHigh + 1 ; i++)
    {
        gBoard[i][0] = 1;
        gBoard[i][kBoardWide + 1] = 1;
    }
    
    [self createTetris];
    
    [self startTimer];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self initial];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panGesture];
        
    }
    return self;
}

- (void)startTimer
{
    NSLog(@"startTimer:%0.3f",_speed);
    //先关掉，再打开，调节速度
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    __weak typeof(self) wkSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_speed repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        //游戏结束
        if ([wkSelf isGamaOver]) {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"游戏结束" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
            [timer invalidate];
            timer  = nil;
            
            return ;
        }
        
        //如果可以下落
        if ([wkSelf canDown]) {
            [wkSelf onDown];
            [wkSelf setNeedsDisplay];
        }
        //如果不可以，处理满行
        else {
            [wkSelf put];
        
            NSInteger s = [wkSelf dealFull];
            if (s > 0) {
                wkSelf.score +=s;
            }
            [wkSelf createTetris];
            
            //刚出来就不能下来了
            if (![wkSelf canDown]) {
                wkSelf.gameOver = YES;
            }
        }
    }];
}


/**
 * 产生新的方块
 */
- (void)createTetris
{
    _boxId = arc4random()%19;
    _currentBoxPoint = CGPointMake(kBoardWide / 2, 0);
    
    [self setNeedsDisplay];
}

#pragma mark - calculate

- (int ) valueForPoint:(CGPoint) pt
{
    //适当的校验
    if (pt.x < 0 || pt.x > kBoardWide + 1) {
        return 1;
    }
    if (pt.y < 0 || pt.y > kBoardHigh) {
        return 1;
    }
    return gBoard[(int)(pt.y)][(int)(pt.x)];
}

- (void) setValueForPoint:(CGPoint) pt
{
    gBoard[(int)(pt.y)][(int)(pt.x)] = 1;
}


- (BOOL)canLeft
{
    for (int i = 0 ; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if (gXFBox[_boxId][i][j] != 0) {
                CGPoint pt = CGPointMake(_currentBoxPoint.x + j + 1 - 1, _currentBoxPoint.y + i);
                if ([self valueForPoint:pt] == 1) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (void)onLeft
{
    if ([self canLeft]) {
        _currentBoxPoint.x--;
    }
}

- (BOOL)canRight
{
    for (int i = 0 ; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if (gXFBox[_boxId][i][j] != 0) {
                CGPoint pt = CGPointMake(_currentBoxPoint.x + j + 1 + 1, _currentBoxPoint.y + i);
                if ([self valueForPoint:pt] == 1) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (void)onRight
{
    if ([self canRight]) {
        _currentBoxPoint.x++;
    }
}

- (BOOL)canDown
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0 ; j < 4; j++) {
            if (gXFBox[_boxId][i][j] != 0) {
                CGPoint pt = CGPointMake(_currentBoxPoint.x + j + 1, _currentBoxPoint.y + i + 1);
                if ([self valueForPoint:pt] == 1) {
                    return NO;
                }

            }
        }
    }
    return YES;
}

- (void)onDown
{
    if ([self canDown]) {
        _currentBoxPoint.y++;
    }
}

- (BOOL)canRotate:(int )nextBoxId
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0 ; j < 4; j++) {
            if (gXFBox[nextBoxId][i][j] != 0) {
                CGPoint pt = CGPointMake(_currentBoxPoint.x + j + 1, _currentBoxPoint.y + i);
                if ([self valueForPoint:pt] == 1) {
                    return NO;
                }
                
            }
        }
    }
    return YES;
}

- (void)onRotate
{
    int next_box = 0;
    switch(_boxId)
    {
        case 0:next_box=1;break;
        case 1:next_box=0;break;
        case 2:next_box=3;break;
        case 3:next_box=4;break;
        case 4:next_box=5;break;
        case 5:next_box=2;break;
        case 6:next_box=7;break;
        case 7:next_box=8;break;
        case 8:next_box=9;break;
        case 9:next_box=6;break;
        case 10:next_box=11;break;
        case 11:next_box=10;break;
        case 12:next_box=13;break;
        case 13:next_box=12;break;
        case 14:next_box=15;break;
        case 15:next_box=16;break;
        case 16:next_box=17;break;
        case 17:next_box=14;break;
        case 18:next_box=18;break;
    }
    
    if ([self canRotate:next_box]) {
        _boxId = next_box;
    }
}



/**
 * 能否放下当前方块
 */
- (BOOL)canPut
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0 ; j < 4; j++) {
            
                CGPoint pt = CGPointMake(_currentBoxPoint.x + j + 1, _currentBoxPoint.y + i);
                if ([self valueForPoint:pt] == 1) {
                    return NO;
                }
        }
    }
    return YES;
}

- (void)put
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0 ; j < 4; j++) {
            
            if (gXFBox[_boxId][i][j]) {
                CGPoint pt = CGPointMake(_currentBoxPoint.x + j + 1, _currentBoxPoint.y + i);
                [self setValueForPoint:pt];
            }
        }
    }
}

- (BOOL) checkFullRow:(int) row
{
    for (int j = 1; j <= kBoardWide; j++) {
        if (gBoard[row][j] == 0) {
            return NO;
        }
    }
    return YES;
}

- (void)setEmptyRow:(int) row
{
    for (int j = 0; j <= kBoardWide; j++) {
        gBoard[row][j] = 1;
    }
}

- (void)copyDestRow:(int)dest andSrcRow:(int)src
{
    for (int j = 1; j<=kBoardWide; j++) {
        gBoard[dest][j] = gBoard[src][j];
    }
}

- (void)dealFullFall:(int) row
{
    int k = 0;
    for (k = row; k >= 1; k--) {
        
        // k--k-1,上面的方块下落
        [self copyDestRow:k andSrcRow:k-1];
    }
}

- (int)dealFull
{
    int nCount = 0;
    int score = 0;
    for (int i = kBoardHigh - 1; i >= 0 ; i--) {
        
        if ([self checkFullRow:i]) {
            [self setEmptyRow:i];
            [self dealFullFall:i];
            
            //reSet
            i++;
            
            nCount++;
        }
    }
    
    switch (nCount) {
        case 1:
            score+=100;
            break;
        case 2:
            score+=300;
            break;
        case 3:
            score+=500;
            break;
        case 4:
            score+=700;
            break;
        default:
            break;
    }
    if (score > 0) {
        NSLog(@"score:%d",score);
    }
    return score;
}





// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

#pragma mark - draw



/**
 * 画背景格子
 */
- (void)drawGrid
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(ctx==NULL)
        return;
    CGMutablePathRef path = CGPathCreateMutable();
    
    int bottom = kScreenHeight;
    int top = kScreenHeight - kBoardHigh*kBoxHeight;
    
    int i =0;
    //画横线，
    for(i = 0 ; i <= kBoardHigh ; i++)
    {
        CGPathMoveToPoint(path, NULL, 0, top + i*kBoxHeight);
        CGPathAddLineToPoint(path, NULL, kBoxWidth*kBoardWide + 0,top + i * kBoxHeight);
    }
    //画竖线
    for(i = 0 ; i <= kBoardHigh ; i++)
    {
        CGPathMoveToPoint(path, NULL, i * kBoxWidth, top);
        CGPathAddLineToPoint(path, NULL, i * kBoxWidth, bottom);
    }
    CGContextAddPath(ctx, path);
    
    //颜色
    CGContextSetLineWidth(ctx, 1.8);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    
    CGContextStrokePath(ctx);
    CGPathRelease(path);
}


/**
 * 画所有的方块（堆积下来的）
 */
- (void)drawAllBox
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(ctx==NULL)
        return;
    CGContextSetFillColorWithColor(ctx, [[UIColor purpleColor] CGColor]);
    
    //从下往上画
    for (int i = kBoardHigh - 1; i>=0; i--) {
        for (int j = 1; j <= kBoardWide ; j++) {
            if (gBoard[i][j] == 1) {
                CGRect rect = CGRectMake(kBoxWidth * (j-1), kOriginY + i*kBoxHeight, kBoxWidth, kBoxHeight);
                UIRectFill(rect);
                CGContextStrokeRect(ctx, rect);
            }
        }
    }
}


/**
 * 画悬浮的方块
 * 一一对应，（0，0）对于格子中的0,0
 */
- (void)drawFloatBox
{
    if (_boxId > 18) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == NULL) {
        return;
    }
    
    CGContextSetFillColorWithColor(ctx, [[UIColor purpleColor] CGColor]);
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if (gXFBox[_boxId][i][j] != 0) {
                CGRect rect = CGRectMake((_currentBoxPoint.x+j) * kBoxWidth, (_currentBoxPoint.y+i)*kBoxHeight + kOriginY, kBoxWidth, kBoxHeight);
                UIRectFill(rect);
                CGContextStrokeRect(ctx, rect);
            }
        }
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self drawGrid];
    [self showInfo];
    [self drawAllBox];
    [self drawFloatBox];
}

#pragma mark - event

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
    if ([self isGamaOver]) {
        return;
    }
    [self onRotate];
    [self setNeedsDisplay];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    if([self isGamaOver])
        return;
    
    static CGPoint beginPoint ;
    static CGPoint movingPoint;
    CGPoint endpoint;
 
    
    if([gesture state]==UIGestureRecognizerStateBegan)
    {
        beginPoint = [gesture locationInView:self];
        movingPoint = beginPoint;
    }
    
    
    if([gesture state]==UIGestureRecognizerStateChanged)
    {
        //beginPoint = movingPoint;
        movingPoint = [gesture locationInView:self];
        //NSLog(@"beingPoint %@",NSStringFromCGPoint(beginPoint));
        //NSLog(@"movingPoint %@",NSStringFromCGPoint(movingPoint));
        
        
        NSInteger stepX = (NSInteger)((movingPoint.x - beginPoint.x)/10);
        //NSLog(@"stepx=%ld",stepX);
        
        NSInteger stepY = (NSInteger)((movingPoint.y - beginPoint.y)/10);
        if(stepX >= 1)
        {
            if([self canRight])
            {
                [self onRight];
                beginPoint = movingPoint;
                [self setNeedsDisplay];
            }
        }
        else if(stepX <= -1)
        {
            if([self canLeft])
            {
                [self onLeft];
                beginPoint = movingPoint;
                [self setNeedsDisplay];
            }
        }
        else if(stepY >= 1)
        {
            if([self canDown])
            {
                [self onDown];
                beginPoint = movingPoint;
                [self setNeedsDisplay];
            }
        }
    }
    if([gesture state]==UIGestureRecognizerStateEnded)
    {
        endpoint = [gesture locationInView:self];
        //NSLog(@"endpoint is %@",NSStringFromCGPoint(endpoint));
    }
}

#pragma mark -delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self initial];
}


@end
