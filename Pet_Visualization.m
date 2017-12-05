function varargout = Pet_Visualization(varargin)
% PET_VISUALIZATION GUI for visualizing PET images
%      PET_VISUALIZATION, by itself, creates a new PET_VISUALIZATION or raises the existing
%      singleton*.
%
%      H = PET_VISUALIZATION returns the handle to a new PET_VISUALIZATION or the handle to
%      the existing singleton*.
%
%      PET_VISUALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PET_VISUALIZATION.M with the given input arguments.
%
%      PET_VISUALIZATION('Property','Value',...) creates a new PET_VISUALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pet_Visualization_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pet_Visualization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pet_Visualization

% Last Modified by GUIDE v2.5 23-May-2007 15:15:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pet_Visualization_OpeningFcn, ...
                   'gui_OutputFcn',  @Pet_Visualization_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Pet_Visualization is made visible.
function Pet_Visualization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pet_Visualization (see VARARGIN)

% Choose default command line output for Pet_Visualization
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Pet_Visualization wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(gcf,'Renderer','OpenGL');

% --- Outputs from this function are returned to the command line.
function varargout = Pet_Visualization_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global C D;
base = pwd; %store current dir
[filename, pathname] = uigetfile('*.img;*.mat', 'Get img or mat file');
if isequal(filename,0)|isequal(pathname,0)
    disp('File not found')
else % open img file (use any of three .m files) and display first frame
    disp(['File ', pathname, filename, ' found'])
	%A = readanalyze([pathname, filename]); %readanalyze.m
    %A = avw_img_read([pathname, filename]); A = A.img; %avw_img_read.m
    if (strfind(filename,'.img') ~= 0)
		V = spm_vol([pathname, filename]); %spm_vol.m + spm_read_vols.m
        D = spm_read_vols(V);
    	C = permute(D,[2 1 4 3]); %note that x is now y for display
    else 
        load C6.mat;
        D = C6;
        clear C6;
        C = permute(D,[1 2 4 3]);
    end
	C = mat2gray(C); 
	C = flipdim(C,1);
	%set(gcf,'DoubleBuffer','on');
    set(gcf,'Renderer','OpenGL'); lighting gouraud
    %set(gcf,'Renderer','zbuffer'); lighting phong
    %set(gcf,'WVisual','Double Buffered');
    %set(gcf,'BackingStore','off');
    figure_handle = guidata(gcf);
	set(figure_handle.edit1,'Visible','on');
	set(figure_handle.slider1,'Visible','on');
	set(figure_handle.popupmenu2,'Visible','on');
	%Select frames 51 to 56 and use reshape to create an array for montage.
	%Y = reshape(C(:,:,51:56),[size(C,1) size(C,2) 1 6]);
	% Code to display one frame
	image_num = 1;
	image_slice = C(:,:,:,image_num);
	subplot('Position',[0.02 0.55 0.3 0.3]); h=imshow(image_slice);
	set(h,'ButtonDownFcn',@myCallback);
	set(figure_handle.edit1,'String','1');
	set(figure_handle.slider1,'Value',1);
	set(figure_handle.popupmenu2,'Value',1);
	% create structure of handles
	handles = guihandles; 
	% store the data
	%handles.img_data = C; 
	frame_num = size(C,4)
	slider_step(1) = 1/(frame_num-1);
	slider_step(2) = 1/(frame_num-1);
	set(handles.slider1,'sliderstep',slider_step,...
          'max',frame_num,'min',1,'Value',1)
      % save the structure
    guidata(gcf,handles) 
    figure, montage(C);
    clear V;
end
cd (base);

% --------------------------------------------------------------------
function Show3d_view(mean_D)
global D;

figure_handle = guidata(gcf);
subplot('Position',[0.45 0.42 0.5 0.5]);
Di = mat2gray(D); 
Di = gray2ind(Di);
Ds = smooth3(Di);
surface_val = get(figure_handle.edit7,'string');
if strcmp(surface_val, '1') == 1
    % mean_D = round(mean(mean(mean(Di))))
	c = size(Di,3);
	mean_D = 43;%round(mean(mean(Di(:,:,uint8(c/2))))) % use mean of middle slice?
	set(figure_handle.edit7,'string',int2str(mean_D));
