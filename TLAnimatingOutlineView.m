//
//  TLAnimatingOutlineView.m
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
#import "TLAnimatingOutlineView.h"
#import "TLCollapsibleView.h"
#import "TLDisclosureBar.h"

NSString *TLAnimatingOutlineViewItemWillExpandNotification = @"TLAnimatingOutlineViewItemWillExpandNotification";
NSString *TLAnimatingOutlineViewItemDidExpandNotification = @"TLAnimatingOutlineViewItemDidExpandNotification";
NSString *TLAnimatingOutlineViewItemWillCollapseNotification = @"TLAnimatingOutlineViewItemWillCollapseNotification";
NSString *TLAnimatingOutlineViewItemDidCollapseNotification = @"TLAnimatingOutlineViewItemDidCollapseNotification";

@interface TLAnimatingOutlineView ()

@end

@interface TLAnimatingOutlineView (Private)
- (void)_updateDisclosureBarBorders;
- (void)_sizeToFit;
- (void)_animateSubviewsWithAnimationInfo:(NSDictionary *)info;
- (void)_postWillExpandNotificationWithItem:(TLCollapsibleView *)item;
- (void)_postDidExpandNotificationWithItem:(TLCollapsibleView *)item;
- (void)_postWillCollapseNotificationWithItem:(TLCollapsibleView *)item;
- (void)_postDidCollapseNotificationWithItem:(TLCollapsibleView *)item;
- (void)_removeDelegateAsObserver;
@end

@implementation TLAnimatingOutlineView (Private)
- (void)_updateDisclosureBarBorders;
{
	if ([[self subviews] count] <= 1)
		return;
	NSUInteger index = 1;
	for (index ; index < [[self subviews] count] ; index ++) {
		TLCollapsibleView *subview = [[self subviews] objectAtIndex:index];
		TLCollapsibleView *precedingView = [[self subviews] objectAtIndex:index - 1];
		[[subview disclosureBar] setBorderSidesMask:precedingView.expanded ? (TLMinYEdge|TLMaxYEdge) : ([[subview disclosureBar] isFlipped] ? TLMaxYEdge : TLMinYEdge)];
	}
}

- (void)_sizeToFit;
{
	if ([[self subviews] count] == 0)
		return;
	
	NSRect newViewFrame = [self frame];
	newViewFrame.size.height = 0.0f;
	for (TLCollapsibleView *subview in [self subviews])
		newViewFrame.size.height += NSHeight([subview frame]);
	[self setFrame:newViewFrame];
}

- (void)_animateSubviewsWithAnimationInfo:(NSDictionary *)info;
{
	if (self.animating)
		return;
	
	TLCollapsibleView *animatingSubview = [[info objectForKey:TLCollapsibleViewAnimationInfoKey] objectForKey:NSViewAnimationTargetKey];
	NSRect animatingSubviewEndFrame = [[[info objectForKey:TLCollapsibleViewAnimationInfoKey] objectForKey:NSViewAnimationEndFrameKey] rectValue];
	
	NSMutableArray *allAnimationInfo = [NSMutableArray arrayWithObjects:[info objectForKey:TLCollapsibleViewAnimationInfoKey],[info objectForKey:TLCollapsibleViewDetailViewAnimationInfoKey],nil];
	
	NSUInteger indexOfAnimatingSubview = [[self subviews] indexOfObject:animatingSubview];
	NSUInteger index = indexOfAnimatingSubview + 1;
	NSRect newPrecedingViewFrame = animatingSubviewEndFrame;
	for (index ; index < [[self subviews] count] ; index++) {
		NSView *subview = [[self subviews] objectAtIndex:index];
		NSRect newSubviewFrame = [subview frame];
		newSubviewFrame.origin.y = NSMaxY(newPrecedingViewFrame);
		NSDictionary *subviewAnimationInfo = [NSDictionary dictionaryWithObjectsAndKeys:subview,NSViewAnimationTargetKey,[NSValue valueWithRect:[subview frame]],NSViewAnimationStartFrameKey,[NSValue valueWithRect:newSubviewFrame],NSViewAnimationEndFrameKey,nil];
		[allAnimationInfo addObject:subviewAnimationInfo];
		newPrecedingViewFrame = newSubviewFrame;
	}
	
	// If we're expanding, we temporarily change our frame's height to that of the NSClip view (if we're in a scroll view) so the subviews drawings aren't clipped as they move down the screen. Our frame's size is finalised after the animation is complete. We only expand as far as the content height for two reasons: 1) drawing is limited to the NSClip view's bounds anyway 2) scrollbar's appear juddery if we expand to the full neccessary height to encompass the expanded views from a height that is less than the clip view's height.
	if ([[info objectForKey:TLCollapsibleViewAnimationTypeKey] unsignedIntValue] == TLCollapsibleViewExpansionAnimation) {
		if ([self enclosingScrollView]) {
			NSSize contentSize = [[self enclosingScrollView] contentSize];
			NSRect tempFrame = [self frame];
			tempFrame.size.height = MAX(tempFrame.size.height,contentSize.height); // only set out frame to the content's height if the current frame is less than the content's height.
			[self setFrame:tempFrame];
		}
	}
	
	NSViewAnimation *animation = [[[NSViewAnimation alloc] initWithViewAnimations:allAnimationInfo] autorelease];
	[animation setDuration:0.25];
	[animation setDelegate:self];
	[animation setAnimationCurve:NSAnimationEaseInOut];
	[animation startAnimation];
}

