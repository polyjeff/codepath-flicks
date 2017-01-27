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
@property (weak, nonatomic) IBOutlet UILabel *runtime;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Make secondary network call
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@&append_to_response=videos", self.movieModel.movieID, apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                            completionHandler:^(NSData * _Nullable data,
                                                NSURLResponse * _Nullable response,
                                                NSError * _Nullable error) {
                                if (!error) {
                                    NSError *jsonError = nil;
                                    NSDictionary *responseDictionary =
                                    [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                      error:&jsonError];
                                    NSLog(@"Response: %@", responseDictionary);
                                    // Terrible assumptions made here...
                                    self.movieModel.trailerID = responseDictionary[@"videos"][@"results"][0][@"id"];
                                    self.movieModel.runtime = responseDictionary[@"runtime"];
                                    NSLog(@"Trailer id = %@, runtime = %@", self.movieModel.trailerID, self.movieModel.runtime);
                                    // self.movies = models;
                                    // [self.movieTableView reloadData];
                                    // [self.collectionView reloadData];
                                    [self fillInTheBlanks];
                                } else {
                                    NSLog(@"An error occurred: %@", error.description);
                                }
                            }
                  ];
    [task resume];
    
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.movieDescription);
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.posterURL);
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.hiresPosterURL);
    // NSLog(@"Inside DVC: viewDidLoad: %@", self.movieModel.releaseDate);
    self.detailMovieTitle.text = self.movieModel.title;
    self.detailMovieDescription.text = self.movieModel.movieDescription;
    [self.detailMovieDescription sizeToFit];
    
    self.releaseDate.text = [NSString stringWithFormat:@"Released %@", self.movieModel.releaseDate];
    self.averageVote.text = [NSString stringWithFormat:@"Score: %@/10", self.movieModel.voteAverage];
    self.runtime.text = @"Run time: ..."; // Filled in later
    [self.detailImageView setImageWithURL:self.movieModel.hiresPosterURL];
    
    CGFloat labelMaxY = CGRectGetMaxY(self.detailMovieDescription.frame);
    CGRect contentFrame = self.scrollContentView.frame;
    contentFrame.size.height = labelMaxY + 20;
    contentFrame.origin.y = (labelMaxY + 20) * 0.75;
    self.scrollContentView.frame = contentFrame;
    
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

- (void)fillInTheBlanks {
    NSLog(@"SECOND TIME: Trailer id = %@, runtime = %@", self.movieModel.trailerID, self.movieModel.runtime);
    self.runtime.text = [NSString stringWithFormat:@"Run time: %@ minutes", self.movieModel.runtime];

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
