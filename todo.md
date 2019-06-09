# All the things I should probably get done at some point, sorted arbitrarily

## Features
- User-defined lists
- Trip Reports
- Geo-fencing notifications
- Today in History
- Themeparks API
- News Feed
- Tab Redesign

## Changes
- Better multi-select support for adding attractions
- Completely different check-in UI (get rid of the pop-up)
 
## Bugs
- Weird issue with web-fetching and parsing when handling some iOS data
  \- make parsing more robust in all cases
 
## Notes from iOS
- Fix Font Size depending on phone size
- Increase tap icon area for experience
- Make multiple modified by (don't mess with it when submitting /
  modifying thing)
  -  IOS doesn't follow this behavior, ignore for now
 
- Haptic - Increment thing (maybe)
- Lat/Long submission UI needs total redo
- Link to copyright info for each copyright type
- Adding default null attraction type
- Firebase Analytics "Add New Attraction" event for checking off an
  attraction for the first time.

- Text Pop-up for parks without attractions
- Models & Manufacturers IDs and drop-downs
- Increase satisfaction of incrementing attractions.


## UI2
- Independent navigation for each page/tab ✔
- Icon / Behavior switching for home button
  -   Smooth animations? Animated Icon transitions?
- Tie park & user data to newhome, removing from the parks_home
- Tab Functionality
  - News
    -  Add functionality to webfetcher
    -  Add functionality to FirebaseDB Manager
    -  Create UI
  - Stats
    -  Link UI page to stats
  - Home
    -  New parks UI
    -  New attractions UI
    -  Add navigation
    -  New Search UI
    -  Addition of Attractions ✔
    -  Main page UI ✔
  - Lists
    - Add Lists
  - Settings / Preferences
    - Add settings
    - Add logout button / account details
- Cross-fade animations/transitions

# Complete

 - Active = 2 is "To Be Opened" ✔
 - Add DateOpen values to toBeOpenAttractions ✔
   - YYYY-MM-DD✔
 - Opening Dates - "Opening Soon" toggle, opening date mandatory field ✔
-  The only thing left to do: Display upcoming attractions differently
   on the main page ✔
 - New Line-break structure on Former Names, additional contributors, Inactive Years ✔
 - Search on former names (park & attraction) ✔
 - Search on ride ID or attraction ID ✔
 - Add close button to the park settings page ✔
 - Fix issue with ignoring attractions you've been on ✔
 - Grey out header instead of the whole tile for excluded ✔
-  Show defunct / seasonal attractions that are checked off regardless
   of setting ✔
 - Look at recentering pie chart ✔
-  Sort "Add Parks" Alphabetically ✔
 - Defunct parks shouldn't have the option to hide defunct attractions ✔
 - User Submission (**REQUIRED FOR FULL LAUNCH**)
    - Submission of new attractions ✔ (add opening soon)
    - Submission of new parks ✔ Location Search for location tag thing
  (After Launch thing)
    - Propose changes to attractions ✔
  -   Submit images for attractions ✔
 - Attraction Site
  -   Is partner site, display "via {formatted url}" ✔
-  Search on initials (park) ✔
- Upcoming attraction ✔

## Version 0.5.3
- Ignore defunct toggle setting for defunct parks ✔
- Switch tally to be default ✔

## Version 0.6.0
- Fix passing reference ✔
- Add inversions / Addl Contributors to the attraction modification page
  ✔
- Change date display to words ✔
- Show defunct attractions despite setting when searching ✔
- Show defunct attractions counter regardless of setting with data ✔
- New UI for lists of things in user submission ✔
- Search should show defunct and seasonal regardless of setting ✔
- Fill on upcoming attraction should be white ✔
- Photo icon on attraction subtitles ✔
- Opening/Closing date/year together. ✔
- Submission entries have proper automatic capitalization ✔
- Eliminate Favorites Section (Sorted Alphabetically) ✔

## Version 0.6.1
- Fixed issue with calculating user statistics