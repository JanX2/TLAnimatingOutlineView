//
//  AppController.m
//  Created by Jonathan Dann and on 20/10/2008.
//	Copyright (c) 2008, espresso served here.
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, 
//	are permitted provided that the following conditions are met:
//
//	Redistributions of source code must retain the above copyright notice, this list 
//	of conditions and the following disclaimer.
//
//	Redistributions in binary form must reproduce the above copyright notice, this list 
//	of conditions and the following disclaimer in the documentation and/or other materials 
//	provided with the distribution.
//
//	Neither the name of the espresso served here nor the names of its contributors may be
//	used to endorse or promote products derived from this software without specific prior 
//	written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//	OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
//	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
//	IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
//	OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains code from "TLAnimatingOutlineView" by Jonathan Dann http://code.google.com/p/tlanimatingoutlineview/" will // do.

#import "AppController.h"
#import "TLAnimatingOutlineView.h"
#import "TLCollapsibleView.h"
#import "TLDisclosureBar.h"

@implementation AppController
- (void)awakeFromNib;
{
	NSSize contentSize = [_scrollView contentSize];
	TLAnimatingOutlineView *outlineView = [[[TLAnimatingOutlineView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, contentSize.width, contentSize.height)] autorelease];
	[outlineView setDelegate:self];
	[outlineView setAutoresizingMask:NSViewWidthSizable]; // should not be combined with NSviewHieghtSizable else we have incorrect scrollbar showing/hiding/sizing behaviour.
	[_scrollView setDocumentView:outlineView];
	
	id view = [outlineView addView:_detailView1 withImage:[NSImage imageNamed:NSImageNameQuickLookTemplate] label:[NSString stringWithString:@"First View"]  expanded:YES];
	TLGradientView *accessoryView = [[[TLGradientView alloc] initWithFrame:NSMakeRect(0.0, 0, 40, 18)] autorelease];
//	[[view disclosureBar] setAccessoryView:accessoryView];
	
	view = [outlineView addView:_detailView2 withImage:[NSImage imageNamed:NSImageNameInfo] label:[NSString stringWithString:@"Next View"]  expanded:YES];
	
	view = [outlineView addView:_detailView3 withImage:[NSImage imageNamed:NSImageNameNetwork] label:[NSString stringWithString:@"And again"]  expanded:NO];
	
	view = [outlineView addView:_detailView4 withImage:[NSImage imageNamed:NSImageNamePreferencesGeneral] label:[NSString stringWithString:@"Yet another"]  expanded:NO];
	
//	[self performSelector:@selector(insertionTest) withObject:nil afterDelay:4.0f];
}

- (void)frameTest;
{
	TLAnimatingOutlineView *outlineView = [_scrollView documentView];
	NSView *view = [(TLCollapsibleView *)[[outlineView subviews] objectAtIndex:0] detailView];
	NSRect frame = [view frame];
	frame.size.height += 100.0f;
	[view setFrame:frame];
}

- (void)insertionTest;
{
	TLAnimatingOutlineView *outlineView = [_scrollView documentView];
	
	NSView *customView = [[[TLGradientView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 700.0f, 300.0f)] autorelease];
	
	[outlineView insertView:customView atRow:1 withImage:nil label:@"test" expanded:NO animate:YES];
	
	[self performSelector:@selector(removalTest) withObject:nil afterDelay:4.0f];
}

- (void)removalTest;
{
	TLAnimatingOutlineView *outlineView = [_scrollView documentView];
	[outlineView removeItemAtRow:2 animate:YES];
	[self performSelector:@selector(additionTest) withObject:nil afterDelay:4.0f];
}

- (void)additionTest;
{
	TLAnimatingOutlineView *outlineView = [_scrollView documentView];
	NSView *customView = [[[TLGradientView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 700.0f, 300.0f)] autorelease];
	
	[outlineView addView:customView withImage:nil label:@"added" expanded:NO animate:NO];
	
	[self performSelector:@selector(frameTest) withObject:nil afterDelay:4.0f];
}

- (CGFloat)rowSeparation;
{
	return 1.0f;
}
@end
