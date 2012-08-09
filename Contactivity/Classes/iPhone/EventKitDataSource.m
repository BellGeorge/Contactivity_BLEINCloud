/*
 * Copyright (c) 2010 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "EventKitDataSource.h"

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
  return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@interface EventKitDataSource ()
- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate;
- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end

@implementation EventKitDataSource

@synthesize defaultCalendar;

+ (EventKitDataSource *)dataSource
{
  return [[[[self class] alloc] init] autorelease];
}

- (id)init {

    if ((self = [super init])) {
        eventStore = [[EKEventStore alloc] init];
          
        // SOLEES
        // Find local source
        EKSource *localSource = nil;
        for (EKSource *source in eventStore.sources) {
            if (source.sourceType == EKSourceTypeLocal) {
                localSource = source;
                break;
            }    
        }
          
        BOOL crearCalendario = YES;
        NSString *contactivityID = @"";
        for(EKCalendar *calendar in [eventStore calendars]) {
            if ([[calendar title] isEqualToString:@"Contactivity"]) {
                crearCalendario = NO;
                contactivityID = [NSString stringWithFormat:@"%@",[calendar calendarIdentifier]];
            }
            // Salimos si lo encontramos
            if (!crearCalendario) break;
        }
          
        EKCalendar *cal;
        if (crearCalendario) {
            cal = [EKCalendar calendarWithEventStore:eventStore];
            cal.title = @"Contactivity";
            cal.source = localSource;
            [eventStore saveCalendar:cal commit:YES error:nil];
              
            // Guardamos el ID del Calendario
            contactivityID = [NSString stringWithFormat:@"%@",[cal calendarIdentifier]];
        } else {
            cal = [eventStore calendarWithIdentifier:contactivityID];
        }
            
            // Get the default calendar from store.
        self.defaultCalendar = [eventStore calendarWithIdentifier:[cal calendarIdentifier]];
        // SOLEES

      events = [[NSMutableArray alloc] init];
      items = [[NSMutableArray alloc] init];
      eventStoreQueue = dispatch_queue_create("com.thepolypeptides.nativecalexample", NULL);
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:) name:EKEventStoreChangedNotification object:nil];

  }
  return self;
}

- (void)eventStoreChanged:(NSNotification *)note
{
  [[NSNotificationCenter defaultCenter] postNotificationName:KalDataSourceChangedNotification object:nil];
}

- (EKEvent *)eventAtIndexPath:(NSIndexPath *)indexPath
{
  return [items objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    /*static NSString *identifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    EKEvent *event = [self eventAtIndexPath:indexPath];
    cell.textLabel.text = event.title;
    return cell;*/
    
    static NSString *CellIdentifier = @"CalendarCell";
    CalendarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CalendarCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[CalendarCell class]]) {
                cell = (CalendarCell *)currentObject;
                break;
            }
        }
    }
    
    // PONEMOS EL NOMBRE DEL EVENTO
    EKEvent *event = [self eventAtIndexPath:indexPath];
    [[cell evento] setText:event.title];
    
    // PONEMOS LA HORA
    //set Date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [[NSString alloc] initWithFormat:@"%@", [formatter stringFromDate:event.startDate]];
    [formatter release];
    
    [[cell hora] setText:timeString];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [items count];
}

#pragma mark KalDataSource protocol conformance

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
  // asynchronous callback on the main thread
  [events removeAllObjects];
  dispatch_async(eventStoreQueue, ^{
    NSDate *fetchProfilerStart = [NSDate date];

    NSArray *calendarArray = [NSArray arrayWithObject:defaultCalendar];
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:fromDate endDate:toDate calendars:calendarArray];
    NSArray *matchedEvents = [eventStore eventsMatchingPredicate:predicate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [events removeAllObjects];
      [events addObjectsFromArray:matchedEvents];
      [delegate loadedDataSource:self];
    });
  });
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate {

    // synchronous callback on the main thread
    return [[self eventsFrom:fromDate to:toDate] valueForKeyPath:@"startDate"];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    // synchronous callback on the main thread
    [items addObjectsFromArray:[self eventsFrom:fromDate to:toDate]];
}

- (void)removeAllItems {
    // synchronous callback on the main thread
    [items removeAllObjects];
}

#pragma mark -

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate {

    NSMutableArray *matches = [NSMutableArray array];
    for (EKEvent *event in events)
    if (IsDateBetweenInclusive(event.startDate, fromDate, toDate))
      [matches addObject:event];
  
    return matches;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    [items release];
    [events release];
    dispatch_sync(eventStoreQueue, ^{
        [eventStore release];
    });
    dispatch_release(eventStoreQueue);
    [defaultCalendar release];
  [super dealloc];
}

@end
