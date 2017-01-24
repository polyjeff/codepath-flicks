//
//  MovieModel.m
//  Flicks
//
//  Created by Jeffrey Okamoto on 1/23/17.
//  Copyright © 2017 Jeffrey Okamoto. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.title = dictionary[@"original_title"];
        self.movieDescription = dictionary[@"overview"];
        self.releaseDate = dictionary[@"release_date"];
        self.voteAverage = dictionary[@"vote_average"];
        NSString *urlString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w342%@", dictionary[@"poster_path"]];
        self.posterURL = [NSURL URLWithString:urlString];
        NSString *urlHiresString = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", dictionary[@"poster_path"]];
        self.hiresPosterURL = [NSURL URLWithString:urlHiresString];
    }
    return self;
}

@end
