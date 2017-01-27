//
//  DetailsViewController.m
//  Flicks
//
//  Created by Jeffrey Okamoto on 1/24/17.
//  Copyright © 2017 Jeffrey Okamoto. All rights reserved.
//

#import "DetailsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

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
                                    // NSLog(@"Response: %@", responseDictionary);
                                    // Terrible assumptions made here...
                                    self.movieModel.trailerID = responseDictionary[@"videos"][@"results"][0][@"key"];
                                    self.movieModel.runtime = responseDictionary[@"runtime"];
                                    // Reload values on the view that depended on this data
                                    [self fillInTheBlanks];
                                } else {
                                    NSLog(@"An error occurred: %@", error.description);
                                }
                            }
                  ];
    [task resume];
    
    self.detailMovieTitle.text = self.movieModel.title;
    self.detailMovieDescription.text = self.movieModel.movieDescription;
    [self.detailMovieDescription sizeToFit];
    
    self.releaseDate.text = [NSString stringWithFormat:@"Released %@", self.movieModel.releaseDate];
    self.averageVote.text = [NSString stringWithFormat:@"Score: %.1f/10", self.movieModel.voteAverage.doubleValue];
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

    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [playButton setTitle:@"Play Video" forState:UIControlStateNormal];
    [playButton sizeToFit];
    [playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:playButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)fillInTheBlanks {
    self.runtime.text = [NSString stringWithFormat:@"Run time: %@ minutes", self.movieModel.runtime];
    // Create "Play Trailer" button... later
}

- (void) playVideo
{
    NSLog(@"Inside playVideo, trailer ID = %@", self.movieModel.trailerID);
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.movieModel.trailerID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
    MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    if (finishReason == MPMovieFinishReasonPlaybackError)
    {
        NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
        // Handle error
    }
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
