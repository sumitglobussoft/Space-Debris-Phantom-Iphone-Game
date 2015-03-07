//
//  ImageViewCustomCell.m
//  Anypic
//
//  Created by Globussoft 1 on 9/2/14.
//
//

#import "ImageViewCustomCell.h"
@implementation ImageViewCustomCell
@synthesize imageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"name.png"]];
        self.imageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
              
        [self.contentView addSubview:self.imageView];
        
      self.textLabel=[[UILabel alloc]initWithFrame:CGRectMake(40,0,100, 40)];
    
          self.textLabel.font=[UIFont fontWithName:@"Helvetica" size:10];
//           self.textLabel.textAlignment=NSTextAlignmentNatural;
         self.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
           self.textLabel.numberOfLines=0;
         self.textLabel.backgroundColor=[UIColor clearColor];
        [self.textLabel setTextColor:[UIColor whiteColor]];
                  
          [self.contentView addSubview:self.textLabel];
//        self.checkButton=[[UIImageView alloc] initWithFrame:CGRectMake(100.0, 10.0, 20.0, 20.0)];
//        [self.contentView addSubview:self.checkButton];

        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
