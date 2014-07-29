#import "MUKUserNotificationView.h"

static CGFloat const kTextToTitleVerticalMargin = 2.0f;

@interface MUKUserNotificationView ()
@property (nonatomic, weak) UIView *bottomSeparatorView;
@end

@implementation MUKUserNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configureLabelsForCurrentState];
    [self layoutLabelsIfNeeded];
    
    // Keep separator hooked to bottom (preserving height)
    CGRect frame = self.bottomSeparatorView.frame;
    frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame);
    frame.size.width = CGRectGetWidth(self.bounds);
    self.bottomSeparatorView.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    // Width is constrained by input
    CGSize fittedSize = CGSizeMake(size.width, 0.0f);
    
    // Make sure state is updated
    [self configureLabelsForCurrentState];
    
    // Get dimensions taking into account padding
    CGSize const paddedSize = CGSizeMake(size.width - self.padding.left - self.padding.right, size.height - self.padding.top - self.padding.bottom);
    
    if (!self.titleLabel.hidden && self.textLabel.hidden) {         // 1
        fittedSize.height = self.padding.top + [self heightForTextContainedInLabel:self.titleLabel maxSize:paddedSize] + self.padding.bottom;
    }
    else if (self.titleLabel.hidden && !self.textLabel.hidden) {    // 2
        fittedSize.height = self.padding.top + [self heightForTextContainedInLabel:self.textLabel maxSize:paddedSize] + self.padding.bottom;
    }
    else if (!self.titleLabel.hidden && !self.textLabel.hidden) {   // 3
        // Title first
        CGFloat titleHeight = [self heightForTextContainedInLabel:self.titleLabel maxSize:paddedSize];
        fittedSize.height = self.padding.top + titleHeight;
        
        // Calculate remianing space
        CGSize remainingSize = paddedSize;
        remainingSize.height -= titleHeight + kTextToTitleVerticalMargin;
        
        // Then text
        fittedSize.height += kTextToTitleVerticalMargin + [self heightForTextContainedInLabel:self.textLabel maxSize:remainingSize] + self.padding.bottom;
    }
    
    return fittedSize;
}

#pragma mark - Methods

+ (UIEdgeInsets)defaultPadding {
    return UIEdgeInsetsMake(4.0f, 8.0f, 4.0f, 8.0f);
}

#pragma mark - Private

static void CommonInit(MUKUserNotificationView *me) {
    me.clipsToBounds = YES;
    [me createAndAttachGestureRecognizers];
    [me createAndInsertAllSubviews];
    me->_padding = [[me class] defaultPadding];
}

- (void)createAndAttachGestureRecognizers {
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [_tapGestureRecognizer requireGestureRecognizerToFail:_panGestureRecognizer];
    [self addGestureRecognizer:_tapGestureRecognizer];
}

- (CGFloat)heightForTextContainedInLabel:(UILabel *)label maxSize:(CGSize)maxSize
{
    CGSize size = [label sizeThatFits:maxSize];
    return fminf(size.height, maxSize.height);
}

#pragma mark - Labels

- (void)createAndInsertAllSubviews {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    UIFontDescriptor *fontDesciptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
    UIFontDescriptor *boldFontDescriptor = [fontDesciptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    label.font = [UIFont fontWithDescriptor:boldFontDescriptor size:0.0f];
    [self addSubview:label];
    _titleLabel = label;
    
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    [self addSubview:label];
    _textLabel = label;
    
    CGFloat const minDisplayableHeight = [[UIScreen mainScreen] scale] > 1.0 ? 0.5f : 1.0f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, minDisplayableHeight)];
    view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    view.userInteractionEnabled = NO;
    [self addSubview:view];
    _bottomSeparatorView = view;
}

// There are 3 configurations:
//
// 1) title only    [ ------ title ------ ]
//
// 2) text only     [ text text text text ]
//                  [ text text --------- ]
//
// 3) both title and text
//                  [ title title ------- ]
//                  [ text text text text ]
//                  [ text text --------- ]