end
hiso = patch(isosurface(Ds,mean_D),...
    'FaceColor',[1,.75,.65],...
    'EdgeColor','none');
alpha(.5);
% hcap = patch(isocaps(Di,mean_D),...
%     'FaceColor','interp',...
%     'EdgeColor','none');
% h = vol3d('cdata',D,'texture','3D');
% view(3); 
% % view(-5,26);
% % Update view since 'texture' = '2D'
% %vol3d(h);  
alphamap('default');
alphamap(1 .* alphamap);
adjust_map(23,37);
view(-5,26);
axis tight
daspect([1,1,.6])
lightangle(45,30); 
set(gcf,'Renderer','OpenGL'); lighting phong
isonormals(Ds,hiso)
% set(hcap,'AmbientStrength',.6)
set(hiso,'SpecularColorReflectance',0,'SpecularExponent',50)
%vol3dtool;
%pause;

% Isosurface of MRI data                                                    
% subplot('Position',[0.45 0.42 0.5 0.5]); 
[x y z Ds] = subvolume(Ds, [nan nan nan nan 17 18]);                          
p = patch(isosurface(x,y,z,Ds, mean_D), 'FaceColor', [1,.75,.65], 'EdgeColor', 'none'); 
[x y z Di] = subvolume(Di, [nan nan nan nan 17 18]);                          
p2 = patch(isocaps(x,y,z,Di, mean_D), 'FaceColor', 'interp', 'EdgeColor', 'none');
isonormals(x,y,z,Di,p);                                                      
view(3); axis tight;  daspect([1 1 .6]); %rotate3d on;
view(-5,26);
colormap(gray(100));
camva(6); box on;
camlight(40, 40); camlight(-20,-10); lighting gouraud                       

c = size(D,3);
Di = mat2gray(D); 
D2 = Di;
for x=1:c
    D2(:,:,x) = flipud(Di(:,:,x));
end
D3 = imsubtract(D2,Di);
D3 = gray2ind(D3);
Ds = smooth3(D3);
% mean_D = round(mean(mean(D3(:,:,uint8(c/2))))) % use mean of middle slice?
hiso2 = patch(isosurface(Ds,mean_D),...
    'FaceColor',[1,0,0],...
    'EdgeColor','none');
view(-5,26);
axis tight 
daspect([1,1,.6])
%set(gcf,'Renderer','OpenGL'); lighting phong
isonormals(Ds,hiso2)
set(hiso2,'SpecularColorReflectance',0,'SpecularExponent',50)

