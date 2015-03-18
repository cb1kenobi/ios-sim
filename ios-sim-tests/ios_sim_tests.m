/**
 * Tests for ios-sim
 *
 * Copyright (c) 2015 by Appcelerator, Inc. All Rights Reserved.
 *
 * See the LICENSE file for the license on the source code in this file.
 */

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

/* README
 Before running these tests, fill out the "Config" section below.
 
 Notes:
 The test names are numbered to force them to run in a certain order (they are run alphabetically).
 */

#pragma mark - Constants

// START Config
// Xcode > Window > Devices > Simulators > Select a Simulator > copy its Identifier here
// This UDID should be for a device WITH Watch support
NSString *const confUDID = @"<UDID OF SIM WITH WATCH SUPPORT>";
// This UDID should be for a device that does NOT have Watch support (eg. iPhone 4s)
// Tests that use this const can be removed when support for iPhone 4 is dropped
NSString *const confUDIDNoWatchSupport = @"<UDID OF SIM WITH no WATCH SUPPORT>";
// This Only needs to be a non valid UDID. Leave this alone in most cases.
NSString *const confUDIDBad = @"THISISNOTAVALIDDID";
// This app should point to a valid .app that was built for simulator and has a WatchKit app.
NSString *const confPathForAppToInstall = @"<FULL PATH TO APP>";
// This file is provided in the 'ios-sim-tests' folder
NSString *const confPathForNotificationPayload = @"<FULL PATH TO NOTIFICATION PAYLOAD FILE>";
// An app that fulfills these requirements can be found here: https://dl.dropboxusercontent.com/u/7540194/Test.app.zip
// This file is named 'PushNotificationPayload.apns' and is provided in the 'ios-sim-tests' folder
// END Config

// Commands
NSString *const comShowSDKs = @"show-sdks";
NSString *const comLaunch = @"launch";
NSString *const comReset = @"reset";
NSString *const comShowSimulators = @"show-simulators";
NSString *const comShowInstalledApps = @"show-installed-apps";

// Options
NSString *const optXcodeDir = @"--xcode-dir";
NSString *const optVersion = @"--version";
NSString *const optHelp = @"--help";
NSString *const optVerbose = @"--verbose";
NSString *const optExit = @"--exit";
NSString *const optLaunchWatchApp = @"--launch-watch-app";
NSString *const optExternalDisplayType = @"--external-display-type";
NSString *const optWatchLaunchMode = @"--watch-launch-mode";
NSString *const optWatchNotificationPayload = @"--watch-notification-payload";
NSString *const optBundleId = @"--bundle-id";
NSString *const optRetina = @"--retina";
NSString *const optTall = @"--tall";
NSString *const optSim64bit = @"--sim-64bit";
NSString *const optTimeout = @"--timeout";
NSString *const optSDK = @"--sdk";
NSString *const optUDID = @"--udid";
NSString *const optfamily = @"--family";
NSString *const optUUID = @"--uuid";
NSString *const optEnv = @"--env";
NSString *const optSetEnv = @"--setenv";
NSString *const optStdOut = @"--stdout";
NSString *const optStdErr = @"--stderr";
NSString *const optArgs = @"--args";

// Args
NSString *const argExternalDisplayTypeRegular = @"watch-regular";
NSString *const argExternalDisplayTypeCompact = @"watch-compact";
NSString *const argExternalDisplayTypeBad = @"watch-bad";

NSString *const argLaunchModeDefault = @"default";
NSString *const argLaunchModeGlance = @"glance";
NSString *const argLaunchModeNotification = @"notification";

// Key Strings
NSString *const keyUsage = @"Usage:";
NSString *const keyProvideValidUDID = @"please provide a valid simulator UDID";
NSString *const keyUnableToFindSimulator = @"Unable to locate the Simulator";
NSString *const keyAppInstalled = @"App installed successfully";
NSString *const keyAppLaunched = @"App launched successfully";
NSString *const keyDoesNotSupportWatch = @"does not support Watch";

@interface ios_sim_tests : XCTestCase {
	NSString *launchPath;
}

@end

