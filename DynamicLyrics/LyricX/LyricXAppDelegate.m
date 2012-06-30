//
//  LyricXAppDelegate.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import "LyricXAppDelegate.h"
#import "Constants.h"
@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Initialize application
    //Start coding at 2012-04-03 10:51 =。=
    //By Martian
    Controller = [[MainController alloc] initWithMenu:AppMenu initWithDelayItem:currentDelay];
    
    //设置默认配置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[userDefaults objectForKey:@Pref_Desktop_Text_Color]);
    if ([userDefaults objectForKey:@Pref_Desktop_Text_Color] == nil) {
        NSData *theData=[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
        [userDefaults setObject:theData forKey:@Pref_Desktop_Text_Color];
    }
    
    if ([userDefaults objectForKey:@Pref_Desktop_Background_Color] == nil) {
        NSData *theData=[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0 alpha:0.25]];
        [userDefaults setObject:theData forKey:@Pref_Desktop_Background_Color];
    }
    
    if ([userDefaults floatForKey:@Pref_Lyrics_W] <= 0)
    {
        [userDefaults setInteger:NSScreen.mainScreen.frame.size.width-300 forKey:@Pref_Lyrics_W];
    }
    
    if ([userDefaults objectForKey:@Pref_Enable_Desktop_Lyrics] == nil)
    {
        [userDefaults setBool:YES forKey:@Pref_Enable_Desktop_Lyrics];
        [userDefaults setBool:YES forKey:@Pref_Enable_MenuBar_Lyrics];
    }
}

-(IBAction)OpenAlbumfillerWindow:(id)sender
{
    if (!AlbumfillerWindow)
        AlbumfillerWindow = [[Albumfiller alloc] init];
    else {
        [AlbumfillerWindow.window makeKeyAndOrderFront:self];
        
    }
    
}

-(IBAction)OpenLyricsSearchWindow:(id)sender
{  
    //i think put the init code in app delegate may be a good idea
    SearchWindow = [[LyricsSearchWnd alloc] initWithArtist:Controller.iTunesCurrentTrack.artist initWithTitle:Controller.iTunesCurrentTrack.name];
}

-(IBAction)CopyCurrentLyrics:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:Controller.CurrentSongLyrics forType: NSStringPboardType];
}


-(IBAction)CopyTotalLRC:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:Controller.SongLyrics forType: NSStringPboardType];

}

-(IBAction)CopyTotalTextLyrics:(id)sender
{
    
    NSMutableString *s = [[NSMutableString alloc] init];
    [s setString:@""];
    for (int i = 0; i < [Controller.lyrics count]; i++) {
        [s setString:[s stringByAppendingString:[NSString stringWithFormat:@"%@\n",[[Controller.lyrics objectAtIndex:i] objectForKey:@"Content"]]]];
    }
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString: s forType: NSStringPboardType];
    [s release];
    
}

-(IBAction)WriteLyricsToiTunes:(id)sender
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s setString:@""];
    for (int i = 0; i < [Controller.lyrics count]; i++) {
        [s setString:[s stringByAppendingString:[NSString stringWithFormat:@"%@\n",[[Controller.lyrics objectAtIndex:i] objectForKey:@"Content"]]]];
    }

    Controller.iTunesCurrentTrack.lyrics = s;
    [s release];

}

-(IBAction)WriteArtwork:(id)sender
{
    NSSavePanel *saveDlg = [[NSSavePanel savePanel] autorelease];
    
    [saveDlg setTitle:@"Save Artwork"];
    
    
     
    NSString* documentsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@.tiff",Controller.iTunesCurrentTrack.name,Controller.iTunesCurrentTrack.artist];
    
    [saveDlg setNameFieldStringValue:fileName];

    [saveDlg setDirectoryURL:[NSURL URLWithString:documentsFolder]];
    [saveDlg runModal];



    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];


    NSImage *image = [[NSImage alloc] initWithData:[[[[iTunes currentTrack] artworks] objectAtIndex:0] rawData]];
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:[[saveDlg URL] path] atomically:NO];     
    [image release];
}


-(IBAction)ExportLRC:(id)sender
{
    NSSavePanel *saveDlg = [[NSSavePanel savePanel] autorelease];
    [saveDlg setTitle:@"Save Lyrics"];

    
    NSString* documentsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@.lrc",Controller.iTunesCurrentTrack.name,Controller.iTunesCurrentTrack.artist];
    
    [saveDlg setNameFieldStringValue:fileName];
    [saveDlg setDirectoryURL:[NSURL URLWithString:documentsFolder]];
    [saveDlg runModal];
        
    
    [[NSFileManager defaultManager] createFileAtPath:[[saveDlg URL] path] contents:[Controller.SongLyrics dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

-(IBAction)showPrefsWindow:(id)sender
{
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}


- (IBAction)DisabledMenuBarLyrics:(id)sender
{
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Disabled_MenuBarLyrics forKey:@"Lyrics"]];
    
}

- (IBAction)DisabledDesktopLyrics:(id)sender
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Changed_DesktopLyrics forKey:@"Lyrics"]];
}

- (IBAction)aboutDynamicLyrics:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://dynamiclyrics.project.4321.la/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)adjustLyricsDelay:(id)sender
{
    NSString *str = [[(NSMenuItem *)sender title] stringByReplacingOccurrencesOfString:@"s" withString:@""];
    
    float i = 0 - [str floatValue]; //我发现我第一次脑残了，把延迟给弄成提前了……于是为了省事直接加个 0- 吧……
    if (Controller && Controller.iTunesCurrentTrack.name) {
        Controller->LyricsDelay += i;
        
        [currentDelay setTitle:[NSString stringWithFormat:@"%@ %.2fs",NSLocalizedString(@"CurrentDelay", nil),0 - Controller->LyricsDelay]];

        [[NSUserDefaults standardUserDefaults] setFloat:Controller->LyricsDelay forKey:[NSString stringWithFormat:@"Delay%@%@",Controller.iTunesCurrentTrack.artist,Controller.iTunesCurrentTrack.name]];
            }
}
- (IBAction)resetLyricsDelay:(id)sender
{
    if (Controller && Controller.iTunesCurrentTrack.name) {
        Controller->LyricsDelay = 0 ;
        
        [currentDelay setTitle:[NSString stringWithFormat:@"%@ %.2fs",NSLocalizedString(@"CurrentDelay", nil),0 - Controller->LyricsDelay]];
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:[NSString stringWithFormat:@"Delay%@%@",Controller.iTunesCurrentTrack.artist,Controller.iTunesCurrentTrack.name]];
        
    }
}

@end
