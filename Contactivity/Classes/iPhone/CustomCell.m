//
//  CustomCell.m
//  Contactivity
//
//  Created by Erik Solis on 5/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

@synthesize imageView, nombre, telefono, correo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
