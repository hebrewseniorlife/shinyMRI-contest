# shinyMRI-contest
https://community.rstudio.com/t/shiny-contest-submission-shinymri-view-mri-images-in-shiny/23995

![](https://community.rstudio.com/uploads/default/optimized/2X/9/9ae6cecde050278c43a0423ec4dd64260756394c_2_690x366.gif)

![](https://community.rstudio.com/uploads/default/optimized/2X/6/6040cf7208bac035be04f4d6e7bfd723073460e9_2_690x444.gif)

This app demonstrates using R shiny to dynamically visualize 3D/4D medical imaging data in the conventional way. It offers a basic yet useful tool for researchers and clinicians to quickly check MRI data inside a browser. More importantly, the mechanism we used here can be used to visualize any 3D voxel data. Here we are using MRI images as an example because this is a well-known format for the public and it's fun to play with.

This app provides two modes to visualize the data. In the first mode, you can play the images like a movie. We call it "animation" mode. Behind the scene, the images are rendered into pngs under a different environment (See lazyr.R). Therefore, we can enjoy the ultimate streaming speed provided by renderImage while the main Shiny thread won't get blocked when generating those plots. This is different from the strategy of promises as promises is good for "a few operations that take a long time" while we have "lots of little operations that a bit slow".

In the second mode, you can play with the app interactively by clicking a point on any of the three plots. This 3D position will then be mapped to the other two plots and show you the cross-sectional picture of that point in the 3D space (indicated by the crosshair). In our field, clinicians uses this to diagnostic cerebrovascular diseases or other things like white matter disease.

If you check the source code of app.R, you will see the app itself is very small. The truth is that this time we also wraped up the two modes I just described as shiny modules. In the near future, we will release this two modules as a separate R package so people can use them more easily.

Authors:
- Hao Zhu
- Nischal Mahaveer Chand
- Thomas Travison
