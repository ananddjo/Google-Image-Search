//
//  GoogleSearchVC.m
//  pixster
//
//  Created by Anand Joshi on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "GoogleSearchVC.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "ImageCVCell.h"


@interface GoogleSearchVC ()

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic) BOOL loadingMoreContent;

@end

@implementation GoogleSearchVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Google Image Search";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Google Image Search";
        self.imageResults = [NSMutableArray array];
        self.loadingMoreContent=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchDisplay delegate

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    [self.imageResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return NO;
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
    NSLog(@"Searching Data ... First time");
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            [self.collectionView reloadData];
        }
    } failure:nil];
    
    [operation start];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.imageResults.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ImageCVCell" forIndexPath:indexPath];
    ImageCVCell *iCell = (ImageCVCell *) cell;
    iCell.imgView.image = nil;
    [iCell.imgView setImageWithURL:[NSURL URLWithString:[[self.imageResults objectAtIndex:indexPath.row] objectForKey:@"tbUrl"]]];
    // if cell being requested is the end of the model, load more data
    if (indexPath.row+1 >= self.imageResults.count && self.loadingMoreContent==NO) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%d", [self.imgSearch.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], self.imageResults.count]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSLog(@"Requesting more data ahead of %d ...", self.imageResults.count);
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            id results = [JSON valueForKeyPath:@"responseData.results"];
            if ([results isKindOfClass:[NSArray class]]) {
                [self.imageResults addObjectsFromArray:results];
                self.loadingMoreContent=NO;
                [self.collectionView reloadData];
            }
        } failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error, id JSON ) {
                NSLog(@"Error! %@", error);
        }
        ];
        
        [operation start];
        
    }
    return cell;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger width = [[[self.imageResults objectAtIndex:indexPath.row] objectForKey:@"tbWidth"] integerValue];
    NSInteger height = [[[self.imageResults objectAtIndex:indexPath.row] objectForKey:@"tbHeight"] integerValue];
    //SearchImage *img = self.imageResults[indexPath.row];
    NSLog(@"Width %d and height %d",width,height);
    CGSize retval = width > 0 ? CGSizeMake(width, height) : CGSizeMake(100, 100);
    //retval.height += 35; retval.width += 35;
    return retval;
}
*/

@end
