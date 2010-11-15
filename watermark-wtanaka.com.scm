; Copyright Wesley Tanaka <http://wtanaka.com>
; http://wtanaka.com/node/7552
; Based on http://lists.xcf.berkeley.edu/lists/gimp-user/2006-May/008022.html

; Loads a file into a new top-level layer at the given location,
; and returns the resulting layer.  If filename is
; empty, return defaultlayer
(define (script-fu-load-file-into-layer image defaultlayer filename location)
   (if (and (not (null? filename)) (> (string-length filename) 0))
      (let*
         (
            (errobj ())
            (tempimage (car (gimp-file-load 1 filename filename)))
         )
         
         (if (eq? errobj ())
            (let*
               (

                  (templayer (car (gimp-image-get-active-layer tempimage)))
                  (toplayer (car (gimp-layer-new-from-drawable templayer image))) 
                  (tempwidth (car (gimp-image-width tempimage)))
                  (tempheight (car (gimp-image-height tempimage)))
                  (imagewidth (car (gimp-image-width image)))
                  (imageheight (car (gimp-image-height image)))
                  (ypos (cond ((<= location 1) (- imageheight tempheight))
                              ((>= location 2) 0)
                        )
                  )
                  (xpos (cond ((= (fmod location 2) 0) 0)
                              ((= (fmod location 2) 1) (- imagewidth tempwidth))
                        )
                  )
               )
               (gimp-image-add-layer image toplayer -1)
               (gimp-image-delete tempimage)
               (gimp-layer-translate toplayer xpos ypos)
               (car (gimp-image-merge-down image toplayer 0))
            )
         )
      )
;     else
      defaultlayer
   )
)

; puts the four images specified by filexx into the four corners of a
; new layer and sets the opacity of that new layer
(define (script-fu-watermark-corners image drawable filell filelr fileul fileur opacity)
;  (gimp-image-undo-group-start image)
   (let*
      (
         (wmarklayer (car (gimp-layer-new image 
                                          (car (gimp-image-width image))
                                          (car (gimp-image-height image))
                                          RGBA-IMAGE
                                          "Watermark"
                                          100
                                          NORMAL-MODE)))
      )

      (gimp-image-add-layer image wmarklayer -1)
      (gimp-edit-clear wmarklayer)

      (let*
         (
            (withll (script-fu-load-file-into-layer image wmarklayer filell 0))
            (withlr (script-fu-load-file-into-layer image withll filelr 1))
            (withul (script-fu-load-file-into-layer image withlr fileul 2))
            (withur (script-fu-load-file-into-layer image withul fileur 3))
         )
         (gimp-layer-set-opacity withul opacity)
      )
   )

;  (gimp-image-undo-group-end image)
   (gimp-displays-flush)
)

(script-fu-register "script-fu-watermark-corners"
   "<Image>/Script-Fu/wtanaka.com/Watermark"
   "Visible Watermark"
   "Wesley Tanaka <http://wtanaka.com>"
   "Wesley Tanaka <http://wtanaka.com>"
   "2007-05-13"
   "RGB*, GRAY*"
   SF-IMAGE "Input Image" 0
   SF-DRAWABLE "Input Drawable" 0
   SF-FILENAME "Lower Left" "/home/wtanaka/my/creative/photos/wmark-ll.png"
   SF-FILENAME "Lower Right" "/home/wtanaka/my/creative/photos/wmark-lr.png"
   SF-FILENAME "Upper Left" ""
   SF-FILENAME "Upper Right" ""
   SF-ADJUSTMENT "Opacity" '(30 0 100 5 10 0 1)
)