- (void)configureLabelsForCurrentState {
    BOOL const hasTitle = [self.titleLabel.text length] > 0;
    BOOL const hasText = [self.textLabel.text length] > 0;
    
    if (hasTitle && !hasText) {         // 1
        self.titleLabel.hidden = NO;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.hidden = YES;
    }
    else if (!hasTitle && hasText) {    // 2
        self.titleLabel.hidden = YES;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.hidden = NO;
    }
    else if (hasTitle && hasText) {     // 3
        self.titleLabel.hidden = NO;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.hidden = NO;
    }
    else {
        self.titleLabel.hidden = YES;
        self.textLabel.hidden = YES;
    }
}

- (void)layoutLabelsIfNeeded {
    // Position title horizontally
    CGFloat titleHeight = 0.0f;
    if (!self.titleLabel.hidden) {
        [self.titleLabel sizeToFit];
        
        CGRect frame = self.titleLabel.frame;
        frame.origin.x = self.padding.left;
        frame.size.width = CGRectGetWidth(self.bounds) - CGRectGetMinX(frame) - self.padding.right;
        self.titleLabel.frame = frame;
        
        titleHeight = CGRectGetHeight(frame);
    }
    
    // Position text horizontally
    CGFloat textHeight = 0.0f;
    if (!self.textLabel.hidden) {
        CGRect frame = self.textLabel.frame;
        frame.origin.x = self.padding.left;
        frame.size.width = CGRectGetWidth(self.bounds) - CGRectGetMinX(frame) - self.padding.right;
        self.textLabel.frame = frame;
        [self.textLabel sizeToFit];
        
        textHeight = CGRectGetHeight(self.textLabel.frame);
    }
    
    CGFloat const maxHeight = CGRectGetHeight(self.bounds) - self.padding.top - self.padding.bottom;
    
    // Center labels vertically
    if (!self.titleLabel.hidden && self.textLabel.hidden) {         // 1
        CGRect frame = self.titleLabel.frame;
        
        CGFloat y = roundf((maxHeight - titleHeight)/2.0f) + self.padding.top;
        frame.origin.y = y;
        
        self.titleLabel.frame = frame;
    }
    else if (self.titleLabel.hidden && !self.textLabel.hidden) {    // 2
        CGRect frame = self.textLabel.frame;
        
        CGFloat y = roundf((maxHeight - textHeight)/2.0f);
        y = fmaxf(y, self.padding.top);
        
        CGFloat const maxHeight = CGRectGetHeight(self.bounds) - self.padding.top - self.padding.bottom;
        CGFloat height = fminf(maxHeight, CGRectGetHeight(frame));
        
        frame.origin.y = y;
        frame.size.height = height;
        self.textLabel.frame = frame;
    }
    else if (!self.titleLabel.hidden && !self.textLabel.hidden) {   // 3
        // Calculate total vertical occupation
        CGFloat labelsCombinatedHeight = titleHeight;
        if (textHeight > 0.0f) {
            labelsCombinatedHeight += kTextToTitleVerticalMargin + textHeight;
        }
        
        // Text label should be shrinked in height?
        if (labelsCombinatedHeight > maxHeight) {
            CGFloat diff = labelsCombinatedHeight - maxHeight;
            textHeight -= diff;
            labelsCombinatedHeight -= diff;
        }

        // Calculate paddings
        CGFloat const remainingSpace = CGRectGetHeight(self.bounds) - labelsCombinatedHeight;
        CGFloat const topPadding = fmaxf(self.padding.top, roundf(remainingSpace/2.0f));
        CGFloat const bottomPadding = remainingSpace - topPadding;
        
        // Set title frame
        CGRect frame = self.titleLabel.frame;
        frame.origin.y = topPadding;
        self.titleLabel.frame = frame;
        
        // Set text frame
        frame = self.textLabel.frame;
        frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + kTextToTitleVerticalMargin;
        frame.size.height = CGRectGetHeight(self.bounds) - CGRectGetMinY(frame) - bottomPadding;
        self.textLabel.frame = frame;
    }
}

@end
