//
//  ViewController.m
//  Flicks
//
//  Created by  Jeff Okamoto on 1/23/17.
//  Copyright © 2017  Jeff Okamoto. All rights reserved.
//

#import "ViewController.h"
#import "MovieCell.h"
#import "MovieModel.h"
#import "DetailsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>

@interface ViewController () <UITableViewDataSource>

@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (strong, nonatomic) NSString *initialURL;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.movieTableView.dataSource = self;
    if ([self.restorationIdentifier isEqualToString:@"now_playing"]) {
        self.initialURL = @"https://api.themoviedb.org/3/movie/now_playing?api_key=";
    } else if ([self.restorationIdentifier isEqualToString:@"top_rated"]) {
        self.initialURL = @"https://api.themoviedb.org/3/movie/top_rated?api_key=";
    }
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.movieTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];

    [self fetchMovies];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieCell *cellPtr = sender;
    NSIndexPath *indexPath = [self.movieTableView indexPathForCell:cellPtr];
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    DetailsViewController *dvc = segue.destinationViewController;
    dvc.movieModel = model;
}

- (void)fetchMovies
{
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [self.initialURL stringByAppendingString:apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
                                        NSArray *results = responseDictionary[@"results"];
                                        NSMutableArray *models = [NSMutableArray array];
                                        
                                        for (NSDictionary *result in results) {
                                            MovieModel *model = [[MovieModel alloc] initWithDictionary:result];
                                            // NSLog(@"Model - %@", model);
                                            [models addObject:model];
                                        }
                                        self.movies = models;
                                        [self.refreshControl endRefreshing];
                                        [self.movieTableView reloadData];
                                        
                                    } else {
                                        NSLog(@"An error occurred: %@",
                                                          error.description);
                                    }
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                }];
    [task resume];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell* cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    
    MovieModel *model = [self.movies objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = model.title;
    cell.overviewLabel.text = model.movieDescription;
    cell.posterImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.posterImage setImageWithURL:model.posterURL];
    
    // NSLog(@"row number = %ld", indexPath.row);
    
    return cell;
}

@end
