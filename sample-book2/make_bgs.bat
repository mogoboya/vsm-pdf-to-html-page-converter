mkdir bg-images
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 95 -density 400 merged_r.pdf[0] bg-images/page-01-bg.jpg
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 95 -density 400 merged_r.pdf[1] bg-images/page-02-bg.jpg
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 95 -density 400 merged_r.pdf[2] bg-images/page-03-bg.jpg
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 95 -density 400 merged_r.pdf[3] bg-images/page-04-bg.jpg
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 95 -density 400 merged_r.pdf[4] bg-images/page-05-bg.jpg
convert +profile \"!sRGB,*\" -colorspace sRGB -intent Perceptual -background white -quality 95 -density 400 merged_r.pdf[5] bg-images/page-06-bg.jpg
convert bg-images/page-01-bg.jpg -resize 612x783 -unsharp 0x0.75+0.75+0.008 bg-images/page-01-bg.jpg
convert bg-images/page-02-bg.jpg -resize 612x783 -unsharp 0x0.75+0.75+0.008 bg-images/page-02-bg.jpg
convert bg-images/page-03-bg.jpg -resize 612x783 -unsharp 0x0.75+0.75+0.008 bg-images/page-03-bg.jpg
convert bg-images/page-04-bg.jpg -resize 612x783 -unsharp 0x0.75+0.75+0.008 bg-images/page-04-bg.jpg
convert bg-images/page-05-bg.jpg -resize 612x783 -unsharp 0x0.75+0.75+0.008 bg-images/page-05-bg.jpg
convert bg-images/page-06-bg.jpg -resize 612x783 -unsharp 0x0.75+0.75+0.008 bg-images/page-06-bg.jpg