clc
clear all
close all
tic
addpath subFunctions
% Data=imread('images\cameraman.tif');
% Data=imread('images\rice.tif');
% Data=imread('images\Lena.jpg');
% Data=imread('images\football.jpg');
Data=imread('images\onion.png');
% Data=imread('images\ORLFace.jpg');
[row,col,dim]=size(Data);
if (dim>1)
Data=rgb2gray(Data); % convert into grayscale if input image is a color image
end

%% Scalling and Convertion to binary
% Scalling to convert image into array of 8-pixels; each pixel is of 8 bits
% therefore 8 pixel will be equals to 64 bit of data
[Data,padding]=Scalling(Data,8);
Data_binary=convert2bin(Data);

%% Key Selection and Expansion
% Input the key in the form of 133457799bbcdff1
hex_key = '133457799bbcdff1';
[bin_key] = Hex2Bin( hex_key );
[K1,K2,K3,K4,K5]=SF_Key_Gen(bin_key);

%% Encryption and Decryption
orignal_msg=[];
  encrypt_msg=[];
  decrypt_msg=[];
for i=1:size(Data_binary,1)
    orignal=Data_binary(i,:);
    tic
    [cipher]=SF_Encrypt(orignal,K1,K2,K3,K4,K5);
    encryption_time(i)=toc;
    [plaintext]=SF_Decryption(cipher,K1,K2,K3,K4,K5);
  encrypt_msg(:,i)=Binary2Dec(cipher);
  decrypt_msg(:,i)=Binary2Dec(plaintext);
end

if (padding~=0)
    Data=reshape(Data,[size(Data,1)*size(Data,2) 1]);
    Data=Data(1:end-padding);
    encrypt_msg=reshape(encrypt_msg,[size(encrypt_msg,1)*size(encrypt_msg,2) 1]);
    encrypt_msg=encrypt_msg(1:end-padding);
    decrypt_msg=reshape(decrypt_msg,[size(decrypt_msg,1)*size(decrypt_msg,2) 1]);
    decrypt_msg=decrypt_msg(1:end-padding);
end

%% Converting the Vectors into Images
Orignal=uint8(reshape(Data,[row,col]));
Encrypted=uint8(reshape(encrypt_msg,[row,col]));
Decrypted=uint8(reshape(decrypt_msg,[row,col]));
figure
subplot(1,3,1)
imshow(Orignal)
title('Orignal')
subplot(1,3,2)
imshow(Encrypted)
title('Encrypted')
subplot(1,3,3)
imshow(Decrypted)
title('Decrypted')
figure
subplot(2,1,1)
imhist(Orignal);
subplot(2,1,2)
imhist(Encrypted);
display('Done');
toc

%% Calculating the Encrypted and Orignal image's Entropy
Y=(imhist(Encrypted)+0.00001)/(row*col);
Y=-sum(Y.*log2(Y));
X=(imhist(Orignal)+0.00001)/(row*col);
X=-sum(X.*log2(X));
Re=[X Y]