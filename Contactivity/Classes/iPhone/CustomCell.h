//
//  CustomCell.h
//  Contactivity
//
//  Created by Erik Solis on 5/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {

    UIImageView *imageView;
    UILabel *nombre;
    UILabel *telefono;
    UILabel *correo;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *nombre;
@property (nonatomic, retain) IBOutlet UILabel *telefono;
@property (nonatomic, retain) IBOutlet UILabel *correo;

@end
