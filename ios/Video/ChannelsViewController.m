//
//  ChannelsViewController.m
//  Pods
//
//  Created by Mahdi Hamdan on 13/02/2022.
//

#import "ChannelsViewController.h"
#import "TVUIKit/TVUIKit.h"

@interface ChannelsViewController (){
}
@end

@implementation ChannelsViewController

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
    return self.channels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    NSDictionary *channel = [self.channels objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:[channel objectForKey:@"thumb"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc ] initWithData: data];
    
    TVPosterView *posterView= [[TVPosterView alloc] initWithImage:image];
    posterView.layer.cornerRadius = 20;
     posterView.title =[channel objectForKey:@"title"];
    posterView.frame= cell.bounds;
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
     }
   
    [cell.contentView addSubview:posterView];
     return cell;
}
- (NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView{
    @try{
        int currentChannelIndex = 0;
        int i, count = (int)[self.channels count];
        for(i = 0; i < count; i++){
            if([self.channels[i] objectForKey:@"id"] == self.currentChannelId){
                currentChannelIndex = i;
            }
        }
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:currentChannelIndex inSection:0];
        return indexPath;
    }
    @catch(id anException){
        NSLog(@"====indexPathForPreferredFocusedViewInCollectionView Expection ===== %@", anException);
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *channelId =@"";
    int i, count = (int)[self.channels count];
    for(i = 0; i < count; i++){
        if(i ==  indexPath.row){
            channelId = [self.channels[i] objectForKey:@"id"];
        }
    }
    if(self.onChannelSelect){
        self.onChannelSelect(@{
            @"id" : channelId,
            @"index" : [NSString stringWithFormat:@"%ld", indexPath.row]
        });
    }


}
@end
