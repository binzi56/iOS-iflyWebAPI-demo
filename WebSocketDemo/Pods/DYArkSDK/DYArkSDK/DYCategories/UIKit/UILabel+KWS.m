#import "UILabel+KWS.h"

@implementation UILabel (KWSSafeSize)

- (CGSize)safeSizeThatFits:(CGSize)size
{
    CGSize safeSize = [self sizeThatFits:size];
    if (!isnormal(safeSize.width)) {
        safeSize.width = 0.0;
    }
    return safeSize;
}

@end
