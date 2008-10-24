//
//  TLAnimatingOutlineView.h
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

#import <Cocoa/Cocoa.h>

@protocol TLAnimatingOutlineViewDelegate;
@class TLCollapsibleView;
@interface TLAnimatingOutlineView : NSView <NSCoding> {
@private
	id <TLAnimatingOutlineViewDelegate> _delegate;
	BOOL _animating;
}
@property(readwrite,assign) id <TLAnimatingOutlineViewDelegate> delegate;
@property(readwrite,assign) BOOL animating;

- (TLCollapsibleView *)addView:(NSView *)detailView withImage:(NSImage *)image label:(NSString *)label expanded:(BOOL)expanded;

- (void)expandItem:(TLCollapsibleView *)item;
- (void)expandItemAtRow:(NSUInteger)row;
- (void)collapseItem:(TLCollapsibleView *)item;
- (void)collapseItemAtRow:(NSUInteger)row;

- (NSUInteger)numberOfRows;

- (TLCollapsibleView *)itemAtRow:(NSUInteger)row;
- (NSView *)detailViewAtRow:(NSUInteger)row;

- (NSUInteger)rowForItem:(TLCollapsibleView *)item;
- (NSUInteger)rowForDetailView:(NSView *)detailView;

- (BOOL)isItemExpanded:(TLCollapsibleView *)item;

@end

@protocol TLAnimatingOutlineViewDelegate
@optional
- (BOOL)outlineView:(TLAnimatingOutlineView *)outlineView shouldExpandItem:(TLCollapsibleView *)item;
- (BOOL)outlineView:(TLAnimatingOutlineView *)outlineView shouldCollapseItem:(TLCollapsibleView *)item;
- (void)outlineViewItemWillExpand:(NSNotification *)notification;
- (void)outlineViewItemDidExpand:(NSNotification *)notification;
- (void)outlineViewItemWillCollapse:(NSNotification *)notification;
- (void)outlineViewItemDidCollapse:(NSNotification *)notification;
@end

extern NSString *TLAnimatingOutlineViewItemWillExpandNotification;
extern NSString *TLAnimatingOutlineViewItemDidExpandNotification;
extern NSString *TLAnimatingOutlineViewItemWillCollapseNotification;
extern NSString *TLAnimatingOutlineViewItemDidCollapseNotification;
