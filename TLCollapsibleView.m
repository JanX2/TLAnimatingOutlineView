//
//  TLCollapsibleView.m
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

#import <Quartz/Quartz.h>
#import "TLCollapsibleView.h"
#import "TLDisclosureBar.h"
#import "TLAnimatingOutlineView.h"

@interface TLCollapsibleView ()
@property(readwrite,retain) TLDisclosureBar *disclosureBar;
@property(readwrite,assign) NSRect targetFrame;
@property(readwrite,retain) NSViewAnimation *expandAnimation;
@property(readwrite,retain) NSViewAnimation *collapseAnimation;
@end

@interface TLCollapsibleView (Private)
- (void)_expand;
- (void)_collapse;
- (NSDictionary *)_expandAnimationInfo;
- (NSDictionary *)_collapseAnimationInfo;
@end

@implementation TLCollapsibleView (Private)
- (void)_expand;
{
	if ([[self superview] isKindOfClass:[TLAnimatingOutlineView class]])
		[(TLAnimatingOutlineView *)[self superview] expandItem:self];
	else
		[self expand];
}

- (void)_collapse;
{
	if ([[self superview] isKindOfClass:[TLAnimatingOutlineView class]])
		[(TLAnimatingOutlineView *)[self superview] collapseItem:self];
	else
		[self collapse];
}

- (NSDictionary *)_expandAnimationInfo;
{
	NSRect newDetailViewFrame = [self.detailView frame];
	newDetailViewFrame.origin.y = NSMaxY([self.disclosureBar frame]);
	NSDictionary *detailViewAnimationInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.detailView,NSViewAnimationTargetKey,[NSValue valueWithRect:[self.detailView frame]],NSViewAnimationStartFrameKey,[NSValue valueWithRect:newDetailViewFrame],NSViewAnimationEndFrameKey,nil];
	
	NSRect newViewFrame = [self frame];
	newViewFrame.size.height = NSHeight([self.disclosureBar frame]) + NSHeight([self.detailView frame]);
	NSDictionary *viewAnimationInfo = [NSDictionary dictionaryWithObjectsAndKeys:self,NSViewAnimationTargetKey,[NSValue valueWithRect:[self frame]],NSViewAnimationStartFrameKey,[NSValue valueWithRect:newViewFrame],NSViewAnimationEndFrameKey,nil];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:detailViewAnimationInfo,@"detailViewAnimationInfo",viewAnimationInfo,@"viewAnimationInfo",nil];	
}

- (NSDictionary *)_collapseAnimationInfo;
{
	NSRect newDetailViewFrame = [self.detailView frame];
	newDetailViewFrame.origin.y = NSMaxY([self.disclosureBar frame]) - NSHeight([self.detailView frame]);
	NSDictionary *detailViewAnimationInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.detailView,NSViewAnimationTargetKey,[NSValue valueWithRect:[self.detailView frame]],NSViewAnimationStartFrameKey,[NSValue valueWithRect:newDetailViewFrame],NSViewAnimationEndFrameKey,nil];
	
	NSRect newViewFrame = [self frame];
	newViewFrame.size.height = NSHeight([self.disclosureBar frame]);
	NSDictionary *viewAnimationInfo = [NSDictionary dictionaryWithObjectsAndKeys:self,NSViewAnimationTargetKey,[NSValue valueWithRect:[self frame]],NSViewAnimationStartFrameKey,[NSValue valueWithRect:newViewFrame],NSViewAnimationEndFrameKey,nil];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:detailViewAnimationInfo,@"detailViewAnimationInfo",viewAnimationInfo,@"viewAnimationInfo",nil];
}

@end

@implementation TLCollapsibleView
@synthesize disclosureBar = _disclosureBar;
@synthesize detailView = _detailView;
@synthesize expanded = _expanded;
@synthesize targetFrame = _targetFrame;
@synthesize animating = _animating;
@synthesize expandAnimation = _expandAnimation;
@synthesize collapseAnimation = _collapseAnimation;

- (id)initWithFrame:(NSRect)frame;
{
	[NSException raise:NSGenericException format:@"%s is not the designated initialiser for instances of class: %@",__func__,[self className]];
	return nil;
}

