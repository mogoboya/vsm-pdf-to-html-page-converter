mkdir bg-images
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 100 -flatten story-01-bg.pdf[0] bg-images/page-01-bg.png
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 100 -flatten story-01-bg.pdf[1] bg-images/page-02-bg.png
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 100 -flatten story-01-bg.pdf[2] bg-images/page-03-bg.png
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 100 -flatten story-01-bg.pdf[3] bg-images/page-04-bg.png
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 100 -flatten story-01-bg.pdf[4] bg-images/page-05-bg.png
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 100 -flatten story-01-bg.pdf[5] bg-images/page-06-bg.png
bin\pngquanti.exe bg-images/*.png
move /Y bg-images\page-01-bg-fs8.png bg-images\page-01-bg.png
move /Y bg-images\page-02-bg-fs8.png bg-images\page-02-bg.png
move /Y bg-images\page-03-bg-fs8.png bg-images\page-03-bg.png
move /Y bg-images\page-04-bg-fs8.png bg-images\page-04-bg.png
move /Y bg-images\page-05-bg-fs8.png bg-images\page-05-bg.png
move /Y bg-images\page-06-bg-fs8.png bg-images\page-06-bg.png