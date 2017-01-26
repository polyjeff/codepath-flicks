//
//  DetailsViewController.m
//  Flicks
//
//  Created by Jeffrey Okamoto on 1/24/17.
//  Copyright © 2017 Jeffrey Okamoto. All rights reserved.
//

#import "DetailsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UILabel *detailMovieTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailMovieDescription;
@property (weak, nonatomic) IBOutlet UILabel *releaseDate;
@property (weak, nonatomic) IBOutlet UILabel *averageVote;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.movieDescription);
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.posterURL);
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.hiresPosterURL);
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.releaseDate);
    self.detailMovieTitle.text = self.movieModel.title;
    self.detailMovieDescription.text = self.movieModel.movieDescription;
    [self.detailMovieDescription sizeToFit];
    
    CGFloat labelMaxY = CGRectGetMaxY(self.detailMovieDescription.frame);
    CGRect contentFrame = self.scrollContentView.frame;
    contentFrame.size.height = labelMaxY + 20;
    contentFrame.origin.y = (labelMaxY + 20) * 0.75;
    self.scrollContentView.frame = contentFrame;
    
    self.releaseDate.text = [NSString stringWithFormat:@"Released %@", self.movieModel.releaseDate];
    self.averageVote.text = [NSString stringWithFormat:@"Score: %@/10", self.movieModel.voteAverage];
    [self.detailImageView setImageWithURL:self.movieModel.hiresPosterURL];
    
    // Set scroll
    CGFloat contentOffsetY = CGRectGetMaxY(self.scrollContentView.frame);
    CGRect scrollViewFrame = self.detailScrollView.frame;
    scrollViewFrame.size.height = CGRectGetHeight(self.scrollContentView.bounds);
    self.detailScrollView.frame = scrollViewFrame;
    self.detailScrollView.contentSize = CGSizeMake(self.detailScrollView.bounds.size.width, contentOffsetY);
    
    // self.detailScrollView.backgroundColor = [UIColor yellowColor];
    // self.scrollContentView.backgroundColor = [UIColor blueColor];
    NSLog(@"%@", self.detailScrollView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
