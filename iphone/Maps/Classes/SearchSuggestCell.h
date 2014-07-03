
#import <UIKit/UIKit.h>
#import "SearchCell.h"

@interface SearchSuggestCell : SearchCell

@property (nonatomic, readonly) UILabel * titleLabel;
@property (nonatomic, readonly) UIImageView * iconImageView;

+ (CGFloat)cellHeight;

@end
