#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>


// more information : http://www.kakao.com/services/api/story_link

typedef NS_ENUM(NSInteger, ScrapType) {
    ScrapTypeNone = 0,
    ScrapTypeWebsite,
    ScrapTypeVideo,
    ScrapTypeMusic,
    ScrapTypeBook,
    ScrapTypeArticle,
    ScrapTypeProfile
};

@interface ScrapInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSArray *imageURLs;
@property (nonatomic, assign) ScrapType type;

@end

@interface KakaoStoryShare : NSObject <RCTBridgeModule>

+ (BOOL)canOpenStoryLink;

+ (NSString *)makeStoryLinkWithPostingText:(NSString *)postingText
                               appBundleID:(NSString *)appBundleID
                                appVersion:(NSString *)appVersion
                                   appName:(NSString *)appName
                                 scrapInfo:(ScrapInfo *)scrapInfo;

+ (BOOL)openStoryLinkWithPostingText:(NSString *)postingText
                         appBundleID:(NSString *)appBundleID
                          appVersion:(NSString *)appVersion
                             appName:(NSString *)appName
                           scrapInfo:(ScrapInfo *)scrapInfo;

+ (BOOL)openStoryLinkWithURLString:(NSString *)URLString;

@end
