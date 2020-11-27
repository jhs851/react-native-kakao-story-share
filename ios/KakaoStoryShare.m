#import "KakaoStoryShare.h"
#import <UIKit/UIKit.h>

NSString *const StoryLinkApiVersion = @"1.0";
NSString *const StoryLinkURLBaseString = @"storylink://posting";
NSString *const WebStoryLinkURLBaseString = @"https://story.kakao.com/s/share";

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
        @try {
            NSString *text = [NSString stringWithFormat:@"%@-%@", [options objectForKey:@"title"], [options objectForKey:@"desc"]];
            NSString *webStoryLinkURLString = [
                                            KakaoStoryShare makeWebStoryLinkWithPostingText:[options objectForKey:@"url"]
                                            text:text];
            
            if ([KakaoStoryShare openStoryLinkWithURLString:webStoryLinkURLString]) {
                return resolve(NULL);
            } else {
                return reject(@"Open web story link failed.", NULL, NULL);
            }
        } @catch (NSException * e) {
            return reject(@"Failed posting.", e.reason, NULL);
        }
    }
    
    @try {
        NSBundle *bundle = [NSBundle mainBundle];
        ScrapInfo *scrapInfo = [[ScrapInfo alloc] init];
        scrapInfo.title = [options objectForKey:@"title"];
        scrapInfo.desc = [options objectForKey:@"desc"];
        NSString *imageURL = [options objectForKey:@"imgURL"];
        if (imageURL != NULL) {
            scrapInfo.imageURLs = @[imageURL];
        }
        scrapInfo.type = ScrapTypeVideo;
        
        NSString *storyLinkURLString = [
                                        KakaoStoryShare makeStoryLinkWithPostingText:[options objectForKey:@"url"]
                                        appBundleID:[bundle bundleIdentifier]
                                        appVersion:[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                        appName:[options objectForKey:@"appName"]
                                        scrapInfo:scrapInfo];
        
        if ([KakaoStoryShare openStoryLinkWithURLString:storyLinkURLString]) {
            resolve(NULL);
        } else {
            reject(@"Open story link app failed.", NULL, NULL);
        }
    } @catch (NSException * e) {
        reject(@"Failed posting.", e.reason, NULL);
    }
}

+ (BOOL)canOpenStoryLink {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:StoryLinkURLBaseString]];
}

+ (NSString *)makeWebStoryLinkWithPostingText:(NSString *)url
                                         text:(NSString *)text {
    if (!url || !text) {
        return nil;
    }
    
    NSMutableDictionary *parameters = [@{ @"url": url, @"text": text } mutableCopy];
    NSString *parameterString = HTTPArgumentsStringForParameters(parameters);
    return [NSString stringWithFormat:@"%@?%@", WebStoryLinkURLBaseString, parameterString];
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
