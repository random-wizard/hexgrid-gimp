# hexgrid-gimp

Hexgrid is a script-fu plugin for gimp. It creates a set of layers and an image grid suitable for making hex maps with custom brush tiles. Hexgrid is derived from hexGIMP by isomage.

## setup instructions

Find where gimp has setup the scripts and brushes folder. This varies with operating system and which version of gimp is installed. Copy the bw_*.br files from brushes directory into the brushes directory of the gimp installation. Copy the hexgrid.scm file from the scripts directory into the scripts directory of the gimp installation.

## using hexgrid

Start gimp. A new menu item named "New Hex Map" should appear under the "File" menu. Specify the size of the map in the Columns and Rows boxes. Hit OK and the script-fu will generate a new image with a hex grid and layers to help with building up a hex map.

Make sure "Snap to Grid" is checked under the "View" menu. This will help with getting the hex paint brush to align correctly the pregenerated grid.
