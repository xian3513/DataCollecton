//
//  ViewController.m
//  DataCollection
//
//  Created by kt on 15/1/2.
//  Copyright (c) 2015年 kt. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataController.h"
#import "Hardware.h"
#import "Ui.h"
#import "DataClick.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
   // [DataClick startWithAppkey:@"" reportPolicy:1 channelId:@""];
//    [DataClick beginLogPageView:@"aaController"];
//    [DataClick beginLogPageView:@"bbController"];
    Ui *user = [Ui share];
    user.name = @"zhang";
    
    user.enterTime = @"14:00";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)readButton:(id)sender {
     //[[CoreDataController share] readDataCollectionFromTable:[Ui share]];
   NSLog(@"%@", [[CoreDataController share] RequestFromTable:[Ui share]]);
}

- (IBAction)writeButton:(id)sender {
     //[DataClick beginLogPageView:@"aaController"];
   
    Ui *user1 = [Ui share];
   
    user1.length = @"100";
   
    //[[CoreDataController share] insertDataCollectionToTable:user];
    [[CoreDataController share] insertDataCollectionToTable:user1];
}

- (IBAction)deleteButton:(id)sender {
    [[CoreDataController share] deleteFromTable:[Ui share]];
    
}

- (IBAction)writeData:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 0){
    
        [DataClick startWithAppkey:@"" reportPolicy:1 channelId:@""];
    }
    else if (btn.tag == 1){
    
        [DataClick UIEvent:nil];
    }
    else{
    
        [DataClick beginLogPageView:@"aaController"];
        [DataClick endLogPageView:@"bbController"];
    }
}

- (IBAction)deleteData:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 0){
        [[CoreDataController share] deleteFromTable:[Hardware share]];
        
    }
    else if (btn.tag == 1){
        
        [[CoreDataController share] deleteFromTable:[Network share]];
    }
    else{
        
        [[CoreDataController share] deleteFromTable:[Ui share]];
    }
}
@end
