//
//  MoviePosterCollectionViewCell.m
//  Flicks
//
//  Created by Jeffrey Okamoto on 1/26/17.
//  Copyright © 2017 Jeffrey Okamoto. All rights reserved.
//

#import "MoviePosterCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface MoviePosterCollectionViewCell ()

@property (strong,nonatomic) UIImageView *imageView;

@end

@implementation MoviePosterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void) reloadData
{
    [self.imageView setImageWithURL:self.model.posterURL];
    // Make sure layoutSubViews gets called
    [self setNeedsLayout];
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    // Image view is same size as cell
    self.imageView.frame = self.contentView.bounds;
}

@end
