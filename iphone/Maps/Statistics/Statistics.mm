
#import "Statistics.h"
#include "../../../platform/settings.hpp"
#import "Flurry.h"
#import "AppInfo.h"
#import "LocalyticsSession.h"

@implementation Statistics

- (void)startSessionWithLaunchOptions:(NSDictionary *)launchOptions
{
  if (self.enabled)
  {
    [Flurry startSession:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlurryKey"]];
    [Flurry setCrashReportingEnabled:YES];
    [Flurry setSessionReportsOnPauseEnabled:NO];

    [[LocalyticsSession shared] integrateLocalytics:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LocalyticsKey"] launchOptions:launchOptions];
    [LocalyticsSession shared].enableHTTPS = YES;
  }
}

- (void)logLatitude:(double)latitude longitude:(double)longitude horizontalAccuracy:(double)horizontalAccuracy verticalAccuracy:(double)verticalAccuracy
{
  if (self.enabled)
  {
    static NSDate * lastUpdate;
    if (!lastUpdate || [[NSDate date] timeIntervalSinceDate:lastUpdate] > (60 * 60 * 3))
    {
      lastUpdate = [NSDate date];
      [Flurry setLatitude:latitude longitude:longitude horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy];
    }
  }
}

- (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
  if (self.enabled)
  {
    [Flurry logEvent:eventName withParameters:parameters];
    [[LocalyticsSession shared] tagEvent:eventName attributes:parameters];
  }
}

- (void)logEvent:(NSString *)eventName
{
  [self logEvent:eventName withParameters:nil];
}

- (void)logInAppMessageEvent:(NSString *)eventName imageType:(NSString *)imageType
{
  NSString * language = [[NSLocale preferredLanguages] firstObject];
  AppInfo * info = [AppInfo sharedInfo];
  [self logEvent:eventName withParameters:@{@"Type": imageType, @"Country" : info.countryCode, @"Language" : language, @"Id" : info.uniqueId}];
}

- (void)logProposalReason:(NSString *)reason withAnswer:(NSString *)answer
{
  NSString * screen = [NSString stringWithFormat:@"Open AppStore With Proposal on %@", reason];
  [self logEvent:screen withParameters:@{@"Answer" : answer}];
}

- (void)logApiUsage:(NSString *)programName
{
  if (programName)
    [self logEvent:@"Api Usage" withParameters: @{@"Application Name" : programName}];
  else
    [self logEvent:@"Api Usage" withParameters: @{@"Application Name" : @"Error passing nil as SourceApp name."}];
}

- (void)applicationWillResignActive
{
  [self closeLocalytics];
}

- (void)applicationWillTerminate
{
  [self closeLocalytics];
}

- (void)applicationDidEnterBackground
{
  [self closeLocalytics];
}

- (void)applicationWillEnterForeground
{
  [self resumeLocalytics];
}

- (void)applicationDidBecomeActive
{
  [self resumeLocalytics];
}

- (void)resumeLocalytics
{
  if (self.enabled)
  {
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
  }
}

- (void)closeLocalytics
{
  if (self.enabled)
  {
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
  }
}

- (id)init
{
  self = [super init];

  if (self.enabled)
    [Flurry setSecureTransportEnabled:true];

  return self;
}

- (BOOL)enabled
{
#ifdef DEBUG
  return NO;
#endif

  bool statisticsEnabled = true;
  Settings::Get("StatisticsEnabled", statisticsEnabled);

  return statisticsEnabled;
}

+ (Statistics *)instance
{
  static Statistics * instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[Statistics alloc] init];
  });
  return instance;
}

- (void)logSearchQuery:(NSString *)query
{
  m_tracker.TrackSearch([query UTF8String]);
}

@end