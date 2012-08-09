//
//  CalendarCell.h
//  Contactivity
//
//  Created by Erik Solis on 5/17/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarCell : UITableViewCell {

    UILabel *hora;
    UILabel *evento;
}

@property (nonatomic, retain) IBOutlet UILabel *hora;
@property (nonatomic, retain) IBOutlet UILabel *evento;

@end
