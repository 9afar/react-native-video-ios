//
//  EpisodesViewController.m
//  Pods
//
//  Created by Mahdi Hamdan on 13/02/2022.
//

#import "EpisodesViewController.h"
#import "TVUIKit/TVUIKit.h"
static NSString *const RCTHidePlayerControls = @"RCTHidePlayerControls";
static NSString *const RCTEpisodeTabAppear = @"RCTEpisodeTabAppear";

@interface EpisodesViewController(){
    NSDictionary *episode;
    NSArray *_episodes;
    
    int counter;
}
@end

@implementation EpisodesViewController

NSString * _reuseIdentifier = @"Cell";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_reuseIdentifier];
    
}
- (void)viewWillAppear:(BOOL)animated{
    if (@available(tvOS 15.0, *) ) {
        self.collectionView.remembersLastFocusedIndexPath = false;

    }else{
         self.collectionView.remembersLastFocusedIndexPath = true;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RCTEpisodeTabAppear
                                                        object:nil
                                                      userInfo:nil];
    
  
    
    [self.collectionView reloadData];
 
}

#pragma mark <UICollectionViewDataSource>
- (void) setEpisodes:(NSArray *)episodes {
    _episodes = episodes;
    [self.collectionView reloadData];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _episodes.count > 0 ?_episodes.count : 30 ;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    if(@available(tvOS 13.0, *)){
        if(_episodes.count ==0 ){
            TVPosterView *posterView =[[TVPosterView alloc] init];
            posterView.frame = CGRectMake(0 , 0 , 380 , 213);
            posterView.imageView.layer.cornerRadius = 50;
            
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurredEffectView.frame =posterView.bounds;
            blurredEffectView.layer.cornerRadius = 50;
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            spinner.color = [UIColor grayColor];
            
            spinner.frame = CGRectMake(0, 0, 24, 24);
            [spinner startAnimating];
            
            
            [posterView.imageView.overlayContentView insertSubview:blurredEffectView atIndex:0];
            spinner.center = posterView.center;
            [posterView.imageView.overlayContentView insertSubview:spinner atIndex:1];
            [cell.contentView addSubview:posterView];

            return cell;
            
        }
        
        NSDictionary *episode = [_episodes objectAtIndex:indexPath.row];
        self->episode = episode;
        self->counter = 0;
        
        //===== TVOS 14 ========
        TVPosterView *posterView =[[TVPosterView alloc] init];
        
        posterView.frame = cell.bounds;
        posterView.imageView.layer.cornerRadius = 50;
        
        UIImage *intialImage  = [UIImage imageNamed:@"emptyBackground.png"];
        
        posterView.frame = CGRectMake(0, 0, 420, 270);
        posterView.image = intialImage;
        posterView.imageView.frame =CGRectMake(0, 0, 420, 236);
        
        posterView.title = [episode objectForKey:@"title"];
        
        if((long) [self getSelectedIndex] != indexPath.row){
            posterView.footerView.titleLabel.textColor = [UIColor grayColor];
        }
         if(![[episode objectForKey:@"id"]  isEqual: @"more"]){
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSURL *url = [NSURL URLWithString:[episode objectForKey:@"thumb"]];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *image = [[UIImage alloc ] initWithData: data];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    posterView.image = image;
                
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
                });
                
            });
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
            
            
        } else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                NSURL *url = [NSURL URLWithString:[episode objectForKey:@"thumb"]];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *image = [[UIImage alloc ] initWithData: data];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    posterView.image = image;
                    
                });
            });
            
            
        }
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        [cell.contentView addSubview:posterView];
    }
    
    return cell;
}
- (int) getSelectedIndex {
    int currentEpisodeIndex = 0;
    int i, count = (int)[_episodes count];
    for(i = 0; i < count; i++){
        if([_episodes[i] objectForKey:@"id"] == self.currentEpisodeId){
            currentEpisodeIndex = i;
        }
    }
    return currentEpisodeIndex;
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView{
    @try{
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:[self getSelectedIndex] inSection:0];
        [NSThread sleepForTimeInterval:0.5];
      
        return indexPath;
    }
    @catch(id anException){
        NSLog(@"====indexPathForPreferredFocusedViewInCollectionView Expection ===== %@", anException);
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *episodeId =@"";
    
    int i, count = (int)[_episodes count];
    if(count == 0 ){
        return;
    }
    for(i = 0; i < count; i++){
        if(i ==  indexPath.row){
            episodeId = [_episodes[i] objectForKey:@"id"];
        }
    }
    
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
- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context API_AVAILABLE(ios(9.0)){
    
    if( _episodes.count > 0){

        return  true;
    }
    return  false;
}

 
@end
