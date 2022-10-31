//
//  EpisodesViewController.m
//  Pods
//
//  Created by Mahdi Hamdan on 13/02/2022.
//

#import "EpisodesViewController.h"
#import "TVUIKit/TVUIKit.h"
static NSString *const RCTHidePlayerControls = @"RCTHidePlayerControls";

@interface EpisodesViewController(){
    NSDictionary *episode;
    int counter;
}
@end

@implementation EpisodesViewController

NSString * _reuseIdentifier = @"Cell";
int _NumberOfAppear = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];

}

- (void)viewWillAppear:(BOOL)animated{
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.episodes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];

    NSDictionary *episode = [self.episodes objectAtIndex:indexPath.row];
    self->episode = episode;
    self->counter = 0;
    if(@available(tvOS 13.0, *)){

        //===== TVOS 14 ========
        TVPosterView *posterView =[[TVPosterView alloc] init];
        posterView.title = [episode objectForKey:@"title"];
        posterView.frame = cell.bounds;
        posterView.imageView.layer.cornerRadius = 50;
         if(![[episode objectForKey:@"id"]  isEqual: @"more"]){

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSURL *url = [NSURL URLWithString:[episode objectForKey:@"thumb"]];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *image = [[UIImage alloc ] initWithData: data];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    posterView.image = image;
                    if(![[episode objectForKey:@"catalogTag"] isEqual:@""]){
                        UIImageView *ImageView = [[UIImageView alloc] init];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                       ^{
                            NSURL *overlayUrl = [NSURL URLWithString:[self->episode objectForKey:@"catalogTag"]];
                            NSData *overlayData = [NSData dataWithContentsOfURL:overlayUrl];
                            UIImage *overlayImage = [[UIImage alloc ] initWithData: overlayData];

                            dispatch_sync(dispatch_get_main_queue(), ^{
                                ImageView.image = overlayImage;
                                ImageView.frame= CGRectMake(12, 12, overlayImage.size.width * 0.3, overlayImage.size.height* 0.3);
                                ImageView.layer.cornerRadius = 5;
                                ImageView.clipsToBounds = YES;
                            });
                        });
                        [posterView.imageView.overlayContentView addSubview:ImageView];
                    }
                });

            });

            if([episode objectForKey:@"progress"] && [[episode objectForKey:@"progress"] floatValue] > 0){
                UIProgressView *progressView = [[UIProgressView alloc]  initWithFrame:CGRectMake(10, 165, 320 , 10)];
                progressView.progress =[[episode objectForKey:@"progress"] floatValue];


                UIColor *colorTwo = [UIColor colorWithRed:(152/255.0) green:(152/255.0) blue:(152/255.0) alpha:1];
                UIColor *colorOne = [UIColor clearColor];

                NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];

                CAGradientLayer *layer = [[CAGradientLayer alloc] init];
                layer.frame =CGRectMake(
                                        cell.bounds.origin.x,
                                        cell.bounds.origin.y + 100,
                                        cell.bounds.size.width,
                                        cell.bounds.size.height/2
                                        );
                layer.colors = colors;

                [posterView.imageView.overlayContentView.layer insertSublayer:layer atIndex:0];
                [posterView.imageView.overlayContentView addSubview:progressView];
            }

        } else {

            UIImage *elipses = [UIImage systemImageNamed:@"ellipsis.circle"];
            posterView.image = elipses;

            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *blurredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurredEffectView.frame = posterView.bounds;
            [posterView.imageView.overlayContentView insertSubview:blurredEffectView atIndex:0];


            UIImageView *imageView =[[UIImageView alloc] initWithImage:elipses];
            imageView.frame = CGRectMake(125, 50, 80, 80);
            [posterView.imageView.overlayContentView insertSubview:imageView atIndex:1];

        }

        for (UIView

             *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        [cell.contentView addSubview:posterView];

    }
    return cell;
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView{
    @try{
        int currentEpisodeIndex = 0;
        int i, count = (int)[self.episodes count];
        for(i = 0; i < count; i++){
            if([self.episodes[i] objectForKey:@"id"] == self.currentEpisodeId){
                currentEpisodeIndex = i;
            }
        }
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:currentEpisodeIndex inSection:0];
        return indexPath;
    }
    @catch(id anException){
        NSLog(@"====indexPathForPreferredFocusedViewInCollectionView Expection ===== %@", anException);
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSString *episodeId =@"";

    int i, count = (int)[self.episodes count];
    for(i = 0; i < count; i++){
        if(i ==  indexPath.row){
            episodeId = [self.episodes[i] objectForKey:@"id"];
        }
    }
    //    if(episodeId == self.currentEpisodeId){
    //        [[NSNotificationCenter defaultCenter] postNotificationName:RCTHidePlayerControls
    //                                                            object:nil
    //                                                          userInfo:nil];
    //        return;
    //    }

    if(self.onEpisodeSelect){

        [[NSNotificationCenter defaultCenter] postNotificationName:RCTHidePlayerControls
                                                            object:nil
                                                          userInfo:nil];
        self.onEpisodeSelect(@{
            @"id" : episodeId,
            @"index" : [NSString stringWithFormat:@"%ld", indexPath.row]
        });
    }
}

@end
