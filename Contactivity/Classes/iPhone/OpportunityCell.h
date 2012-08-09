//
//  OpportunityCell.h
//  Contactivity
//
//  Created by Erik Solis on 5/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpportunityCell : UITableViewCell {

    UIImageView *imageView;
    UILabel *nombre;
    UILabel *monto;
    UILabel *estado;
    UILabel *moneda;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *nombre;
@property (nonatomic, retain) IBOutlet UILabel *monto;
@property (nonatomic, retain) IBOutlet UILabel *estado;
@property (nonatomic, retain) IBOutlet UILabel *moneda;

@end
