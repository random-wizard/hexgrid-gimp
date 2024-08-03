;; NAME
;;      hexgrid
;;
;; VERSION
;;      2024-07-09
;;
;; DESCRIPTION
;;  Hexgrid is a Script-Fu plugin for GIMP.  It creates a set of layers
;;      and an image grid suitable for making hex maps with custom brush
;;      tiles. Hexgrid is derived from hexGIMP by isomage.
;;
;;      Parameters:
;;          hex rows
;;          hex columns
;;
;; AUTHOR
;;      random-wizard : https://random-wizard.github.io
;;      isomage : http://axiscity.hexamon.net/users/isomage
;;
;; LICENSE
;;      Hexgrid is free software.
(define hex_width 38)
(define hex_height 31)
(define hex_1_x 28)
(define hex_2_x 9)
(define hex_0_y 15)

(define number-font "Sans")
(define number-size 7)

(define (hex-origin i j)
  (list (* i (+ hex_1_x 1))
        (+ 1
           (if (zero? (modulo i 2))
             (* j (+ 1 hex_height))
             (+ (* j (+ 1 hex_height)) hex_0_y 1)))))

(define (hex-center i j)
  (let ((origin (hex-origin i j)))
    (list (+ (car origin) (/ hex_width 2))
          (+ (cadr origin) (/ hex_height 2)))))

(define (fill-hex-grid drawable cols rows hex)
  (gimp-brushes-set-brush hex)
  (let ((y 0))
    (while (< y rows)
           (let ((x 0))
             (while (< x cols)
                    (let ((center (hex-center x y))
                          (coords (cons-array 2 'double)))
                      (aset coords 0 (car center))
                      (aset coords 1 (cadr center))
                      (gimp-pencil drawable 2 coords))
                    (set! x (+ 1 x))))
           (set! y (+ 1 y)))))

(define (make-label coord-separator x y)
  (string-append
    (if (< x 10) (number->string 0) "")
    (number->string x)
    coord-separator
    (if (< y 10) (number->string 0) "")
    (number->string y)))

(define (number-hex-grid
         image
         drawable
         x0
         y0
         x1
         y1
         ix
         iy
         coord-separator)
  (let ((y y0))
    (while (<= y y1)
           (let ((x x0))
             (while (<= x x1)
                    (let* ((center (hex-center x y))
                           (xcoord (car center))
                           (ycoord (- (cadr center) (/ hex_height 2) 1))
                           (layer (car (gimp-text-fontname
                                         image
                                         drawable
                                         xcoord
                                         ycoord
                                         (make-label
                                           coord-separator
                                           (+ ix (- x x0))
                                           (+ iy (- y y0)))
                                         -1
                                         TRUE
                                         number-size
                                         POINTS
                                         number-font)))
                           (width (car (gimp-drawable-width layer))))
                      (gimp-layer-translate layer (- (/ width 2)) 0)
                      (gimp-floating-sel-anchor layer))
                    (set! x (+ 1 x))))
           (set! y (+ 1 y)))))

(define (new-hex-map
         cols
         rows
         numbering
         number-from
         number-to
         number-initial
         coord-separator)
  (let ((width (+ (* (+ hex_1_x 1) cols) hex_2_x))
        (height
          (+ (* (+ hex_height 1) rows) (+ hex_0_y 1) 1)))
    (let* ((image (car (gimp-image-new width height RGB)))
           (layer-terrain
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Terrain"
                    100
                    NORMAL-MODE)))
           (layer-water
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Water"
                    100
                    NORMAL-MODE)))
           (layer-roads
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Roads"
                    100
                    NORMAL-MODE)))
           (layer-cities
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Cities"
                    100
                    NORMAL-MODE)))
           (layer-grid
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Grid"
                    75
                    MULTIPLY-MODE)))
           (layer-borders
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Borders"
                    100
                    NORMAL-MODE)))
           (layer-numbers
             (car (gimp-layer-new
                    image
                    width
                    height
                    RGBA-IMAGE
                    "Numbers"
                    100
                    NORMAL-MODE))))
      (gimp-image-add-layer image layer-terrain -1)
      (gimp-image-add-layer image layer-water -1)
      (gimp-image-add-layer image layer-roads -1)
      (gimp-image-add-layer image layer-cities -1)
      (gimp-image-add-layer image layer-grid -1)
      (gimp-image-add-layer image layer-borders -1)
      (gimp-image-add-layer image layer-numbers -1)
      (gimp-edit-clear layer-terrain)
      (gimp-edit-clear layer-water)
      (gimp-edit-clear layer-roads)
      (gimp-edit-clear layer-cities)
      (gimp-edit-clear layer-grid)
      (gimp-edit-clear layer-borders)
      (gimp-edit-clear layer-numbers)
      (fill-hex-grid
        layer-terrain
        cols
        rows
        "bw_hex_blank")
      (if (equal? numbering FALSE)
        (gimp-image-remove-layer image layer-numbers)
        (let ((x0 (string->number (substring number-from 0 2)))
              (y0 (string->number (substring number-from 2)))
              (x1 (string->number (substring number-to 0 2)))
              (y1 (string->number (substring number-to 2)))
              (ix (string->number (substring number-initial 0 2)))
              (iy (string->number (substring number-initial 2))))
          (gimp-context-set-foreground '(100 100 100))
          (number-hex-grid
            image
            layer-numbers
            x0
            y0
            x1
            y1
            ix
            iy
            coord-separator)))
      (let ((foreground (car (gimp-context-get-foreground))))
        (gimp-context-set-foreground '(150 150 150))
        (gimp-by-color-select
          layer-terrain
          '(255 255 255)
          0
          0
          FALSE
          FALSE
          0
          FALSE)
        (gimp-selection-invert image)
        (gimp-bucket-fill
          layer-grid
          FG-BUCKET-FILL
          NORMAL-MODE
          100
          0
          FALSE
          0
          0)
        (gimp-selection-none image)
        (gimp-context-set-foreground foreground))
      (gimp-image-grid-set-spacing image 29 16)
      (gimp-image-grid-set-offset image 19 0)
      (gimp-image-grid-set-style image GRID-DOTS)
      (gimp-image-set-active-layer image layer-terrain)
      (gimp-display-new image))))

(script-fu-register
  "new-hex-map"
  "<Toolbox>/File/New Hex Map"
  "Create a new hex map"
  "random-wizard"
  "isomage"
  "Created 2009-04-13, Last Modified 2024-07-09"
  ""
  SF-VALUE
  "Columns"
  "16"
  SF-VALUE
  "Rows"
  "16"
  SF-TOGGLE
  "Number hexes"
  FALSE
  SF-STRING
  "Top left"
  "0000"
  SF-STRING
  "Bottom right"
  "1515"
  SF-STRING
  "Initial value"
  "0000"
  SF-STRING
  "Coordinate separator"
  "")