- (void)_postWillExpandNotificationWithItem:(TLCollapsibleView *)item;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TLAnimatingOutlineViewItemWillExpandNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:item,@"NSObject",nil]];	
}

- (void)_postDidExpandNotificationWithItem:(TLCollapsibleView *)item;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TLAnimatingOutlineViewItemDidExpandNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:item,@"NSObject",nil]];	
}

- (void)_postWillCollapseNotificationWithItem:(TLCollapsibleView *)item;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TLAnimatingOutlineViewItemWillCollapseNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:item,@"NSObject",nil]];	
}

- (void)_postDidCollapseNotificationWithItem:(TLCollapsibleView *)item;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TLAnimatingOutlineViewItemDidCollapseNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:item,@"NSObject",nil]];	
}

- (void)_removeDelegateAsObserver;
{
	// we explicitly remove the delegate as observer of these notifications, else we potentially remove it from observing those that the client code has set up.
	[[NSNotificationCenter defaultCenter] removeObserver:self.delegate name:TLAnimatingOutlineViewItemWillExpandNotification object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.delegate name:TLAnimatingOutlineViewItemDidExpandNotification object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.delegate name:TLAnimatingOutlineViewItemWillCollapseNotification object:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self.delegate name:TLAnimatingOutlineViewItemDidCollapseNotification object:self];	
}

@end

@implementation TLAnimatingOutlineView
@synthesize delegate = _delegate; // assigned
@synthesize animating = _animating;

- (id)initWithFrame:(NSRect)frame;
{
	if (![super initWithFrame:frame])
		return nil;
    return self;
}

- (NSArray *)keysForCoding;
{
	return [NSArray arrayWithObjects:nil];
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
	[self _removeDelegateAsObserver];
	[super dealloc];
}

- (BOOL)isFlipped;
{
	return YES;
}

