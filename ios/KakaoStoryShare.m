#import "KakaoStoryShare.h"
#import <UIKit/UIKit.h>

NSString *const StoryLinkApiVersion = @"1.0";
NSString *const StoryLinkURLBaseString = @"storylink://posting";

NSString* convertJSONString(id object) {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0
                                                         error:&error];
    if (error) {
        return @"";
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}

NSString* convertScrapTypeString(ScrapType type) {
    switch (type) {
        case ScrapTypeVideo:
            return @"video";
            
        case ScrapTypeMusic:
            return @"music";
            
        case ScrapTypeBook:
            return @"book";
            
        case ScrapTypeArticle:
            return @"article";
            
        case ScrapTypeProfile:
            return @"profile";
            
        default:
            break;
    }
    
    return @"website";
}

NSString *StringByAddingPercentEscapesForURLArgument(NSString *string) {
    NSCharacterSet *customAllowedSet = [[NSCharacterSet characterSetWithCharactersInString:@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`\n"] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:customAllowedSet];
}

NSString *HTTPArgumentsStringForParameters(NSDictionary *parameters) {
    __block NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:parameters.count];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [arguments addObject:[NSString stringWithFormat:@"%@=%@", key, StringByAddingPercentEscapesForURLArgument(obj)]];
    }];
    
    return [arguments componentsJoinedByString:@"&"];
}

@implementation ScrapInfo

- (NSString *)toJSONString {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    
    if (_title) {
        dictionary[@"title"] = _title;
    }
    
    if (_desc) {
        dictionary[@"desc"] = _desc;
    }
    
    if (_imageURLs && _imageURLs.count > 0) {
        dictionary[@"imageurl"] = _imageURLs;
    }
    
    if (_type != ScrapTypeNone) {
        dictionary[@"type"] = convertScrapTypeString(_type);
    }
    
    if (dictionary.count == 0) {
        return @"";
    }
    
    return convertJSONString(dictionary);
}

@end

@implementation KakaoStoryShare

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(post,
                 withOptions:(nonnull NSDictionary*)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    if (![KakaoStoryShare canOpenStoryLink]) {
        NSLog(@"Cannot open kakao story.");
        return;
    }
    
    NSBundle *bundle = [NSBundle mainBundle];
    ScrapInfo *scrapInfo = [[ScrapInfo alloc] init];
    scrapInfo.title = [options objectForKey:@"title"];
    scrapInfo.desc = [options objectForKey:@"desc"];
    scrapInfo.imageURLs = [options objectForKey:@"imgURLs"];
    scrapInfo.type = ScrapTypeVideo;
    
    @try {
        NSString *storyLinkURLString = [
                                        KakaoStoryShare makeStoryLinkWithPostingText:@"Sample Story Posting https://www.youtube.com/watch?v=XUX1jtTKkKs"
                                        appBundleID:[bundle bundleIdentifier]
                                        appVersion:[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                        appName:[bundle objectForInfoDictionaryKey:@"CFBundleName"]
                                        scrapInfo:scrapInfo];
        if ([KakaoStoryShare openStoryLinkWithURLString:storyLinkURLString]) {
            resolve(NULL);
        } else {
            reject(@"Check URL Scheme", NULL, NULL);
        }
    } @catch (NSException * e) {
        reject(@"failed posting", e.reason, NULL);
    }
}

+ (BOOL)canOpenStoryLink {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:StoryLinkURLBaseString]];
}

+ (NSString *)makeStoryLinkWithPostingText:(NSString *)postingText
                               appBundleID:(NSString *)appBundleID
                                appVersion:(NSString *)appVersion
                                   appName:(NSString *)appName
                                 scrapInfo:(ScrapInfo *)scrapInfo {
    if (!postingText || !appBundleID || !appVersion || !appName) {
        return nil;
    }
    
    
    NSMutableDictionary *parameters = [@{ @"post" : postingText,
                                          @"apiver" : StoryLinkApiVersion,
                                          @"appid" : appBundleID,
                                          @"appver" : appVersion,
                                          @"appname" : appName } mutableCopy];
    if (scrapInfo) {
        NSString *infoString = [scrapInfo toJSONString];
        if (infoString.length > 0) {
            parameters[@"urlinfo"] = infoString;
        }
    }
    
    NSString *parameterString = HTTPArgumentsStringForParameters(parameters);
    return [NSString stringWithFormat:@"%@?%@", StoryLinkURLBaseString, parameterString];
}

+ (BOOL)openStoryLinkWithPostingText:(NSString *)postingText
                         appBundleID:(NSString *)appBundleID
                          appVersion:(NSString *)appVersion
                             appName:(NSString *)appName
                           scrapInfo:(ScrapInfo *)scrapInfo {
    return [self openStoryLinkWithURLString:[self makeStoryLinkWithPostingText:postingText
                                                                   appBundleID:appBundleID
                                                                    appVersion:appVersion
                                                                       appName:appName
                                                                     scrapInfo:scrapInfo]];
}

+ (BOOL)openStoryLinkWithURLString:(NSString *)URLString {
    if (!URLString || URLString.length == 0) {
        NSLog(@"Story Link URL is empty.");
        return NO;
    }
    
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

@end
