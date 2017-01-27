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
#import "MoviePosterCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD.h>

@interface ViewController () <UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray<MovieModel *> *movies;
@property (strong, nonatomic) NSString *initialURL;
@property (strong, nonatomic) UIRefreshControl *listRefreshControl;
@property (strong, nonatomic) UIRefreshControl *collectionRefreshControl;
@property (weak, nonatomic) IBOutlet UIView *errorView;

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // So the subviews don't underlap the navbar and tab bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.movieTableView.dataSource = self;

    // Set URL to populate from based on the restoration ID from the storyboard
    if ([self.restorationIdentifier isEqualToString:@"now_playing"]) {
        self.initialURL = @"https://api.themoviedb.org/3/movie/now_playing?api_key=";
    } else if ([self.restorationIdentifier isEqualToString:@"top_rated"]) {
        self.initialURL = @"https://api.themoviedb.org/3/movie/top_rated?api_key=";
    }
    
    // Set up Collection View and layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat itemHeight = 150;
    CGFloat itemWidth = screenWidth / 3;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 64) collectionViewLayout:layout];
    [collectionView registerClass:[MoviePosterCollectionViewCell class] forCellWithReuseIdentifier:@"MoviePosterCollectionViewCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

    
    // Initial state
    self.collectionView.hidden = YES;
    self.movieTableView.hidden = NO;
    
    // Build segmented control
    NSArray *segText = [NSArray arrayWithObjects:@"List", @"Grid", nil];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:segText];
    segControl.selectedSegmentIndex = 0;
    [segControl addTarget:self action:@selector(changeSegState:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    
    // Add separate pull-to-refresh controls
    self.listRefreshControl = [[UIRefreshControl alloc]init];
    [self.listRefreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.movieTableView addSubview:self.listRefreshControl];
    
    self.collectionRefreshControl = [[UIRefreshControl alloc]init];
    [self.collectionRefreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.collectionRefreshControl];
    
    
    // And... get the data!
    [self fetchMovies];
}

- (void)changeSegState:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.collectionView.hidden = YES;
        self.movieTableView.hidden = NO;
    } else {
        self.collectionView.hidden = NO;
        self.movieTableView.hidden = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        MovieModel *model = [self.movies objectAtIndex:((NSIndexPath *)sender).row];
        DetailsViewController *dvc = segue.destinationViewController;
        dvc.movieModel = model;
    } else if ([sender isKindOfClass:[MovieCell class]]) {
        MovieCell *cellPtr = sender;
        NSIndexPath *indexPath = [self.movieTableView indexPathForCell:cellPtr];
        MovieModel *model = [self.movies objectAtIndex:indexPath.row];
        DetailsViewController *dvc = segue.destinationViewController;
        dvc.movieModel = model;
    }
}

- (void)fetchMovies
{
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [self.initialURL stringByAppendingString:apiKey];
    self.errorView.hidden = YES;
    NSLog(@"Inside fetchMovies");
    
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
                    [self.movieTableView reloadData];
                    [self.collectionView reloadData];
                    
                } else {
                    NSLog(@"An error occurred: %@", error.description);
                    self.errorView.hidden = NO;
                    [self.view bringSubviewToFront:self.errorView];
                }
                [self.listRefreshControl endRefreshing];
                [self.collectionRefreshControl endRefreshing];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        ];
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
    [cell.posterImage setImageWithURL:model.hiresPosterURL];
    
    // NSLog(@"row number = %ld", indexPath.row);
    
    return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MoviePosterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviePosterCollectionViewCell" forIndexPath:indexPath];
    MovieModel *model = [self.movies objectAtIndex:indexPath.item];
    cell.model = model;
    [cell reloadData];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:indexPath];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

@end
