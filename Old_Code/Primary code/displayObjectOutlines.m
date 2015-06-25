function output_args=displayObjectOutlinesv2(input_args)
% Usage
% This module is used to overlay cell outlines (using different colors to indicate different cell generations) and cell labels on the original images after tracking and save the resulting image.
% Input Structure Members
% CellsLabel � The label matrix containing the cell outlines for the current image.
% CurrentTracks � The list of the tracks for the current image.
% FileRoot � The root of the image file name to be used when generating the image file name for the current image in combination with the current frame number.
% Image � The original image which will be used to generate the image with overlayed outlines and labels.
%  Output Structure Members
% None.


normalize_args.RawImage.Value=input_args.Image.Value;
int_class='uint8';
normalize_args.IntegerClass.Value=int_class;
normalize_output=imNorm(normalize_args);
cur_img=normalize_output.Image;
objects_lbl=input_args.ObjectsLabel.Value;
img_sz=size(objects_lbl);
max_pxl=intmax(int_class);

red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

field_names=fieldnames(input_args);
if (max(strcmp(field_names,'ShowIDs')))
    b_show_ids=input_args.ShowIDs.Value;
else
    b_show_ids=true;
end

%i need to get the outlines of each individual cell since more than one
%cell might be in a blob
avg_filt=fspecial('average',[3 3]);
lbl_avg=imfilter(objects_lbl,avg_filt,'replicate');
lbl_avg=double(lbl_avg).*double(objects_lbl>0);
img_bounds=abs(double(objects_lbl)-lbl_avg);
img_bounds=im2bw(img_bounds,graythresh(img_bounds));

obj_bounds_lin=find(img_bounds);
%draw the cell bounds in red
red_color(obj_bounds_lin)=max_pxl;
green_color(obj_bounds_lin)=0;
blue_color(obj_bounds_lin)=0;

% %get the centroids
% obj_centroids=getApproximateCentroids(objects_lbl);
% obj_centroids(isnan(obj_centroids(:,1)),:)=[];
% nr_objects=size(obj_centroids,1);
label_ids = unique(objects_lbl);
label_ids(label_ids==0) = [];
nr_objects=size(label_ids,1);

if (b_show_ids)
    for j=1:nr_objects
        cell_id = label_ids(j,:);
        [current_x current_y] = find(objects_lbl == cell_id);
        total_x = sum(current_x);
        total_y = sum(current_y);
        total_size = size(current_x, 1);
        centroid_x = total_x/total_size;
        centroid_y = total_y/total_size;        
        %add the cell ids
        text_img=text2im(num2str(cell_id));
        text_img=imresize(text_img,0.75,'nearest');
        text_length=size(text_img,2);
        text_height=size(text_img,1);
        rect_coord_1=round(centroid_x-text_height/2);
        rect_coord_2=round(centroid_x+text_height/2);
        rect_coord_3=round(centroid_y-text_length/2);
        rect_coord_4=round(centroid_y+text_length/2);
        if ((rect_coord_1<1)||(rect_coord_2>img_sz(1))||(rect_coord_3<1)||(rect_coord_4>img_sz(2)))
            continue;
        end
        [text_coord_1 text_coord_2]=find(text_img==0);
        %offset the text coordinates by the image coordinates in the (low,low)
        %corner of the rectangle
        text_coord_1=text_coord_1+rect_coord_1;
        text_coord_2=text_coord_2+rect_coord_3;
        text_coord_lin=sub2ind(img_sz,text_coord_1,text_coord_2);
        %write the text in green
        red_color(text_coord_lin)=max_pxl;
        green_color(text_coord_lin)=max_pxl;
        blue_color(text_coord_lin)=max_pxl;
    end
end

%write the combined channels as an rgb image
%keyboard;
imwrite(cat(3,red_color,green_color,blue_color),input_args.FileName.Value);
output_args=[];

%end displayObjectOutlines
end
