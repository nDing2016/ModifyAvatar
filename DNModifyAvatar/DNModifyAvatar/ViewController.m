//
//  ViewController.m
//  DNModifyAvatar
//
//  Created by nanding on 17/9/1.
//  Copyright © 2017年 nD. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
//#import <Photos/Photos.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIImagePickerController *imagePickerCtl;


@end

@implementation ViewController
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"修改头像";
    
        
}

#pragma mark - 懒加载
-(UIImagePickerController *)imagePickerCtl
{
    if (!_imagePickerCtl) {
        
        _imagePickerCtl = [[UIImagePickerController alloc] init];
        _imagePickerCtl.delegate = self;
    }
    return _imagePickerCtl;
}


#pragma mark - tap

- (IBAction)tapAvatar:(id)sender {
    
    
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self takePhoto];
        
    }];
    [alertCtl addAction:takePhoto];
    
    
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self localPhoto];
    }];
    [alertCtl addAction:album];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertCtl addAction:cancel];
    
    [self.navigationController presentViewController:alertCtl animated:YES completion:nil];
    
    
}



#pragma mark UIImagePickerControllerDelegate Call Back Implementation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        NSString *key = nil;
        
        if (picker.allowsEditing)
        {
            key = UIImagePickerControllerEditedImage;
        }
        else
        {
            key = UIImagePickerControllerOriginalImage;
        }
        //获取图片
        UIImage *image = [info objectForKey:key];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // 固定方向
            //image = [image fixOrientation];//这个方法是UIImage+Extras.h中方法
            //压缩图片质量
            image = [self reduceImage:image percent:0.1];
            CGSize imageSize = image.size;
            imageSize.height = 320;
            imageSize.width = 320;
            //压缩图片尺寸
            image = [self imageWithImageSimple:image scaledToSize:imageSize];
        }
        //上传到服务器
        //[self doAddPhoto:image];
        
        
        //本地头像更改
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UIImageView *avatar = [cell.contentView viewWithTag:101];
        avatar.image = image;
        
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

// 开始拍照
-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //先检查相机可用是否
        BOOL cameraIsAvailable = [self checkCamera];
        if (YES == cameraIsAvailable) {
            [self.navigationController presentViewController:picker animated:YES completion:nil];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-相机”选项中，允许本应用程序访问你的相机。" delegate:self cancelButtonTitle:@"好，我知道了" otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

// 打开本地相册
-(void)localPhoto
{
    //本地相册不需要检查，因为UIImagePickerController会自动检查并提醒
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
    //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
    //获取方法3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

//检查相机是否可用
- (BOOL)checkCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(AVAuthorizationStatusRestricted == authStatus ||
       AVAuthorizationStatusDenied == authStatus)
    {
        //相机不可用
        return NO;
    }
    //相机可用
    return YES;
}

//压缩图片质量
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}
//压缩图片尺寸
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}




#pragma mark -UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellID"];
    cell.selected = NO;
    
    return cell;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else
        return 0.01;
}

#pragma mark - manage memory method
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
