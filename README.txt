The file "windows-amd64.zip" is all you need to download to run this software on windows.

I developed this small program to solve a real life problem that I had.

While making projects with my uncle using a CNC router, we found it difficult to estimate the volume of resin we would need to fill a certain pocket. In order to make these CNC projects we had already created vectors that would be very helpful for this program.

The program takes two inputs. One is the selected SVG file, and the other is a user typed depth value. The area calculations is straightforward for simple shapes with straight edges, and any curved segments are sampled every thousandth of a mm to create a shape with straight edges and a similar area to the actual shape. These component areas are then added or subtracted depending on their nesting in the overall SVG to return a total area. This is then multiplied by the depth to return a volume in ml.

My main focus in developing this software was to keep the UX as simple as possible as the program is for my uncle to use in future projects, and he is not very confident with using computers.

Overall I'm really happy with how it turned out. The code is relatively clean and efficient, and returns accurate results which help save on wasted resin.