- (id)initWithFrame:(NSRect)frame detailView:(NSView <TLCollapsibleDetailView> *)detailView expanded:(BOOL)expanded;
{
	if (![super initWithFrame:frame])
		return nil;
	[self setAutoresizesSubviews:YES];
	[self setAutoresizingMask:NSViewWidthSizable];
	
	NSRect disclosureBarFrame = frame;
	disclosureBarFrame.size.height = 21.0f;
	disclosureBarFrame.origin.y = 0.0f;
	self.disclosureBar = [[[TLDisclosureBar alloc] initWithFrame:disclosureBarFrame expanded:expanded] autorelease];
	[self.disclosureBar setAutoresizingMask:NSViewWidthSizable];

	NSRect detailViewFrame = [detailView frame];
	detailViewFrame.size.width = NSWidth(frame);
	detailViewFrame.origin.y = expanded ? NSMaxY(disclosureBarFrame) : NSMaxY(disclosureBarFrame) - NSHeight(detailViewFrame);
	[detailView setFrame:detailViewFrame];
	[detailView setAutoresizingMask:NSViewWidthSizable];
	self.detailView = detailView;
	
	frame.size.height = expanded ? NSHeight(disclosureBarFrame) + NSHeight(detailViewFrame) : NSHeight(disclosureBarFrame);
	[self setFrame:frame];
	self.targetFrame = frame;
	
	[self addSubview:self.detailView];
	[self addSubview:self.disclosureBar];
	
	[[self.disclosureBar disclosureButton] setAction:@selector(toggleExpansionState:)];
	[[self.disclosureBar disclosureButton] setTarget:self];
		
    return self;
}

- (NSArray *)keysForCoding;
{
	NSArray *keys = [NSArray arrayWithObjects:nil];
	if ([[[self class] superclass] instancesRespondToSelector:@selector(keysForCoding)])
		keys = [[(id)super keysForCoding] arrayByAddingObjectsFromArray:keys];
	return keys;
}

- (id)initWithCoder:(NSCoder *)coder;
{
	if (![super initWithCoder:coder])
		return nil;
	for (NSString *key in [self keysForCoding])
		[coder encodeObject:[self valueForKey:key] forKey:key];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder;
{
	for (NSString *key in [self keysForCoding])
		[self setValue:[coder decodeObjectForKey:key] forKey:key];
	[super encodeWithCoder:coder];
}

- (void)dealloc;
{
	[self.disclosureBar release];
	[self.detailView release];
	[self.expandAnimation release];
	[self.collapseAnimation release];
	[super dealloc];
}

- (BOOL)isFlipped;
{
	return YES;
}

- (BOOL)expanded;
{
	return NSMinY([self.detailView frame]) >= NSMaxY([self.disclosureBar frame]);
}

- (IBAction)toggleExpansionState:(id)sender;
{
	self.expanded ? [self _collapse] : [self _expand];
}

- (void)expand;
{
	if (self.expanded)
		return;
		
	if ([self.detailView respondsToSelector:@selector(canExpand)]) {
		if (![self.detailView canExpand])
			return;
	}
	
	if ([self.detailView respondsToSelector:@selector(viewWillExpand)])
		[self.detailView viewWillExpand];
				
	self.expandAnimation = [[[NSViewAnimation alloc] initWithViewAnimations:[[self _expandAnimationInfo] allValues]] autorelease];
	[self.expandAnimation setDuration:0.25];
	[self.expandAnimation setAnimationCurve:NSAnimationEaseInOut];
	[self.expandAnimation startAnimation];
}

- (void)collapse;
{
	if (!self.expanded)
		return;

	if ([self.detailView respondsToSelector:@selector(canCollapse)]) {
		if (![self.detailView canCollapse])
			return;
	}
		
	self.collapseAnimation = [[[NSViewAnimation alloc] initWithViewAnimations:[[self _collapseAnimationInfo] allValues]] autorelease];
	[self.collapseAnimation setDuration:0.25];
	[self.collapseAnimation setAnimationCurve:NSAnimationEaseInOut];
	[self.collapseAnimation startAnimation];
}

- (NSDictionary *)expandAnimationInfo;
{
	if (self.expanded)
		return nil;
	
	if ([self.detailView respondsToSelector:@selector(canExpand)]) {
		if (![self.detailView canExpand])
			return nil;
	}
	
	return [self _expandAnimationInfo];
}

- (NSDictionary *)collapseAnimationInfo;
{
	if (!self.expanded)
		return nil;
	
	if ([self.detailView respondsToSelector:@selector(canCollapse)]) {
		if (![self.detailView canCollapse])
			return nil;
	}
	
	return [self _collapseAnimationInfo];
}

@end

@implementation TLCollapsibleView (NSViewAnimationDelegate)
- (BOOL)animationShouldStart:(NSAnimation *)animation;
{
	self.animating = YES;
	return YES;
}

- (void)animationDidEnd:(NSAnimation *)animation;
{
	self.animating = NO;
	[[self.disclosureBar disclosureButton] setState:self.expanded ? NSOnState : NSOffState];
}

@end