%pause
%p=select3d(h);
%disp(sprintf('\nYou clicked at\nX: %.2f\nY: %.2f\nZ: %.2f',p(1),p(2),p(3)'))

%view3d zoom;   %use figure's built in zoom and rotate instead
%rotate3d(gca);

handles = guihandles; 
% store the data and save the structure
handles.threed = gca;
guidata(gcf,handles) 
clear x y z p p2 hiso hcap; %use clearmem?
%clearmem;

function Show3d_view2
global D;

figure_handle = guidata(gcf);
subplot('Position',[0.45 0.42 0.5 0.5]);
Di = mat2gray(D); 
Di = gray2ind(Di);
Ds = smooth3(Di);
c = size(Di,3);
mean_D = round(mean(mean(Di(:,:,uint8(c/2))))) % use mean of middle slice?
hiso = patch(isosurface(Ds,mean_D),...
    'FaceColor',[1,0,0],...
    'EdgeColor','none');
% hcap = patch(isocaps(Di,mean_D),...
%     'FaceColor','interp',...
%     'EdgeColor','none');
% h = vol3d('cdata',D,'texture','3D');
% view(3); 
% % view(-5,26);
% % Update view since 'texture' = '2D'
% %vol3d(h);  
view(-5,26);
axis tight 
daspect([1,1,.6])
% lightangle(45,30); 
set(gcf,'Renderer','OpenGL'); lighting phong
isonormals(Ds,hiso)
% set(hcap,'AmbientStrength',.6)
set(hiso,'SpecularColorReflectance',0,'SpecularExponent',50)
%vol3dtool;
return;

% --------------------------------------------------------------------
function adjust_map(y1, y2)
amap = get(gcf,'AlphaMap');
b=size(amap,2);
figure_handle = guidata(gcf);
set(figure_handle.edit3,'string',int2str(y1));
set(figure_handle.edit4,'string',int2str(y2));
for x=1:y1 amap(x)=0; end;
for x=y1+1:y2 amap(x)=0.03; end;
for x=y2+1:b
    amap(x) = (x-y2)/((1-0)*(b-y2)); % alphamap_index = (index-cm_length)/((amax-amin)*cm_length))
end
set(gcf,'AlphaMap',amap);
y2 = y2;
colormap('default');
cmap = get(gcf,'Colormap');
b=size(cmap,1);
for x=1:y2 mymap(x)=0; end;
for x=y2+1:b
    mymap(x)= (x-y2)/((1-0)*(b-y2));
end
cmap(:,1) = mymap'; % R
%for x=1:b mymap(x)=0; end;
cmap(:,2) = 0; %flipud(mymap'); % G
cmap(:,3) = 0; %flipud(mymap'); % B
set(gcf,'Colormap',cmap);


% --------------------------------------------------------------------
function clearmem
global C;
save 'C.mat' C;
clear all %V D x y z p p2;
load C;

% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --------------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% ---------- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% ------------- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

t=cputime;
%C = squeeze(C);
% get the structure in the subfunction
figure_handle = guidata(gcf);
global C;
%C = figure_handle.img_data;
val = get(figure_handle.popupmenu2,'Value');
str = get(figure_handle.popupmenu2, 'String');
current_frame = get(handles.slider1,'Value');
switch str{val};
case 'View 1'
	image_slice = C(:,:,:,current_frame);
case 'View 2'
	image_slice = C(:,current_frame,:,:);
    image_slice = squeeze(image_slice);
%    T = maketform('affine',[0 1; 1 0; 0 0]);
%    image_slice = imtransform(image_slice, T,'cubic');
%    image_slice = imrotate(image_slice,-90);
case 'View 3'
    image_slice = C(current_frame,:,:,:);
    image_slice = squeeze(image_slice);
%    image_slice = imrotate(image_slice,-90);
end
subplot('Position',[0.02 0.55 0.3 0.3]); h=imshow(image_slice);
set(h,'ButtonDownFcn',@myCallback);
set(figure_handle.edit1,'string',int2str(current_frame));
disp(sprintf('%f',cputime-t));
clear h;

% ------------------ Callback when image slice is clicked.
function myCallback(obj,eventdata)
    t=cputime;
    figure_handle = guidata(gcf);
    global C;
    %C = figure_handle.img_data;
    pos_cursor = get( gca, 'currentpoint'); % gets pos_clicked (x,y) of interest
    x = uint8(pos_cursor(1,1));
    y = uint8(pos_cursor(1,2));
    z = uint8(str2num(get(figure_handle.edit1,'string')));    % gets current slice/frame
    b=get(figure_handle.popupmenu2,'Value');
    %msgbox(strcat(int2str(x),',',int2str(y),',',int2str(z),',',int2str(b)),'X and Y','modal');
    disp(strcat(int2str(pos_cursor(1,1)),',',int2str(pos_cursor(1,2)),',',get(figure_handle.edit1,'string'),',',int2str(b)));
    switch b
	case 1
		top=z; side=y; front=x;
	case 2
		top=x; side=y; front=z;
	case 3
        top=x; side=z; front=y;
	end
	image_slice = C(:,:,:,top);
	subplot('Position',[0.02 0.05 0.3 0.3]); imshow(image_slice);
	image_slice = C(:,front,:,:);
    image_slice = squeeze(image_slice);
	subplot('Position',[0.35 0.05 0.3 0.3]); imshow(image_slice);
    image_slice = C(side,:,:,:);
    image_slice = squeeze(image_slice);
	subplot('Position',[0.70 0.05 0.3 0.3]); imshow(image_slice);
    disp(sprintf('%f',cputime-t));

    
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
figure_handle = guidata(gcf);
global C;
%C = figure_handle.img_data;
val = get(hObject,'Value');
str = get(hObject, 'String');
image_num = 1; set(figure_handle.edit1,'string',int2str(image_num));
switch str{val};
case 'View 1'
    frame_num = size(C,4);
	image_slice = C(:,:,:,image_num);
case 'View 2'
    frame_num = size(C,2);
	image_slice = C(:,image_num,:,:);
    image_slice = squeeze(image_slice);
%    T = maketform('affine',[0 1; 1 0; 0 0]);
%    image_slice = imtransform(image_slice, T,'cubic');
%    image_slice = imrotate(image_slice,-90);
case 'View 3'
    frame_num = size(C,1);
    image_slice = C(image_num,:,:,:);
    image_slice = squeeze(image_slice);
%    image_slice = imrotate(image_slice,-90);
end
subplot('Position',[0.02 0.55 0.3 0.3]); h=imshow(image_slice);
set(h,'ButtonDownFcn',@myCallback);
slider_step(1) = 1/(frame_num-1);
slider_step(2) = 1/(frame_num-1);
set(figure_handle.slider1,'sliderstep',slider_step,...
      'max',frame_num,'min',1,'Value',1)
guidata(hObject,handles)
clear h;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
figure_handle = guidata(gcf);
set(gcf, 'CurrentAxes',figure_handle.threed);
toggle = get(hObject,'Value');
switch toggle;
    case 0
        cla;
    case 1
        Show3d_view(double(str2num(get(figure_handle.edit7,'string'))));
end


% --------------------------------------------------------------------
function view_Callback(hObject, eventdata, handles)
% hObject    handle to view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function show_3d_Callback(hObject, eventdata, handles)
% hObject    handle to show_3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
Show3d_view(double(str2num(get(figure_handle.edit7,'string'))));
set(figure_handle.checkbox1,'Visible','on','Value',1);


% --------------------------------------------------------------------
function compare_Callback(hObject, eventdata, handles)
% hObject    handle to compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global C D;
base = pwd; %store current dir
loop_num = 1;
defaultfiles = cell(2,loop_num);
for x=1:loop_num
	[defaultfile, path1] = uigetfile('*.img', 'Get first img file');
	if isequal(defaultfile,0)|isequal(path1,0)
        disp('File not found')
        return;
	else % open img file 
        defaultfiles(1,x)= cellstr(path1); 
        defaultfiles(2,x)= cellstr(defaultfile);
		[files, path] = uigetfiles('*.img', 'Select all img files');
		if isequal(files,0)|isequal(path,0)
            disp('File not found')
            return;
		else  
        if (x==1) compare_files=cell(loop_num,size(files,2)); end
        compare_files(x,:) = files;
		end %end if 2nd file loop
	end %end if 1st file loop
end %end for
% fid = fopen('var.txt','a');
% fprintf(fid,'img1\timg2\tcyan_count\tcyan_total\tred_count\tred_total\n');
for aa=1:size(defaultfiles,2)
    for bb=1:size(files,2)
        %disp(['File ', path1, defaultfiles, ' found'])
        img1=char(strcat(defaultfiles(1,aa), defaultfiles(2,aa)));
		V1 = spm_vol(img1); 
        D1 = spm_read_vols(V1);
        D1 = permute(D1,[2 1 3]);
        img2=char(strcat(defaultfiles(1,aa), compare_files(aa,bb)))
		V2 = spm_vol(img2); %spm_vol.m + spm_read_vols.m
        D2 = spm_read_vols(V2);
        D2 = permute(D2,[2 1 3]);
%  		C3 = zeros(size(D1,1),size(D1,2),3,size(D1,3));
%        C4 = permute(D2,[1 2 4 3]);
%          C5 = permute(D2,[1 2 4 3]);
        if (bb==1) 
            C3 = zeros(size(D1,1),size(D1,2),1,size(files,2)); 
            C4 = zeros(size(D1,1),size(D1,2),3,size(files,2)); 
            C5 = zeros(size(D1,1),size(D1,2),3,size(files,2)); 
        end;
        d = size(D1,3);
        red_count=0;
        cyan_count=0;
        red_total=0;
        cyan_total=0;
%         D1 = mat2gray(D1);
%         D2 = mat2gray(D2);
		for x=25:25
            input_normal = flipud(D1(:,:,x));
            input_normal=squeeze(input_normal);
            [a,b,c] = size(input_normal);
            input_ab = flipud(D2(:,:,x));
            input_ab=squeeze(input_ab);
            % red image
            B = gray2ind(input_ab,256); cmap = zeros(256,3);
            for i=1:256 cmap(i,1)= i/256; end 
            result1 = ind2rgb(B,cmap); 
            % green image
            B = gray2ind(input_normal,256); cmap = zeros(256,3);
            for i=1:256 cmap(i,2)= i/256; end 
            result2 = ind2rgb(B,cmap); 
            % blue image
            B = gray2ind(input_normal,256); cmap = zeros(256,3);
            for i=1:256 cmap(i,3)= i/256; end 
            result3 = ind2rgb(B,cmap); 
			%add images
            result=result1+result2+result3;
            clear result3 result1 result2;
            %copy results into 4D for displaying
            C4(:,:,:,bb) = result;
            clear result;
		end %end for
        clear D1 V1 D2 V2;
% 	    C1 = permute(D1,[1 2 4 3]);
%     	C1 = flipdim(C1,1);
% 	    C1 = mat2gray(C1);
%         figure, montage(C1);
% 		C2 = permute(D2,[1 2 4 3]);
%     	C2 = flipdim(C2,1);
% 		C2 = mat2gray(C2);
%         figure, montage(C2);
%if (bb==2) || (bb==6) || (bb==10) || (bb==14) || (bb==18) || (bb==22) || (bb==24)
%         C6 = squeeze(C5(:,:,1,:));        
%         save 'C6.mat' C6; 
%         clear C6;
% 		fprintf(fid,'%s\t%s\t',img1, img2');
% 		fprintf(fid,'%12.8f\t%12.8f\t',cyan_count,cyan_total);
% 		fprintf(fid,'%12.8f\t%12.8f',red_count,red_total);
% 		fprintf(fid,'\n');
	end %end for
end %end for
%         colormap('default');
%         cmap = colormap;
%     	C3 = flipdim(C3,1);
%         C3 = mat2gray(C3);
        figure, montage(C4);
%         set(gcf,'Colormap',cmap);
        C = C4;
%     	C4 = flipdim(C4,1);
%         C4 = mat2gray(C4);
%         figure, montage(C4);
%         C5 = flipdim(C5,1);
%         C5 = mat2gray(C5);
%         figure, montage(C5); %end
        clear C1 C2 C3 C4 C5;
        pack;
% fprintf(fid,'\n');
% fclose(fid);
cd (base);


% --------------------------------------------------------------------
function subtract_Callback(hObject, eventdata, handles)
% hObject    handle to subtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global C D;
% base = pwd; %store current dir
% [filename, pathname] = uigetfile('*.img', 'Get img file');
% if isequal(filename,0)|isequal(pathname,0)
%     disp('File not found')
% else % open img file (use any of three .m files) and display first frame
%     disp(['File ', pathname, filename, ' found'])
	%A = readanalyze([pathname, filename]); %readanalyze.m 
    %A = avw_img_read([pathname, filename]); A = A.img; %avw_img_read.m
% 	V1 = spm_vol([pathname, filename]); %spm_vol.m + spm_read_vols.m
%     D1 = spm_read_vols(V1);
    D1 = squeeze(C);
	%D1 = permute(D1,[2 1 3]);
	C2 = zeros(size(D1,1),size(D1,2),3,size(D1,3));
	C3 = zeros(size(D1,1),size(D1,2),3,size(D1,3));
    d = size(D1,3)
	for x=1:d
        input = D1(:,:,x);
        input_normal=squeeze(input);
        [a,b,c] = size(input);
        [color_add colored_input] = coloring_seg(input);
        C2(:,:,:,x) = colored_input;
        C3(:,:,:,x) = color_add;
	end %end for
	C1 = permute(D1,[1 2 4 3]);
    %C1 = flipdim(C1,1);
	C1 = mat2gray(C1);
    C1 = padarray(C1,[5 5],0,'both');
    figure, montage(C1)
   	%C2 = flipdim(C2,1);
    C2 = mat2gray(C2);
%    D = squeeze(C2(:,:,1,:));
%    Show3d_view2;
    C2 = padarray(C2,[5 5],0,'both');
    figure, montage(C2);
    C3 = mat2gray(C3);
    C3 = padarray(C3,[5 5],0,'both');
    figure, montage(C3);
% end
% cd (base);


% --------------------------------------------------------------------
function coregister_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global C;
C1=C;
[a b s c]=size(C);
if (ndims(C)==4) && (s==3)
    C1 = C1(:,:,1,:) + C1(:,:,2,:) + C1(:,:,3,:);
end
image_var=var(C1);
C1=squeeze(C);
D1 = zeros(a,b,c);
x_count_values = zeros(a,1);
y_count_values = zeros(b,1);
thresh_values = zeros(c,1);
window_thresh = zeros(1,3);
%[BW1,thresh] = edge(squeeze(C1(:,:,uint8(c/2))),'sobel'); %use threshold for middle slice
m=double(uint8(c*0.25));
n=double(uint8(c*0.75));
low=image_var*10;
if (low>0.1) 
    high=0.5;
    if (low > 1) low = 0.3; end;
else high=low*5; end;
for x=m:n %sobel filter for edge detection
	input = C1(:,:,x);
	input=squeeze(input);
    [BW1 thresh] = edge(input,'canny',[low high]);
    D1(:,:,x) = BW1;
    %thresh_values(x,1) = thresh;
end
% first_sagittal_slice = im2double(squeeze(D1(:,1,:)));
% last_sagittal_slice = im2double(squeeze(D1(:,b,:)));
% first_coronal_slice = im2double(squeeze(D1(1,:,:)));
% last_coronal_slice = im2double(squeeze(D1(a,:,:)));
for x=1:a %count ones on sagittal slices (left to right array)
    input = squeeze(D1(x,:,:));
    % Sum up each slice across view.
	y_count_values(x,1) = sum(sum(input));
end
for x=1:b %count ones on coronal slices (top down array)
    input = squeeze(D1(:,x,:));
   	x_count_values(x,1) = sum(sum(input));
end
smoothed_x_count_values = smooth(x_count_values);
smoothed_y_count_values = smooth(y_count_values);
mean_x = mean(squeeze(x_count_values));
mean_y = mean(squeeze(y_count_values));
% figure, plot(x_count_values);
% figure, plot(y_count_values);
higher = 0;
temp = zeros(1,3);
index = 0;
for x=1:a 
     if smoothed_x_count_values(x,1) > mean_x && (higher == 0)
         temp(1,1) = x;
         index = index + 1;
         higher = 1;
     end
     if smoothed_x_count_values(x,1) < mean_x && (higher == 1)
         temp(1,2) = x;
         higher = 0;
         temp(1,3) = temp(1,2) - temp(1,1)
         if (index == 1) 
             window_thresh = temp; 
         else 
             window_thresh = cat(1,window_thresh,temp); end;
     end
end
[p,r] = max(squeeze(window_thresh(:,3)));
X1 = window_thresh(r,1);
X2 = window_thresh(r,2);
% for x=1:a 
%      if x_count_values(x,1) > mean_x, X1 = x, break; end
% end
% for x=a:-1:1 
%      if x_count_values(x,1) > mean_x, X2 = x, break; end
% end
higher = 0;
temp = zeros(1,3);
index = 0;
for x=1:b 
     if smoothed_y_count_values(x,1) > mean_y && (higher == 0)
         temp(1,1) = x;
         index = index + 1;
         higher = 1;
     end
     if smoothed_y_count_values(x,1) < mean_y && (higher == 1)
         temp(1,2) = x;
         higher = 0;
         temp(1,3) = temp(1,2) - temp(1,1) 
         if (index == 1) window_thresh = temp; 
         else window_thresh = cat(1,window_thresh,temp); end;
     end
end
[p,r] = max(squeeze(window_thresh(:,3)));
Y1 = window_thresh(r,1);
Y2 = window_thresh(r,2);
% figure, plot(smoothed_x_count_values);
% figure, plot(smoothed_y_count_values);
% for x=1:b 
%      if y_count_values(x,1) > mean_y, Y1 = x, break; end
% end
% for x=b:-1:1 
%      if y_count_values(x,1) > mean_y, Y2 = x, break; end
% end
xmin = min([X1 X2]);
ymin = min([Y1 Y2]);
width = max([X1 X2])-xmin;
height= max([Y1 Y2])-ymin;
cor_C1 = zeros(height+1,width+1,s,c);
for x=1:c
    cor_img = imcrop(squeeze(C(:,:,:,x)), [xmin ymin width height]);
    cor_C1(:,:,:,x) = cor_img;
end
%cor_C1 = permute(cor_C1,[1 2 4 3]);
cor_C1 = padarray(cor_C1,[5 5],0,'both');
figure, montage(cor_C1);
D1 = permute(D1,[1 2 4 3]);
figure, montage(D1);
% return; % future work is how to obtain correct angle of rotation
translate_x = int8(((a - (X2 - X1))/2) - X1);
translate_y = int8(((b - (Y2 - Y1))/2) - Y1);
trans_C = my_translate(C1,double(translate_x),double(translate_y));
% trans_D = my_translate(D1,double(translate_x),double(translate_y));
v=[translate_x translate_y];
%angle = find_angle(trans_D,5,-5,-1,v);
angle = 0;%find_angle(trans_C,20,-20,-5,v);
%angle = find_angle(trans_C,angle+5,angle-5,-2,v);
angle = find_angle(trans_C,angle+2,angle-2,-1,v);
angle = -angle/2
rotated_C = my_transform(trans_C,angle);
rotated_C = permute(rotated_C,[1 2 4 3]);
C = rotated_C;
figure, montage(rotated_C);


function rot_angle = find_angle(trans_C1,a,b,c,v1)
% Initialize variables
mean_corr_value = 0;
max_corr_value = 0;
flipped_C = flipdim(trans_C1,2); % flip axial plane from left to right
[y z d]=size(trans_C1);
xmin = double(v1(1));
ymin = double(v1(2));
if (xmin<0) xmin=-xmin; end
if (ymin<0) ymin=-ymin; end
width = y-xmin-xmin;
height= z-ymin-ymin;
x=double(uint8(d*0.3));
self_corr_value = max(max(xcorr2(trans_C1(:,:,x), trans_C1(:,:,x))));
for rotation_angle = a:c:b 
	rot_C = my_transform(flipped_C,rotation_angle); %-ve angle for counterclockwise
	%rot_C1 = permute(rot_C,[1 2 4 3]);
    %figure, montage(rot_C1);
    m=double(uint8(d*0.55));
    n=double(uint8(d*0.45));
    corr_value = zeros((m-n+1),1);
	for x=n:m
        im_xc = imcrop(squeeze(trans_C1(:,:,x)), [xmin ymin width height]);
        image_rotate = imcrop(squeeze(rot_C(:,:,x)), [xmin ymin width height]);
		% Cross-correlate the rotated image and the original.
		corr_value(x-n+1,1) = max(max(xcorr2(im_xc, image_rotate)));  
    end
    mean_corr_value = max(corr_value);
    % if correlation value is larger than previous values, save the rotation angle(rot_angle)
    if mean_corr_value > max_corr_value
         max_corr_value = mean_corr_value;   
         rot_angle = rotation_angle;
    end
end



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
y_1 = double(str2num(get(figure_handle.edit3,'string')));
y_2 = double(str2num(get(figure_handle.edit4,'string')));
adjust_map((y_1-1),y_2);
set(figure_handle.edit3,'string',int2str(y_1-1));
%vol3dtool;


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
y_1 = double(str2num(get(figure_handle.edit3,'string')));
y_2 = double(str2num(get(figure_handle.edit4,'string')));
adjust_map((y_1+1),y_2);
set(figure_handle.edit3,'string',int2str(y_1+1));
%vol3dtool;


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
y_1 = double(str2num(get(figure_handle.edit3,'string')));
y_2 = double(str2num(get(figure_handle.edit4,'string')));
adjust_map(y_1,(y_2-1));
set(figure_handle.edit4,'string',int2str(y_2-1));
%vol3dtool;


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
y_1 = double(str2num(get(figure_handle.edit3,'string')));
y_2 = double(str2num(get(figure_handle.edit4,'string')));
adjust_map(y_1,(y_2+1));
set(figure_handle.edit4,'string',int2str(y_2+1));
%vol3dtool;


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
file_num = double(str2num(get(figure_handle.edit6,'string')));
load_file(file_num-1);
Show3d_view(double(str2num(get(figure_handle.edit7,'string'))));
% subplot('Position',[0.45 0.42 0.5 0.5]);
% h = vol3d('cdata',D,'texture','3D');
% view(3); 
% view(-5,26);
% axis tight;  %daspect([.5 .5 .5])
figure_handle = guidata(gcf);
y_1 = double(str2num(get(figure_handle.edit3,'string')));
y_2 = double(str2num(get(figure_handle.edit4,'string')));
adjust_map(y_1,y_2);
set(figure_handle.edit6,'string',int2str(file_num-1));


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
file_num = double(str2num(get(figure_handle.edit6,'string')));
load_file(file_num+1);
Show3d_view(double(str2num(get(figure_handle.edit7,'string'))));
% subplot('Position',[0.45 0.42 0.5 0.5]);
% h = vol3d('cdata',D,'texture','3D');
% view(3); 
% view(-5,26);
% axis tight;  %daspect([.5 .5 .5])
figure_handle = guidata(gcf);
y_1 = double(str2num(get(figure_handle.edit3,'string')));
y_2 = double(str2num(get(figure_handle.edit4,'string')));
adjust_map(y_1,y_2);
set(figure_handle.edit6,'string',int2str(file_num+1));


% --------------------------------------------------------------------
function time_series_Callback(hObject, eventdata, handles)
% hObject    handle to time_series (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global D pet_files dir_path;
[pet_files, dir_path] = uigetfiles('*.img', 'Select all img files');
if isequal(pet_files,0)|isequal(dir_path,0)
    disp('File not found')
    return;
else 
    load_file(1);
    Show3d_view(double(str2num(get(figure_handle.edit7,'string'))));
end 

function load_file(num)
global D pet_files dir_path;
img=char(strcat(dir_path,pet_files(1,num)));
V = spm_vol(img); 
D = spm_read_vols(V);
D = permute(D,[2 1 3]);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
set(gcf, 'CurrentAxes',figure_handle.threed);
surface_num = double(str2num(get(figure_handle.edit7,'string')));
cla;
Show3d_view(surface_num);
set(figure_handle.edit7,'string',int2str(surface_num-1));


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure_handle = guidata(gcf);
set(gcf, 'CurrentAxes',figure_handle.threed);
surface_num = double(str2num(get(figure_handle.edit7,'string')));
cla;
Show3d_view(surface_num);
set(figure_handle.edit7,'string',int2str(surface_num+1));


