function image_processing_gui()
    % 创建图形界面窗口
    f = figure('Name', '图像处理', 'Position', [500, 500, 600, 400]);
    
    % 图像显示区域
    ax = axes(f, 'Position', [0.1, 0.3, 0.8, 0.6]);
    
    % 菜单栏
    mbar = uimenu(f, 'Text', '文件');
    uimenu(mbar, 'Text', '打开图像', 'MenuSelectedFcn', @(src, event) open_image(ax));  % 传递 ax
    uimenu(mbar, 'Text', '保存图像', 'MenuSelectedFcn', @(src, event) save_image(ax));  % 传递 ax
    
    % 操作按钮
    uicontrol('Style', 'pushbutton', 'String', '显示直方图', 'Position', [50, 50, 100, 30], 'Callback', @(src, event) show_histogram(ax));  % 传递 ax
    uicontrol('Style', 'pushbutton', 'String', '直方图均衡化', 'Position', [160, 50, 120, 30], 'Callback', @(src, event) histogram_eq(ax));  % 传递 ax
    uicontrol('Style', 'pushbutton', 'String', '对比度增强', 'Position', [290, 50, 120, 30], 'Callback', @(src, event) enhance_contrast(ax));  % 传递 ax
end

function open_image(ax)
    [file, path] = uigetfile({'*.png;*.jpg;*.bmp', '所有图像文件'}, '选择图像');
    if file ~= 0
        img = imread(fullfile(path, file));
        imshow(img, 'Parent', ax);  % 使用传递的 ax
    end
end

function show_histogram(ax)
    % 显示灰度直方图
    img = getimage(ax);  % 获取当前显示的图像
    if size(img, 3) == 3
        img = rgb2gray(img);  % 转为灰度图像
    end
    [counts, binLocations] = imhist(img);
    bar(binLocations, counts, 'Parent', ax);
end

function histogram_eq(ax)
    % 直方图均衡化
    img = getimage(ax);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img_eq = histogram_equalization(img);
    imshow(img_eq, 'Parent', ax);
end

function enhance_contrast(ax)
    % 对比度增强
    img = getimage(ax);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img_contrast = contrast_enhancement(img, 'log');  % 例如，使用对数变换
    imshow(img_contrast, 'Parent', ax);
end

function save_image(ax)
    [file, path] = uiputfile('*.png', '保存图像');
    if file ~= 0
        img = getimage(ax);
        imwrite(img, fullfile(path, file));
    end
end

function img_eq = histogram_equalization(img)
    % 灰度直方图均衡化
    [rows, cols] = size(img);
    hist_counts = imhist(img);
    cdf = cumsum(hist_counts) / (rows * cols);  % 累积分布函数
    img_eq = uint8(255 * cdf(double(img) + 1));  % 均衡化后的图像
end

function img_contrast = contrast_enhancement(img, type)
    % 对比度增强，type为'linear'、'log'、'exp'中的一个
    img = double(img);  % 确保输入为 double 类型

    if strcmp(type, 'linear')
        % 线性对比度增强
        img_contrast = imadjust(img);
    elseif strcmp(type, 'log')
        % 对数变换，确保输入大于零
        img_contrast = log(1 + img);  % 先加 1 避免 log(0) 出错
        img_contrast = img_contrast - min(img_contrast(:));  % 归一化到 0 - 1 范围
        img_contrast = img_contrast / max(img_contrast(:)) * 255;  % 归一化到 0 - 255 范围
        img_contrast = uint8(img_contrast);  % 转回 uint8 类型
    elseif strcmp(type, 'exp')
        % 指数变换
        c = 255 / (exp(1) - 1);
        img_contrast = uint8(c * (exp(img / 255) - 1));
    end
end

function img_noise = add_noise(img, noise_type, param)
    % 添加噪声
    if strcmp(noise_type, 'salt & pepper')
        img_noise = imnoise(img, 'salt & pepper', param);
    elseif strcmp(noise_type, 'gaussian')
        img_noise = imnoise(img, 'gaussian', param(1), param(2));  % mean, var
    elseif strcmp(noise_type, 'speckle')
        img_noise = imnoise(img, 'speckle', param);
    end
end

function img_edge = edge_detection(img, method)
    % 使用不同算子进行边缘检测
    if strcmp(method, 'robert')
        img_edge = edge(img, 'Roberts');
    elseif strcmp(method, 'prewitt')
        img_edge = edge(img, 'Prewitt');
    elseif strcmp(method, 'sobel')
        img_edge = edge(img, 'Sobel');
    elseif strcmp(method, 'laplacian')
        img_edge = edge(img, 'log');
    end
end