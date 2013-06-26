//
//  LyricsFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "LyricsFetcher.h"

@implementation LyricsFetcher

- (NSString *)fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title
{
	[[NSException new] raise];
	return nil;
}

- (NSString *)replaceLastRoundBracketed:(NSString *)title
{
	if ([title rangeOfString:@"("].location != NSNotFound &&
		[title rangeOfString:@")"].location != NSNotFound &&
		[title rangeOfString:@"("].location < [title rangeOfString:@")"].location)
		return [title substringToIndex:[title rangeOfString:@"(" options:NSBackwardsSearch].location];
	else
		return nil;
}

- (NSString *)replaceLastSquareBracketed:(NSString *)title
{
	if ([title rangeOfString:@"["].location != NSNotFound &&
		[title rangeOfString:@"]"].location != NSNotFound &&
		[title rangeOfString:@"["].location < [title rangeOfString:@"]"].location)
		return [title substringToIndex:[title rangeOfString:@"[" options:NSBackwardsSearch].location];
	else
		return nil;
}

@end
