//
//  Constants.h
//  SabaApp
//
//  Created by Syed Naqvi on 7/14/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#ifndef SabaApp_Constants_h
#define SabaApp_Constants_h

// Event Categories
NSString *const kEventCategoryPrayerTimes		= @"Prayer Times";
NSString *const kEventCategoryWeeklySchedule	= @"Weekly Schedule";
NSString *const kEventCategoryAnnouncements		= @"Announcements";
NSString *const kEventCategoryLiveStreamFeeds   = @"LiveStreamFeeds";
NSString *const kEventCategoryLiveStreamView    = @"LiveStreamView";

// Event Labels
NSString *const kRefreshEventLabel			= @"Refresh";
NSString *const kLocationTimer              = @"LocationTimer";
NSString *const kPrayerTimesRequestLabel    = @"PrayerTimesRequst";
NSString *const kLiveStreamFeedsLabel       = @"LiveStreamFeedRequest";
NSString *const kAnnouncementsLabel         = @"EventsAndAnnouncementsRequest";

//Event Actions
NSString *const kRefreshEventActionSwiped	= @"Swiped";
NSString *const kRefreshEventActionClicked	= @"Clicked";
NSString *const kLiveStreamMajlisPlayed     = @"LiveStreamMajlisPlayed";
NSString *const kLiveStreamMajlisPaused     = @"LiveStreamMajlisPaused";

//Errors
NSString *const kPrayerTimesGetError            = @"FailedToGetPrayerTimesFromWeb";
NSString *const kErrorLocationRetrievalTimeout  = @"ErrorLocationRetrievalTimeout";
NSString *const kErrorLocationUnknown           = @"ErrorLocationUnknown";
NSString *const kErrorNoNetwork                 = @"ErrorNoNetwork";
NSString *const kErrorHijriDate                 = @"ErrorGettingHijriDate";
NSString *const kErrorAnnouncements             = @"ErrorGettingEventsAndAnnouncements";
NSString *const kErrorLiveStreamFeeds           = @"ErrorGettingLiveStreamFeeds";
NSString *const kErrorPlayingVideo              = @"ErrorPlayigVideo";

// Following are View/Screen constants
NSString *const kMainView					= @"Main View";
NSString *const kWeeklyScheduleView			= @"Weekly Schedule View";
NSString *const kAnnouncementsView			= @"Announcements View";
NSString *const kContactDirectionsView		= @"Contact and Directions View";
NSString *const kDailyProgramDetailsView	= @"Program Details View";
NSString *const kPrayerTimesView			= @"Prayer Times View";
NSString *const kLiveStreamListView         = @"LiveStreamFeeds ListView";
NSString *const kLiveStreamView             = @"LiveStream View";

#endif
