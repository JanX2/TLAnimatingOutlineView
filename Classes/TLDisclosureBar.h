//
//  TLDisclosureBar.h
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
// For example, "Contains code from "TLAnimatingOutlineView" by Jonathan Dann http://code.google.com/p/tlanimatingoutlineview/" will do.

#import "TLGradientView.h"

@interface TLDisclosureBar : TLGradientView <NSCoding>{
 @private
	NSButton *_disclosureButton;
	NSImageView *_imageViewLeft;
	NSTextField *_labelField;
	NSView *_accessoryView;
}

@property(readonly,retain) NSImageView *imageViewLeft;
@property(readonly,retain) NSButton *disclosureButton;
@property(readonly,retain) NSTextField *labelField;

// Setting the accessory view will cause the removal of the current one from the view heirarchy. The new view will have its autoresizing mask amended with NSMinXMargin if it isn't set already.
@property(readwrite,retain) NSView *accessoryView;
@property(readwrite,assign) BOOL hasDisclosureButton;

- (id)initWithFrame:(NSRect)frame expanded:(BOOL)expanded;
- (id)initWithFrame:(NSRect)frame leftImage:(NSImage *)leftImage label:(NSString *)label expanded:(BOOL)expanded;
- (void)setLeftImage:(NSImage *)image;
- (void)setLabel:(NSString *)label;
- (NSString *)label;

@end