- (void)setDelegate:(id <TLAnimatingOutlineViewDelegate>)delegate;
{
	if (_delegate == delegate)
		return;
	[self _removeDelegateAsObserver];
	_delegate = delegate;
	
	if ([(id)_delegate respondsToSelector:@selector(outlineViewItemWillExpand:)])
		[[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(outlineViewItemWillExpand:) name:TLAnimatingOutlineViewItemWillExpandNotification object:self];
	if ([(id)_delegate respondsToSelector:@selector(outlineViewItemDidExpand:)])
		[[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(outlineViewItemWillExpand:) name:TLAnimatingOutlineViewItemDidExpandNotification object:self];
	if ([(id)_delegate respondsToSelector:@selector(outlineViewItemWillCollapse:)])
		[[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(outlineViewItemWillExpand:) name:TLAnimatingOutlineViewItemWillCollapseNotification object:self];
	if ([(id)_delegate respondsToSelector:@selector(outlineViewItemDidCollapse:)])
		[[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(outlineViewItemWillExpand:) name:TLAnimatingOutlineViewItemDidCollapseNotification object:self];
}

- (TLCollapsibleView *)addView:(NSView *)detailView withImage:(NSImage *)image label:(NSString *)label expanded:(BOOL)expanded;
{
	NSRect itemFrame = [self frame];
	itemFrame.size.height = NSHeight([detailView frame]); // the initialiser of TLCollapsibleView reserves the right to increase the height of the view to include the disclosure bar frame
	if ([[self subviews] count] != 0)
		itemFrame.origin.y = NSMaxY([[[self subviews] lastObject] frame]);
	
	TLCollapsibleView *item = [[[TLCollapsibleView alloc] initWithFrame:itemFrame detailView:detailView expanded:expanded] autorelease];
	[[item disclosureBar] setLabel:label];
	[[item disclosureBar] setLeftImage:image];
	
	[self addSubview:item];
	
	[self _updateDisclosureBarBorders];
	[self _sizeToFit];	
	
	return item;
}

- (BOOL)isItemExpanded:(TLCollapsibleView *)item;
{
	return item.expanded;
}

- (void)expandItem:(TLCollapsibleView *)item;
{
	if (self.animating)
		return;
	
	BOOL shouldExpand = NO;	
	if (![(id)self.delegate respondsToSelector:@selector(outlineView:shouldExpandItem:)])
		shouldExpand = YES;
	else
		shouldExpand = [self.delegate outlineView:self shouldExpandItem:item];
	
	if (!shouldExpand)
		return;
	
	NSDictionary *animationInfo = [item expandAnimationInfo];
	if(!animationInfo)
		return;
	[self _postWillExpandNotificationWithItem:item];
	[self _animateSubviewsWithAnimationInfo:animationInfo];
}

- (void)collapseItem:(TLCollapsibleView *)item;
{
	if (self.animating)
		return;
	
	BOOL shouldCollapse = NO;	
	if (![(id)self.delegate respondsToSelector:@selector(outlineView:shouldCollapseItem:)])
		shouldCollapse = YES;
	else
		shouldCollapse = [self.delegate outlineView:self shouldCollapseItem:item];
	
	if (!shouldCollapse)
		return;
	
	NSDictionary *animationInfo = [item collapseAnimationInfo];
	if(!animationInfo) // the TLCollapsibleView will also ask the detail view if it can expand/collapse.
		return;
	[self _postWillCollapseNotificationWithItem:item];	
	[self _animateSubviewsWithAnimationInfo:animationInfo];
}

- (NSUInteger)numberOfRows;
{
	return [[self subviews] count];
}

- (void)expandItemAtRow:(NSUInteger)row;
{
	[self expandItem:[self itemAtRow:row]];
}

- (void)collapseItemAtRow:(NSUInteger)row;
{
	[self collapseItem:[self itemAtRow:row]];
}

- (TLCollapsibleView *)itemAtRow:(NSUInteger)row;
{
	if ([[self subviews] count] > row)
		return [[self subviews] objectAtIndex:row];
	return nil;
}

- (NSView *)detailViewAtRow:(NSUInteger)row;
{
	return [[self itemAtRow:row] detailView];
}

- (NSUInteger)rowForItem:(TLCollapsibleView *)item;
{
	return [[self subviews] indexOfObjectIdenticalTo:item];
}

- (NSUInteger)rowForDetailView:(NSView *)detailView;
{
	return [[[self subviews] valueForKey:@"detailView"] indexOfObjectIdenticalTo:detailView];
}

@end

@implementation TLAnimatingOutlineView (NSViewAnimationDelegate)
- (BOOL)animationShouldStart:(NSAnimation *)animation;
{
	self.animating = YES;
	[[self subviews] makeObjectsPerformSelector:@selector(setAnimating:) withObject:[NSNumber numberWithBool:YES]];
	return YES;
}

- (void)animationDidEnd:(NSAnimation *)animation;
{
	self.animating = NO;
	[[self subviews] makeObjectsPerformSelector:@selector(setAnimating:) withObject:[NSNumber numberWithBool:NO]];
	
	// get the view that was collapsed/expanded
	TLCollapsibleView *toggledView = [[[(NSViewAnimation *)animation viewAnimations] objectAtIndex:0] objectForKey:NSViewAnimationTargetKey];
	
	if ([(id)self.delegate respondsToSelector:toggledView.expanded ? @selector(outlineViewItemDidExpand:) : @selector(outlineViewItemDidCollapse:)])
		toggledView.expanded ? [self _postDidExpandNotificationWithItem:toggledView] : [self _postDidCollapseNotificationWithItem:toggledView];
	if ([toggledView.detailView respondsToSelector:toggledView.expanded ? @selector(viewDidExpand) : @selector(viewDidExpand)])
		toggledView.expanded ? [toggledView.detailView viewDidExpand] : [toggledView.detailView viewDidCollapse];
	[[toggledView.disclosureBar disclosureButton] setState:toggledView.expanded ? NSOnState : NSOffState];
	
	[self _updateDisclosureBarBorders];
	[self _sizeToFit];
	
	NSRect newViewFrame = [self frame];
	newViewFrame.size.width = [[self enclosingScrollView] contentSize].width;
	[self setFrame:newViewFrame];
	
}

@end
