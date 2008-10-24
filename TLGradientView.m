//
//  TLGradientView.m
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

#import "TLGradientView.h"

@interface TLGradientView ()

@end

@interface TLGradientView (Private)

@end

@implementation TLGradientView (Private)

@end

@implementation TLGradientView
@synthesize activeFillGradient = _activeFillGradient;
@synthesize inactiveFillGradient = _inactiveFillGradient;
@synthesize clickedGradient = _clickedGradient;
@synthesize fillAngle = _fillAngle;
@synthesize drawsHighlight = _drawsHighlight;
@synthesize drawsBorder = _drawsBorder;
@synthesize borderColor = _borderColor;
@synthesize borderSidesMask = _borderSidesMask;

- (id)initWithFrame:(NSRect)frame;
{
	if (![super initWithFrame:frame])
		return nil;
	self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916f alpha:1.0f],[NSColor colorWithCalibratedWhite:0.916f alpha:1.0f],nil]] autorelease];
	self.inactiveFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],nil]] autorelease];
	self.clickedGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.814 alpha:1.0],nil]] autorelease];
	self.fillAngle = 270.0f;
	self.borderColor = [NSColor lightGrayColor];
	self.borderSidesMask = (TLMinXEdge|TLMaxXEdge|TLMinYEdge|TLMaxYEdge);
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
	[self.activeFillGradient release];
	[self.inactiveFillGradient release];
	[self.clickedGradient release];
	[self.borderColor release];
	[super dealloc];
}

- (void)viewWillMoveToSuperview:(NSView *)superview;
{
	[super viewWillMoveToSuperview:superview];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display) name:NSWindowDidResignKeyNotification object:[superview window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display) name:NSWindowDidBecomeKeyNotification object:[superview window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display) name:NSApplicationDidBecomeActiveNotification object:NSApp];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(display) name:NSApplicationDidResignActiveNotification object:NSApp];
}

- (void)setBorderSidesMask:(TLRectEdge)mask;
{
	_borderSidesMask = mask;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect;
{
	[([[self window] isKeyWindow] ? self.activeFillGradient : self.inactiveFillGradient) drawInRect:[self bounds] angle:self.fillAngle];
	
	if (self.drawsHighlight) {
		[[NSColor colorWithCalibratedWhite:0.88f alpha:1.0f] setStroke];
		[[NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX([self bounds]), [self isFlipped] ? NSMinY([self bounds]) + 1.5f : NSMaxY([self bounds]) - 1.5f, NSWidth([self bounds]), 0.0f)] stroke];
	}
	
	if (self.drawsBorder) {
		[self.borderColor setStroke];
		NSBezierPath *border = nil;
		NSRect bounds = [self bounds];
		if (self.borderSidesMask & TLMinXEdge) {
			border = [NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(bounds) + 0.5f, NSMinY(bounds), 0.0f, NSHeight([self bounds]))];
			[border stroke];
		}			
		if (self.borderSidesMask & TLMaxXEdge) {
			border = [NSBezierPath bezierPathWithRect:NSMakeRect(NSMaxX(bounds) - 0.5f, NSMinY(bounds), 0.0f, NSHeight([self bounds]))];
			[border stroke];			
		}
		if (self.borderSidesMask & TLMinYEdge) {
			border = [NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(bounds), NSMinY(bounds) + 0.5f, NSWidth(bounds), 0.0f)];
			[border stroke];	
		}
		if (self.borderSidesMask & TLMaxYEdge) {
			border = [NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(bounds), NSMaxY(bounds) - 0.5f, NSWidth(bounds), 0.0f)];
			[border stroke];			
		}
	}

}

@end