@implementation ios_sim_tests

- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.

	NSString *cwd = [[[NSFileManager alloc] init] currentDirectoryPath];
	launchPath = [cwd stringByAppendingPathComponent:@"Build/Products/Debug/ios-sim"];

	// Simulator struggles creating stdout and stderr files if we fire off the tests too quickly
	[NSThread sleepForTimeInterval:1];
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)test_0000_SetupEnsureConfigured
{
	if ([confUDID isEqualToString:@"<UDID OF SIM WITH WATCH SUPPORT>"] ||
	    [confUDIDNoWatchSupport isEqualToString:@"<UDID OF SIM WITH no WATCH SUPPORT>"] ||
	    [confPathForAppToInstall isEqualToString:@"<FULL PATH TO APP>"] ||
	    [confPathForNotificationPayload isEqualToString:@"<FULL PATH TO NOTIFICATION PAYLOAD FILE>"]) {
		XCTAssert(NO, @"Edit the config (in the test class) before running these tests.");
	}
}

- (void)test_0010_SetupEnsureAppNotAlreadyInstalled
{
	// Get the bundle id of the app
	NSBundle *appBundle = [NSBundle bundleWithPath:confPathForAppToInstall];
	NSString *appBundleID = appBundle.bundleIdentifier;

	NSArray *args = @[ comShowInstalledApps, optUDID, confUDID ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSDictionary *obj = [self parseJsonString:output];

	BOOL found = NO;
	for (NSString *appKey in obj) {
		if ([appBundleID isEqualToString:appKey]) {
			found = YES;
		}
	}
	XCTAssertFalse(found, @"The app should not be installed at this point, reset the simulator.");
}

- (void)test_1000_NoArgs
{
	// When no args provided, the usage should be printed
	NSString *keyString = keyUsage;
	NSString *output = [self outPutForiOSSimWithArgs:nil];

	BOOL found = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(found, "Should find `%@` in output", keyString);
}

- (void)test_1005_Help
{
	NSString *keyString = keyUsage;
	NSArray *args = @[ optHelp ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	BOOL found = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(found, "Should find `%@` in output", keyString);
}

- (void)test_1010_ShowSDKs
{
	NSArray *args = @[ comShowSDKs ];
	NSString *output = [self outPutForiOSSimWithArgs:args];
	// Example output
	/*
     Available iOS SDK's
     [DEBUG]  iOS 7.1
     [DEBUG]  iOS 8.1
     [DEBUG]  iOS 8.3
     */

	NSString *prefix = @"Available iOS SDK's";
	NSRange prefixRange = [output rangeOfString:prefix];
	BOOL found = (prefixRange.location != NSNotFound);
	XCTAssert(found, "Should find `%@` in output", prefix);

	NSUInteger afterPrefix = prefixRange.location + prefixRange.length;
	NSRange searchRange = NSMakeRange(afterPrefix, output.length - afterPrefix);
	NSRange sdksRange = [output rangeOfString:@"iOS " options:0 range:searchRange];
	BOOL foundSdks = (sdksRange.location != NSNotFound);
	XCTAssert(foundSdks, @"Must have at least 1 iOS SDK");
}

- (void)test_1020_ShowSimulators
{
	NSArray *args = @[ comShowSimulators, optUDID, confUDID ];
	NSString *output = [self outPutForiOSSimWithArgs:args];
	// Example output
	/*
     [
         {
             "deviceType" : "iPhone 6",
             "udid" : "EC0BD93B-F601-4C5E-8AF8-F488A879367E",
             "version" : "8.3",
             "type" : "iPhone",
             "logpath" : "\/Users\/jalter\/Library\/Logs\/CoreSimulator\/EC0BD93B-F601-4C5E-8AF8-F488A879367E",
             "name" : "iPhone 6",
             "state" : "Shutdown"
         }
     ]
     */

	if (output.length == 0) {
		// Xcode > Window > Devices > Simulators > Click the + at the bottom left to add a simulator
		XCTFail(@"Must have at least 1 iOS Simulator");
	}

	id obj = [self parseJsonString:output];

	if (![obj isKindOfClass:[NSArray class]]) {
		XCTFail(@"The result of %@ should be a json array", comShowSimulators);
	}

	if ([obj count] == 0) {
		XCTFail(@"Must have at least 1 iOS Simulator...");
	}

	for (NSDictionary *sim in obj) {
		XCTAssertNotNil(sim[@"deviceType"]);
		XCTAssertNotNil(sim[@"udid"]);
		XCTAssertNotNil(sim[@"version"]);
		XCTAssertNotNil(sim[@"type"]);
		XCTAssertNotNil(sim[@"logpath"]);
		XCTAssertNotNil(sim[@"name"]);
		XCTAssertNotNil(sim[@"state"]);
	}
}

- (void)test_1030_ShowInstalledAppsNoUDID
{
	NSArray *args = @[ comShowInstalledApps ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyProvideValidUDID;
	BOOL found = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(found, "Should find `%@` in output", keyString);
}

- (void)test_1040_ShowInstalledAppsBadUDID
{
	NSArray *args = @[ comShowInstalledApps, optUDID, confUDIDBad ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyUnableToFindSimulator;
	BOOL found = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(found, "Should find `%@` in output", keyString);
}

- (void)test_1050_ShowInstalledApps
{
	NSArray *args = @[ comShowInstalledApps, optUDID, confUDID ];
	NSString *output = [self outPutForiOSSimWithArgs:args];
	// Example output
	/*
     {
         "com.apple.mobileslideshow" : {
             "CFBundleName" : "MobileSlideShow",
             "CFBundleDisplayName" : "Photos",
             "SBAppTags" : [
             
             ],
             "CFBundleIdentifier" : "com.apple.mobileslideshow",
             "Path" : "\/Applications\/Xcode_6.3_beta_2\/Xcode-beta.app\/Contents\/Developer\/Platforms\/iPhoneSimulator.platform\/Developer\/SDKs\/iPhoneSimulator.sdk\/Applications\/MobileSlideShow.app",
             "CFBundleExecutable" : "MobileSlideShow"
         }
     }
     */

	if (output.length == 0) {
		// Even if you do not install an app, default apps sush as Photos, Safari, and Maps should be returned
		XCTFail(@"There should be at least 1 app installed on the Simulator");
	}

	id obj = [self parseJsonString:output];

	if (![obj isKindOfClass:[NSDictionary class]]) {
		XCTFail(@"The result of %@ should be a json object", comShowSimulators);
	}

	if ([[obj allKeys] count] == 0) {
		XCTFail(@"There should be a least 1 app installed...");
	}

	for (NSString *appKey in obj) {
		NSDictionary *app = obj[appKey];
		XCTAssertNotNil(app[@"CFBundleName"]);
		XCTAssertNotNil(app[@"CFBundleDisplayName"]);
		XCTAssertNotNil(app[@"SBAppTags"]);
		XCTAssertNotNil(app[@"CFBundleIdentifier"]);
		XCTAssertNotNil(app[@"Path"]);
		XCTAssertNotNil(app[@"CFBundleExecutable"]);
	}
}

- (void)test_1060_InstallApp
{
	// Get the bundle id of the app that was just installed
	NSBundle *appBundle = [NSBundle bundleWithPath:confPathForAppToInstall];
	NSString *appBundleID = appBundle.bundleIdentifier;

	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppInstalled;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1070_LaunchApp
{
	// Get the bundle id of the app that was just installed
	NSBundle *appBundle = [NSBundle bundleWithPath:confPathForAppToInstall];
	NSString *appBundleID = appBundle.bundleIdentifier;

	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1070_LaunchAppWithBundleID
{
	// Get the bundle id of the app that was just installed
	NSBundle *appBundle = [NSBundle bundleWithPath:confPathForAppToInstall];
	NSString *appBundleID = appBundle.bundleIdentifier;

	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optBundleId, appBundleID ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1080_ShowInstalledAppsAfterAppInstalled
{
	// Get the bundle id of the app that was just installed
	NSBundle *appBundle = [NSBundle bundleWithPath:confPathForAppToInstall];
	NSString *appBundleID = appBundle.bundleIdentifier;

	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppInstalled;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);

	args = @[ comShowInstalledApps, optUDID, confUDID ];
	output = [self outPutForiOSSimWithArgs:args];
	// Example output
	/*
     {
         "com.apple.mobileslideshow" : {
             "CFBundleName" : "MobileSlideShow",
             "CFBundleDisplayName" : "Photos",
             "SBAppTags" : [
             
             ],
             "CFBundleIdentifier" : "com.apple.mobileslideshow",
             "Path" : "\/Applications\/Xcode_6.3_beta_2\/Xcode-beta.app\/Contents\/Developer\/Platforms\/iPhoneSimulator.platform\/Developer\/SDKs\/iPhoneSimulator.sdk\/Applications\/MobileSlideShow.app",
             "CFBundleExecutable" : "MobileSlideShow"
         }
     }
     */

	NSDictionary *obj = [self parseJsonString:output];

	BOOL found = NO;
	for (NSString *appKey in [obj allKeys]) {
		if ([appBundleID isEqualToString:appKey]) {
			found = YES;
		}
	}
	XCTAssert(found, @"The app that was just installed should have been found");
}

#pragma mark - Watch App Features

- (void)test_1090_LaunchWatchApp
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1090_LaunchWatchAppOnSimWithoutSupport
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDIDNoWatchSupport, optExit, optLaunchWatchApp ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyDoesNotSupportWatch;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1090_LaunchWatchAppWithDisplayTypeRegular
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp, optExternalDisplayType, argExternalDisplayTypeRegular ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1090_LaunchWatchAppWithDisplayTypeCompact
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp, optExternalDisplayType, argExternalDisplayTypeCompact ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

// README: Testing options with no args will break ios-sim.
// ios-sim is not currently setup to handle this type of validation.
// This may be a good idea in the future, but not worth the time at this point.

//- (void)test_1090_LaunchWatchAppWithDisplayTypeNoArg
//{
//    NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp, optExternalDisplayType ];
//    NSString *output = [self outPutForiOSSimWithArgs:args];
//
//    NSString *keyString = @"SOME ERROR";
//    BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
//    XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
//}

- (void)test_1090_LaunchWatchAppLaunchModeDefault
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp, optWatchLaunchMode, argLaunchModeDefault ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1090_LaunchWatchAppLaunchModeGlance
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp, optWatchLaunchMode, argLaunchModeGlance ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

- (void)test_1090_LaunchWatchAppLaunchModeNotification
{
	NSArray *args = @[ comLaunch, confPathForAppToInstall, optUDID, confUDID, optExit, optLaunchWatchApp, optWatchLaunchMode, argLaunchModeNotification, optWatchNotificationPayload, confPathForNotificationPayload ];
	NSString *output = [self outPutForiOSSimWithArgs:args];

	NSString *keyString = keyAppLaunched;
	BOOL foundInstalled = ([output rangeOfString:keyString].location != NSNotFound);
	XCTAssert(foundInstalled, "Should find `%@` in output", keyString);
}

#pragma mark - Utils

- (NSString *)outPutForiOSSimWithArgs:(NSArray *)args
{
	NSTask *xcodeSelectTask = [[NSTask alloc] init];
	[xcodeSelectTask setLaunchPath:launchPath];
	if (args) {
		[xcodeSelectTask setArguments:args];
	}

	NSPipe *outputPipe = [NSPipe pipe];
	[xcodeSelectTask setStandardOutput:outputPipe];
	[xcodeSelectTask setStandardError:outputPipe];
	NSFileHandle *outputFile = [outputPipe fileHandleForReading];

	[xcodeSelectTask launch];
	NSData *outputData = [outputFile readDataToEndOfFile];
	[xcodeSelectTask terminate];

	NSString *output = [[NSString alloc] initWithData:outputData
	                                         encoding:NSUTF8StringEncoding];
	return output;
}

- (id)parseJsonString:(NSString *)str
{
	NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error;
	id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	if (error) {
		NSLog(@"Error parsing JSON: %@", error);
	}
	return obj;
}

@end
