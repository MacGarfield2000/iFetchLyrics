//
//  MusixmatchFetcher.m
//  iFetchLyrics
//
//  Public Domain
//

#import "MusixmatchFetcher.h"

@implementation MusixmatchFetcher

- (NSString *)__fetchLyricsForArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title {
	sleep(RandomFloatBetween(0.5,1.5));
	NSString *urlStr = [[[[NSString stringWithFormat:@"https://www.musixmatch.com/lyrics/%@/%@", artist, title] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	NSURL *url = [NSURL URLWithString:urlStr];
    
    NSString* userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Safari/604.1.38";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    NSString *cont;
    [NSString stringEncodingForData:data encodingOptions:nil convertedString:&cont usedLossyConversion:nil];

	if ([cont rangeOfString:@"mxm-lyrics__content"].location == NSNotFound || [cont rangeOfString:@"Lyrics not available"].location != NSNotFound) {
		return nil;
	}

	@try {
		NSString *start = [cont substringFromIndex:[cont rangeOfString:@"mxm-lyrics__content"].location+22];
		NSString *end = [start componentsSeparatedByString:@"</p>"][0];
        NSString *start2 = [start substringFromIndex:[start rangeOfString:@"mxm-lyrics__content"].location+22];
        NSString *end2 = [start2 componentsSeparatedByString:@"</p>"][0];
        
        NSString *final = [end stringByAppendingString:end2];


		NSString *final1 = [final stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if ([final1 length] == 0)
			return nil;

		return final1;

	} @catch (id e) {
		return nil;
	}
}
@end
