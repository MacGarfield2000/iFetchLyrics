// NSMutableArray+Shuffling.h

/** This category enhances NSMutableArray by providing methods to randomly
 * shuffle the elements using the Fisher-Yates algorithm.
 */
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end