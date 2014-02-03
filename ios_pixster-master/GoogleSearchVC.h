//
//  GoogleSearchVC.h
//  pixster
//
//  Created by Anand Joshi on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleSearchVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchDisplayDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *imgSearch;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
