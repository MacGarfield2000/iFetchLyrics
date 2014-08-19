//
//  WikiaFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "WikiaFetcher.h"

@implementation WikiaFetcher

// 88% succ 9905 fail 1328
- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	NSString *urlStr = [[[NSString stringWithFormat:@"http://lyrics.wikia.com/%@:%@", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
	NSString *cont = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
	if ([cont rangeOfString:@"<div class='lyricbox'>"].location == NSNotFound) {
		return nil;
	}
	else if ([cont rangeOfString:@"<a href=\"/Category:Instrumental\" title=\"Instrumental\"><img alt=\"TrebleClef\""].location != NSNotFound) {
		return @"[Instrumental]";
	}

	@try {
		NSString *newline = [cont stringByReplacingOccurrencesOfString:@"<br />" withString:@"XYZNEWLINE"];
		NSArray *comp = [newline componentsSeparatedByString:@"<div class='lyricbox'>"];
		NSString *start;
		if ([comp count] == 4)
			start = comp[2];
		else
			start = comp[1];
		NSString *start2 = [start componentsSeparatedByString:@"</div>"][1];
		NSString *end = [start2 componentsSeparatedByString:@"<div class='rtMatcher'>"][0];
		NSString *final = [end stringByConvertingHTMLToPlainText];
		NSString *final2 = [final stringByReplacingOccurrencesOfString:@"XYZNEWLINE" withString:@"\n"];
		final2 = [final2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final2 length] == 0)
			return nil;


		return final2;
	} @catch (id e) {
		return nil;
	}
}

//	NSString *u =	[[NSString stringWithFormat:@"http://lyrics.wikia.com/Special:Search?ns0=1&ns220=1&search=%@ %@", artist, title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:u]];

@end