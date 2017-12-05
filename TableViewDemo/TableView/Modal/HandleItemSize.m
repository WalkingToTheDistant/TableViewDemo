//
//  HandleItemSize.m
//  TableViewDemo
//
//  Created by LHJ on 2017/10/28.
//  Copyright © 2017年 LHJ. All rights reserved.
//

#import "HandleItemSize.h"
#import "CPublic.h"
// ===============================================================
@implementation ItemSize

@end

// ===============================================================
static HandleItemSize *sharedHandleItemSize = nil;
@implementation HandleItemSize

+ (instancetype) sharedHandleItemSize{
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if(sharedHandleItemSize == nil){
            sharedHandleItemSize = [HandleItemSize new];
        }
    });
    
    return sharedHandleItemSize;
}

+ (NSArray<ItemSize*> *) handleTableViewItemSize:(NSArray<ItemData*>*) aryItemDatas
                    withMaxWidth:(int)maxWidth{
    
    NSMutableArray<ItemSize*> *muAryItemSizes = [NSMutableArray new];
    
    static const int spaceEdge_x = 14;
    static const int spaceEdge_y = 16;
    static const int spaceInsert_x = 14;
    static const int spaceInsert_y = 8;
    static const int spaceImgCount_x = 6;
    static const int spaceImgCount_y = 6;
    const int threeRowHeight = [HandleData getHeightForTextOfThreeRow];
    const int twoRowHeight = [HandleData getHeightForTextOfTwoRow];
    
    for(ItemData *data in aryItemDatas){
        
        ItemSize *itemSize = [ItemSize new];
        NSMutableArray<NSValue*> *muAryImgFrame = [NSMutableArray new];
        switch(data.itemStyle)
        {
            case ItemStyle_OneImg:{ // 只有一张图片
                // 图片位置
                const int imgHeight = threeRowHeight;
                const int imgWidth = imgHeight * 4/3; // 16:9
                const int imgX = (maxWidth - imgWidth - spaceEdge_x);
                const int imgY = spaceEdge_y;
                [muAryImgFrame addObject:@(CGRectMake(imgX, imgY, imgWidth, imgHeight))];
                
                // 文字位置
                const int textX = spaceEdge_x;
                const int textY = spaceEdge_y + spaceInsert_y;
                const int textWidth = imgX - spaceInsert_x - textX;
                int textHeight = [HandleData getSizeForTitleFontWithStr:data.title withMaxSize:CGSizeMake(maxWidth-spaceEdge_x, CGFLOAT_MAX)].height;
                if(textHeight > twoRowHeight){
                    textHeight = twoRowHeight;
                }
                
                itemSize.textRect = CGRectMake(textX, textY, textWidth, textHeight);
                
                // 计算行高度
                itemSize.itemCellHeight = imgY + imgHeight + spaceEdge_y;
                break;
            }
            case ItemStyle_ThreeImgs:{ // 2~3张图片
                // 文字位置
                const int textX = spaceEdge_x;
                const int textY = spaceEdge_y;
                const int textWidth = maxWidth - spaceEdge_x - textX;
                int textHeight = [HandleData getSizeForTitleFontWithStr:data.title withMaxSize:CGSizeMake(maxWidth-spaceEdge_x, CGFLOAT_MAX)].height;;
                if(textHeight > twoRowHeight){
                    textHeight = twoRowHeight;
                }
                itemSize.textRect = CGRectMake(textX, textY, textWidth, textHeight);
                
                // 图片位置
                const int countImg = 3;
                const int spaceImg_x = 6;
                const int imgWidth = (maxWidth - spaceEdge_x *2 - spaceImg_x*(countImg-1))/ countImg;
                const int imgHeight = imgWidth*3/4;
                int imgX = spaceEdge_x;
                const int imgY = textY + textHeight + spaceInsert_y;
                
                for(int i=0; i<countImg; i+=1){
                    CGRect imgFrame = CGRectMake(imgX, imgY, imgWidth, imgHeight);
                    [muAryImgFrame addObject:@(imgFrame)];
                    
                    imgX += (imgWidth + spaceImg_x);
                }
                
                // 计算行高度
                itemSize.itemCellHeight = imgY + imgHeight + spaceEdge_y;
                
                break;
            }
            case ItemStyle_Imgs_1:{ // 多张图片样式1 - 只显示一张图片
                
                // 文字位置
                const int textX = spaceEdge_x;
                const int textY = spaceEdge_y;
                const int textWidth = maxWidth - spaceEdge_x - textX;
                int textHeight = [HandleData getSizeForTitleFontWithStr:data.title withMaxSize:CGSizeMake(maxWidth-spaceEdge_x*2, CGFLOAT_MAX)].height;
                if(textHeight > twoRowHeight){
                    textHeight = twoRowHeight;
                }
                
                itemSize.textRect = CGRectMake(textX, textY, textWidth, textHeight);
                
                // 图片位置
                const int imgX = spaceEdge_x;
                const int imgWidth = maxWidth - imgX - spaceEdge_x;
                const int imgHeight = imgWidth * 3 / 4;  // 16:9
                const int imgY = textY + textHeight + spaceInsert_y;
                
                [muAryImgFrame addObject:@(CGRectMake(imgX, imgY, imgWidth, imgHeight))];
                
                // 图片数量的位置
                NSString *str = [NSString stringWithFormat:@"%lu图", data.aryImgs.count];
                CGSize sizeCount = [HandleData getSizeForOneTextWithStr:str withFont:Font_ImgCount withMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                
                NSString *strImg = @"图片";
                CGSize sizeImg = [HandleData getSizeForOneTextWithStr:strImg withFont:Font_ImgCount withMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                const int imgCountWidth = spaceImgCount_x*2 + sizeImg.width + spaceImgCount_x + sizeCount.width;
                const int imgCountHeight = spaceImgCount_y*2 + sizeCount.height;
                const int imgCount_x = imgWidth - imgCountWidth - spaceImgCount_x;
                const int imgCount_y = imgHeight - imgCountHeight - spaceImgCount_y;
                itemSize.imgCountFrame = CGRectMake(imgCount_x, imgCount_y, imgCountWidth, imgCountHeight);

                const int imgSub_x = imgCountWidth/2 - sizeImg.height - spaceImgCount_x/2;
                itemSize.imgCountSubFrame_img = CGRectMake(imgSub_x, spaceImgCount_y, sizeImg.height, sizeImg.height);
                
                const int textSub_x = imgCountWidth/2 + spaceImgCount_x/2;
                itemSize.imgCountSubFrame_count = CGRectMake(textSub_x, spaceImgCount_y, sizeCount.width, sizeCount.height);
                
                // 计算行高度
                itemSize.itemCellHeight = imgY + imgHeight + spaceEdge_y;
                
                break;
            }
            case ItemStyle_Imgs_2:{ // 多张图片样式2
                
                // 文字位置
                const int textX = spaceEdge_x;
                const int textY = spaceEdge_y + spaceInsert_y;
                const int textWidth = maxWidth - spaceEdge_x - textX;
                int textHeight = [HandleData getSizeForTitleFontWithStr:data.title withMaxSize:CGSizeMake(maxWidth-spaceEdge_x, CGFLOAT_MAX)].height;;
                if(textHeight > twoRowHeight){
                    textHeight = twoRowHeight;
                }
                
                itemSize.textRect = CGRectMake(textX, textY, textWidth, textHeight);
                
                // 图片位置
                const int imgY = textY + textHeight + spaceInsert_y;
                int imgX = spaceEdge_x;
                const int spaceImg = 2;
                const int count_squareImg = 2; // 右边正方形图片的数量
                const int imgWidth = (maxWidth - spaceEdge_x*2) *5/10; // 左边矩形图片的宽度
                const int imgWidth_square = (maxWidth - spaceEdge_x*2 - imgWidth - spaceImg * count_squareImg)/count_squareImg;
                const int imgHeight_square = imgWidth_square;
                const int imgHeight = imgHeight_square * count_squareImg + spaceImg;
                [muAryImgFrame addObject:@(CGRectMake(imgX, imgY, imgWidth, imgHeight))]; // 左边矩形图片
                
                // 右边图片计算
                imgX += imgWidth + spaceImg;
                for(int col=0, row=0; row<count_squareImg;){
                    
                    int for_x = imgX + col * (imgWidth_square + spaceImg);
                    int for_y = imgY + row * (imgHeight_square + spaceImg);
                    [muAryImgFrame addObject:@(CGRectMake(for_x, for_y, imgWidth_square, imgHeight_square))];
                    
                    if((col+1) >= count_squareImg){
                        row +=1;
                        col = 0;
                    } else {
                        col += 1;
                    }
                }
                
                // 计算行高度
                itemSize.itemCellHeight = imgY + imgHeight + spaceEdge_y;
                break;
            }
        }
        itemSize.aryImgFrame = muAryImgFrame;
        [muAryItemSizes addObject:itemSize];
    }
    return muAryItemSizes;
}

@end
