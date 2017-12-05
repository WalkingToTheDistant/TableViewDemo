//
//  ViewController.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/27.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "ViewController.h"
#import "HandleData.h"
#import "CellHeader.h"
#import "ImgShow.h"
#import "ProcessDialog.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain) UITableView *tableView;

@property(nonatomic, retain) NSArray<ItemSize*> *aryItemSizes;

@property(nonatomic, retain) NSArray<ItemData*> *aryItemDatas;

@property(nonatomic, copy) _Nullable ClickImgBlock clickImgBlock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _tableView = [UITableView new];
    [_tableView setFrame:self.view.bounds];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setDelegate:(id)self];
    [_tableView setDataSource:(id)self];
//    [self.view addSubview:_tableView];
    
    __weak typeof(self) wkSelf = self;
    int maxWidth = CGRectGetWidth(wkSelf.tableView.bounds);
    [GCD GCDAsync_GlobalQueue:^{
        [HandleData work:^(NSArray<ItemData *> *listData) {
            wkSelf.aryItemSizes = [HandleItemSize handleTableViewItemSize:listData withMaxWidth:maxWidth];
            wkSelf.aryItemDatas = listData;
            [GCD GCDAsync_MainQueue:^{
                [wkSelf.tableView reloadData];
            }];
        }];
    }];
    
    _clickImgBlock = ^(id objSelf, NSArray<UIImage*> *aryImgs, NSArray<NSValue*> *aryImgScrFrames, int currentImgIndex){
        
        BaseTableViewCell *cell = (BaseTableViewCell*)objSelf;
        ItemData *data = wkSelf.aryItemDatas[cell.tag];
        
        [ImgShow showImgViewWithType:ImgShowType_Line withImgs:aryImgs withImgURLs:data.aryImgs withImgFrames:aryImgScrFrames withCurIndex:currentImgIndex];
    };
    
    [ProcessDialog showDialog];
    [self performSelector:@selector(closeProcess) withObject:nil afterDelay:5.0f];
}
- (void) closeProcess
{
    [ProcessDialog hideDialog];
    
    [self.view addSubview:_tableView];
    [_tableView setAlpha:0.0f];
    [UIView animateWithDuration:0.4f animations:^{
        [_tableView setAlpha:1.0f];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ==========================================================================================================
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_aryItemDatas!=nil) ? _aryItemDatas.count : 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemData *data = _aryItemDatas[indexPath.row];
    BaseTableViewCell *resultCell = nil;
    
    switch(data.itemStyle)
    {
        case ItemStyle_OneImg:{ // 只有一张图片
            static NSString *const strID = @"ItemStyle_OneImg";
            TableViewCell_ItemStyle_OneImg *cellView = [tableView dequeueReusableCellWithIdentifier:strID];
            if(cellView == nil){
                cellView = [[TableViewCell_ItemStyle_OneImg alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
            }
            NSURL *url =(data.aryImgs.count > 0)? data.aryImgs[0] : nil;
            [cellView setLayoutFrame:_aryItemSizes[indexPath.row]];
            [cellView setTitle:data.title withImgURL:url];
            resultCell = cellView;
            break;
        }
        case ItemStyle_ThreeImgs:{ // 2~3张图片
            static NSString *const strID = @"ItemStyle_ThreeImgs";
            TableViewCell_ItemStyle_ThreeImgs *cellView = [tableView dequeueReusableCellWithIdentifier:strID];
            if(cellView == nil){
                cellView = [[TableViewCell_ItemStyle_ThreeImgs alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
            }
            [cellView setLayoutFrame:_aryItemSizes[indexPath.row]];
            [cellView setTitle:data.title withImgs:data.aryImgs];
            resultCell = cellView;
            break;
        }
        case ItemStyle_Imgs_1:{ // 多张图片样式1 - 只显示一张图片
            static NSString *const strID = @"ItemStyle_Imgs_1";
            TableViewCell_ItemStyle_Imgs_1 *cellView = [tableView dequeueReusableCellWithIdentifier:strID];
            if(cellView == nil){
                cellView = [[TableViewCell_ItemStyle_Imgs_1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
            }
            [cellView setLayoutFrame:_aryItemSizes[indexPath.row]];
            [cellView setTitle:data.title withImgs:data.aryImgs withImgCornerRadius:4.0f];
            resultCell = cellView;
            break;
        }
        case ItemStyle_Imgs_2:{ // 多张图片样式2
            static NSString *const strID = @"ItemStyle_Imgs_1";
            TableViewCell_ItemStyle_Imgs_2 *cellView = [tableView dequeueReusableCellWithIdentifier:strID];
            if(cellView == nil){
                cellView = [[TableViewCell_ItemStyle_Imgs_2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
            }
            [cellView setLayoutFrame:_aryItemSizes[indexPath.row]];
            [cellView setTitle:data.title withImgs:data.aryImgs];
            resultCell = cellView;
            break;
        }
    }
    if(resultCell == nil){
        static NSString *const strID = @"default";
        resultCell = [tableView dequeueReusableCellWithIdentifier:strID];
        if(resultCell == nil){
            resultCell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
        }
    }
    [resultCell setTag:indexPath.row];
    [resultCell setClickImgBlock:_clickImgBlock];
    
    return resultCell;
}

// ==========================================================================================================
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (_aryItemSizes!=nil) ? _aryItemSizes[indexPath.row].itemCellHeight : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
