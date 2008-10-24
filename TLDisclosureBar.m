//
//  TLDisclosureBar.m
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

#import "TLDisclosureBar.h"
#import "TLEmbossedTextFieldCell.h"

@interface TLDisclosureBar ()
@property(readwrite,retain) NSButton *disclosureButton;
@property(readwrite,retain) NSImageView *imageViewLeft;
@property(readwrite,retain) NSImageView *imageViewRight;
@property(readwrite,retain) NSTextField *labelField;
@end

@interface TLDisclosureBar (Private)

@end

@implementation TLDisclosureBar (Private)

@end

@implementation TLDisclosureBar
@synthesize disclosureButton = _disclosureButton;
@synthesize imageViewLeft = _imageViewLeft;
@synthesize imageViewRight = _imageViewRight;
@synthesize labelField = _labelField;

- (id)initWithFrame:(NSRect)frame;
{
	[NSException raise:NSGenericException format:@"%s is not the designated initialiser for instances of class: %@",__func__,[self className]];
	return nil;
}

#define TL_DISCLOSURE_BAR_SUBVIEW_SPACING 8.0f

- (id)initWithFrame:(NSRect)frame expanded:(BOOL)expanded;
{
	if (![super initWithFrame:frame])
		return nil;
	
	self.drawsBorder = YES;
	self.borderSidesMask = (TLMinYEdge|TLMaxYEdge);

	[self setAutoresizesSubviews:YES];
	[self setAutoresizingMask:NSViewWidthSizable];
	
	self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.814 alpha:1.0],nil]] autorelease];
	
	NSRect disclosureFrame = frame;
	disclosureFrame.origin.x += 8.0f;
	disclosureFrame.size.width = 10.0f;
	self.disclosureButton = [[[NSButton alloc] initWithFrame:disclosureFrame] autorelease];
	[self.disclosureButton setButtonType:NSOnOffButton];
	[self.disclosureButton setBezelStyle:NSDisclosureBezelStyle];
	[self.disclosureButton setTitle:@""];
	[self.disclosureButton setFocusRingType:NSFocusRingTypeNone];
	[self.disclosureButton setState:expanded ? NSOnState : NSOffState];
	[self addSubview:self.disclosureButton];
		
	NSRect imageViewLeftFrame = disclosureFrame;
	imageViewLeftFrame.origin.x = NSMaxX(imageViewLeftFrame) + TL_DISCLOSURE_BAR_SUBVIEW_SPACING;
	imageViewLeftFrame.size.width = NSHeight(imageViewLeftFrame);
	imageViewLeftFrame = NSInsetRect(imageViewLeftFrame, 0.0f, 1.5f);
	self.imageViewLeft = [[[NSImageView alloc] initWithFrame:imageViewLeftFrame] autorelease];
	[self.imageViewLeft setEditable:NO];
	[self.imageViewLeft setAnimates:YES];
	[self.imageViewLeft setImageFrameStyle:NSImageFrameNone];
	[self.imageViewLeft setImageScaling:NSImageScaleProportionallyDown];
	[self.imageViewLeft setAllowsCutCopyPaste:NO];
	[self.imageViewLeft setImageAlignment:NSImageAlignCenter];
	[self addSubview:self.imageViewLeft];
	
	NSRect imageViewRightFrame = frame;
	imageViewRightFrame.origin.x = NSMaxX(imageViewRightFrame) - TL_DISCLOSURE_BAR_SUBVIEW_SPACING - NSHeight(imageViewRightFrame);
	imageViewRightFrame.size.width = NSHeight(imageViewRightFrame);
	imageViewRightFrame.origin.y -= 1.0f;
	self.imageViewRight = [[[NSImageView alloc] initWithFrame:imageViewRightFrame] autorelease];
	[self.imageViewRight setEditable:NO];
	[self.imageViewRight setAnimates:YES];
	[self.imageViewRight setImageFrameStyle:NSImageFrameNone];
	[self.imageViewRight setImageScaling:NSImageScaleProportionallyDown];
	[self.imageViewRight setAllowsCutCopyPaste:NO];
	[self.imageViewRight setImageAlignment:NSImageAlignCenter];
	[self.imageViewRight setAutoresizingMask:NSViewMinXMargin];
	[self addSubview:self.imageViewRight];
	
	
	NSRect labelRect = imageViewLeftFrame;
	labelRect.origin.x = NSMaxX(imageViewLeftFrame) + TL_DISCLOSURE_BAR_SUBVIEW_SPACING;
	labelRect.size.width = 0.0f;
	self.labelField = [[[NSTextField alloc] initWithFrame:labelRect] autorelease];
	[self.labelField setEditable:NO];
	[self.labelField setBezeled:NO];
	[self.labelField setDrawsBackground:NO];
	[self.labelField setTextColor:[NSColor blackColor]];
	[self.labelField setCell:[[[TLEmbossedTextFieldCell alloc] initTextCell:@""] autorelease]];
	[[self.labelField cell] setControlSize:NSSmallControlSize];
	[[self.labelField cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:[[self.labelField cell] controlSize]]]];
	[[self.labelField cell] setWraps:NO];
	[[self.labelField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[self addSubview:self.labelField];
	
	return self;
}

- (id)initWithFrame:(NSRect)frame leftImage:(NSImage *)leftImage rightImage:(NSImage *)rightImage label:(NSString *)label expanded:(BOOL)expanded;
{
	if (![self initWithFrame:frame expanded:expanded])
		return nil;
	[self setLeftImage:leftImage];
	[self setRightImage:rightImage];
	[self setLabel:label];
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
	[self.disclosureButton release];
	[self.imageViewLeft release];
	[self.imageViewRight release];
	[self.labelField release];
	[super dealloc];
}

- (void)setLeftImage:(NSImage *)image;
{
	[self.imageViewLeft setImage:image];
}

- (void)setRightImage:(NSImage *)image;
{
	[self.imageViewRight setImage:image];
}

- (void)setLabel:(NSString *)label;
{
	NSSize size = [label sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]],NSFontAttributeName,nil]];
	NSRect frame = [self.labelField frame];
	frame.size.width = size.width + 10;
	frame.size.height = size.height;
	frame.origin.y = NSMidY([self frame]) - size.height / 2.0;
	[self.labelField setFrame:frame];
	[self.labelField setStringValue:label];
}

- (void)mouseDown:(NSEvent *)event;
{
	[super mouseDown:event];
	self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.83f alpha:1.0f],nil]] autorelease];
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event;
{
	[super mouseUp:event];
	self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.814 alpha:1.0],nil]] autorelease];
	
	NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	if (NSMouseInRect(mouseLocation, [self bounds], [self isFlipped]))	
		[self.disclosureButton sendAction:[self.disclosureButton action] to:[self.disclosureButton target]];	
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event;
{
	NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
	if (NSMouseInRect(mouseLocation, [self bounds], [self isFlipped]))
		self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.83f alpha:1.0f],nil]] autorelease];
	else
		self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.814 alpha:1.0],nil]] autorelease];		
	[self setNeedsDisplay:YES];
	
}

- (void)rightMouseDown:(NSEvent *)event;
{
	[super rightMouseDown:event];
}

@end
