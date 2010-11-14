#!/usr/bin/env python
# Copyright Wesley Tanaka <http://wtanaka.com>
# http://wtanaka.com/node/7552
# Based on http://lists.xcf.berkeley.edu/lists/gimp-user/2006-May/008022.html

from gimpfu import *

def load_file_into_layer(image, defaultlayer, filename, location):
   import os.path
   if filename and not os.path.isdir(filename):
      tempimage = pdb.gimp_file_load(filename, filename)
      templayer = pdb.gimp_image_get_active_layer(tempimage)
      toplayer = pdb.gimp_layer_new_from_drawable(templayer, image)
      tempwidth = pdb.gimp_image_width(tempimage)
      tempheight = pdb.gimp_image_height(tempimage)
      imagewidth = pdb.gimp_image_width(image)
      imageheight = pdb.gimp_image_height(image)
      ypos = 0
      if location <= 1:
         ypos = imageheight-tempheight
      xpos = 0
      if location % 2 == 1:
         xpos = imagewidth-tempwidth
      pdb.gimp_image_add_layer(image, toplayer, -1)
      pdb.gimp_image_delete(tempimage)
      pdb.gimp_layer_translate(toplayer, xpos, ypos)
      defaultlayer = pdb.gimp_image_merge_down(image, toplayer, 0)
   return defaultlayer

# puts the four images specified by filexx into the four corners of a
# new layer and sets the opacity of that new layer
def python_watermark_corners(timg, tdrawable, filell, filelr, fileul,
      fileur, opacity):
#  (gimp-image-undo-group-start image)
   width = tdrawable.width
   height = tdrawable.height

   RGBA=1
   wmarklayer = gimp.Layer(timg, "Watermark", width, height, RGBA,
         NORMAL_MODE)
   timg.add_layer(wmarklayer, -1)
   pdb.gimp_edit_clear(wmarklayer)

   wmarklayer = load_file_into_layer(timg, wmarklayer, filell, 0)
   wmarklayer = load_file_into_layer(timg, wmarklayer, filelr, 1)
   wmarklayer = load_file_into_layer(timg, wmarklayer, fileul, 2)
   wmarklayer = load_file_into_layer(timg, wmarklayer, fileur, 3)
#  (gimp-image-undo-group-end image)

   pdb.gimp_layer_set_opacity(wmarklayer, opacity)

   pdb.gimp_displays_flush()

register(
   "python_fu_watermark_corners",
   "Visible Watermark",
   "Visible Watermark",
   "Wesley Tanaka <http://wtanaka.com>",
   "Wesley Tanaka <http://wtanaka.com>",
   "2010-11-14",
   "Watermark...",
   "RGB*, GRAY*",
   [
      (PF_IMAGE, "image", "Input image", None),
      (PF_DRAWABLE, "drawable", "Input layer", None),
      (PF_FILE, "lower_left", "Lower Left", "/home/wtanaka/my/creative/photos/wmark-ll.png"),
      (PF_FILE, "lower_right", "Lower Right", "/home/wtanaka/my/creative/photos/wmark-lr.png"),
      (PF_FILE, "upper_left", "Upper Left", ""),
      (PF_FILE, "upper_right", "Upper Right", ""),
      (PF_ADJUSTMENT, "opacity", "Opacity", 30, (0, 100, 5)),
   ],
   [],
   python_watermark_corners,
   menu="<Image>/Filters/wtanaka.com"
)

main()
