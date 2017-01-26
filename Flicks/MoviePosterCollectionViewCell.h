//
//  MoviePosterCollectionViewCell.h
//  Flicks
//
//  Created by Jeffrey Okamoto on 1/26/17.
//  Copyright © 2017 Jeffrey Okamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieModel.h"

@interface MoviePosterCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) MovieModel *model;

- (void)reloadData;

@end
