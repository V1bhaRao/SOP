# SOP

The code available in the Github https://github.com/hsijiaxidian/FOCNet and the corresponding FOCNet paper https://www4.comp.polyu.edu.hk/~cslzhang/paper/CVPR19-FOCNet.pdf were used to implement FOCNet for image denoising.




Explanation of the .m files present in the Github :-

Setup.m- Changes directory into matconvnet-1.0-beta25 which is to be downloaded.
vl_compilenn compiles the MEX files in the MatConvNet toolbox. A MEX file is a type of computer file that provides an interface between MATLAB or Octave and functions written in C, C++ or Fortran. It stands for "MATLAB executable".
vl_Setupnn sets up the matconvnet toolbox.

Demo_train_fracDCNN_DAG.m- Here, batch size is taken as 8, learning rate is specified, adam optimizer is used to minimize the loss, sigma i.e., noise level is set as 50.

FracDCNN.m- creates a dagnn object. DagNN is a CNN wrapper which is object oriented and allows constructing networks with a directed acyclic graph (DAG) topology. It is very flexible but a little more complex and slightly slower for small CNNs. The architecture of FOCNet is also specified, giving all the layers as mentioned in the paper.

FracDCNN_train_dag.m-  demonstrates training a CNN using DAGNN wrapper. The getDagNNBatch() function takes label as the clean image present in the train folder. Noise is added to it and it is stored in input. Inputs2 takes the training pair- i.e., the clean and AWGN (Additive white Gaussian noise) added image.

Generatepatches.m- Takes the “train_set” folder and generates the images for training batch by batch. In this case, batch size is taken as 8. Number of scales is also specified here.

Demo_Test_FracDCNN_DAG.m- takes the test folder “testsets”. Here, the “label” variable stores the clean image. Noise is added to this and the resulting image is stored in the variable “input” which is taken as input for the testing evaluation. The label, input and output are displayed using imshow() function. The mean PSNR (peak signal-to-noise ratio) and mean SSIM (Structural Similarity) values are also printed.
 



Steps Followed :-
The steps mentioned in section 4 “Experiments” from the FOCNet paper are followed.  

1. Clean images from the Berkeley Segmentation Dataset (https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/) were downloaded. This contains a BSDS300 dataset including a training and testing folder.
2. matconvnet-1.0-beta25 package was downloaded (https://www.vlfeat.org/matconvnet/). This is a MATLAB Toolbox for implementation of Convolutional Neural Networks (CNNs) for computer vision purposes.
3. MATLAB (R2021a) environment was used on the PC to run the code.
4. A compiler with C++ support like Visual Studio 2015 or a newer version should be downloaded.
5. Check out https://www.vlfeat.org/matconvnet/install/ if any issues are faced during compilation.
6. In vl_compilenn, the path of cl.exe should be changed to the one present in your version of Microsoft Visual Studio. 
7. Configure MATLAB to use the compiler. Before running vl_compilenn, setup mex using the following commands:  
mex –setup                                  (and)  
mex –setup C++  
8. After vl_compilenn and vl_setupnn execute successfully, run Demo_train_fracDCNN_DAG.m. For each noise level (sigma) this creates a folder and the trained epochs (.mat type) are stored within it.
9. Finally, run Demo_test_fracDCNN_DAG.m. This evaluates the denoising performance of FOCNet. It also calculates PSNR and SSIM values for each image and displays their mean. The resulting denoised output images are stored in the “results” folder.  
Changes made to the code:-  
·        In generatepatches.m – Change line 7 to the name of your training set. Ensure that this dataset is present inside the folder “utilities”.  
·        In Demo_test_fracDCNN_DAG.m- Change line 10 such that setTestCur holds the name of the testing test required. Ensure that this set is present inside a folder “testsets”. The current model is saved in data/model. So, uncomment line 25 and comment line 28.  



Modifications:

Presently, the FOCNet code takes a single image and adds noise to it to form the image pairs for the training dataset. This code was modified such that training pairs are externally taken instead of generating the pairs.

In Demo_test_fracDCNN_DAG.m- In line 10, initialize setTestCur with the name of the folder having noisy images for testing. Change line 83 to input = im2single(label)so that extra noise isn’t added to it. Comment out the lines involving PSNR and SSIM as these are required only to compare the output and reference image.

In generatepatches.m- imdb.labels2 is created similar to imdb.labels. For training, pairs consisting of clean and noisy images are required. The corresponding images can be stored in 2 separate folders which can be handled by labels and labels2.

In FracDCNN_train_dag.m- In the function getDagNNBatch, initialize “input” similar to how “label” is initialized but with imdb.labels2. The switch case for ‘Denoising’ can be commented out.
