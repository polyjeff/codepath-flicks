//
//  MovieModel.h
//  Flicks
//
//  Created by Jeffrey Okamoto on 1/23/17.
//  Copyright © 2017 Jeffrey Okamoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

- (instancetype) initWithDictionary:(NSDictionary *)otherDictionary;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *movieDescription;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *voteAverage;
@property (nonatomic, strong) NSURL *posterURL;
@property (nonatomic, strong) NSURL *hiresPosterURL;
@property (nonatomic, strong) NSString *movieID;
@property (nonatomic, strong) NSString *runtime;
@property (nonatomic, strong) NSString *trailerID;

@end
