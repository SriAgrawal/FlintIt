//
//  TableViewWithMultipleSelection.h
//  TableViewLikePicker
//
//  Created by Abhishek Agarwal on 11/06/16.
//  Copyright © 2016 Abhishek Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectedOptionInformationModalClass : NSObject

@property (nonatomic,strong) NSString *selectedObject;
@property (nonatomic,assign) NSInteger selectedIndex;

@end

typedef void(^SelectedOptionInformation)(NSMutableArray *selectedText,NSMutableArray *selectedIndex);

typedef void(^PickerDataModalSelection)(NSArray *updatedModals);


@interface TableViewWithMultipleSelection : UIView<UITableViewDelegate,UITableViewDataSource>

+ (id)sharedTableViewWithMultipleSelection;

-(void)addTableViewWithOptions:(NSArray *)options andSelectedDataInfo:(NSMutableArray *)selectedDataArray andCompletionBlock:(SelectedOptionInformation)block;

-(void)addTableViewWithData:(NSArray *)options andCompletionBlock:(PickerDataModalSelection)block;

@end
