//
//  InfoDetailedTitleButton
//  UW Info
//
//  Created by Zhang Honghao on 2/27/14.
//
//

@interface InfoDetailedTitleButton : UIButton

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;

- (InfoDetailedTitleButton *)initWithText:(NSString *)text detailText:(NSString *)detailText;
- (void)setText:(NSString *)text andDetailText:(NSString *)detailText;
- (void)setText:(NSMutableAttributedString *)attributedString;
- (void)setDetailTextWithAttributedString:(NSMutableAttributedString *)detailAttributedString;

- (void)setTitleColor:(UIColor *)titleColor detailTextColor:(UIColor *)detailColor;

@end
