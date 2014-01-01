/*
 *  Oval Fanduct 
 *  Copyright (C) 2013  Kit Adams
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
*/

use <fan_holder_v2.scad>
use <shapes.scad>

$fn=20;

layerHeight = 0.192;  //Layer height used for printing
m3_diameter = 3.6;
kFanSize = 40;
fanAngleFromVert = 30;

//Settings for E3D V5 hotend and extruder from http://www.thingiverse.com/thing:119616 
heaterBlockW = 17;  //18;//first cut
heaterBlockGap = 6; //gap between vented tube and heated block
mountToHeatBlockHorizontal = 21.5;
mountToHotEndBottomZ = 58;

ventedDuctMaxHeight = 18; //16; //first cut
ventedDuctWidth = 12; //10;//first cut

mountingHingeDia = 8;
hingeInsideWidth = 7.2;
hingeOuterWidth = 4;
hingeLen = 8.5;
outerRadius = 1.5; //outer corner radius
wall = 1.6;



FanSplitter(mountToHotEndBottomZ,kFanSize,heaterBlockW,mountToHeatBlockHorizontal,ventedDuctMaxHeight,ventedDuctWidth);
mirror([0,1,0])
	FanSplitter(mountToHotEndBottomZ,kFanSize,heaterBlockW,mountToHeatBlockHorizontal,ventedDuctMaxHeight,ventedDuctWidth);

translate([-outerRadius,-kFanSize/2,-mountingHingeDia])
	{
	_fan_mount(
			fan_size = kFanSize,
			fan_mounting_pitch = 32,
			fan_m_hole_dia = 2, //For self-tapping screws
			holder_thickness = mountingHingeDia
		 );

//Airflow splitter
	translate([0,(kFanSize-wall)/2,0])
		{
//Shear the rectangule to get half the splitter
		multmatrix(m = [ [1, 0, 0, 0],
                 		  [0, 1, wall/(2*mountingHingeDia), 0],
                        [0, 0, 1, 0],
                        [0, 0, 0,  1]
                        ])
			cube([kFanSize,wall,mountingHingeDia]);
//Shear the other half the other way
		multmatrix(m = [ [1, 0, 0, 0],
                 		  [0, 1, -wall/(2*mountingHingeDia), 0],
                        [0, 0, 1, 0],
                        [0, 0, 0,  1]
                        ])
			cube([kFanSize,wall,mountingHingeDia]);
		}

//Mounting hinge
	translate([kFanSize,kFanSize/2+hingeInsideWidth/2,0])
		MountingHinge(mountingHingeDia,hingeLen,hingeOuterWidth);
	translate([kFanSize,kFanSize/2-hingeInsideWidth/2-hingeOuterWidth,0])
		MountingHinge(mountingHingeDia,hingeLen,hingeOuterWidth);
	}	


//mirror([0,1,0])
//	ventedTube();


//MountingHinge();

module MountingHinge(dia = 8, lenIn = 12,thickness = 4)
{
len = lenIn-dia/2;
difference()
	{
	union()
		{
		translate([len,thickness,dia/2])
		rotate([90,0,0])
			cylinder(h = thickness,r = dia/2);
		cube([len,thickness,dia]);
		}
	translate([len,thickness,dia/2])
	rotate([90,0,0])
		cylinder(h = thickness,r = m3_diameter/2);				
	}
}


module FanSplitter(mountToHotEndBottomZ, fanSizeIn = 30, heaterBlockW = 20, mountToHeatBlockHorizontal = 10, smallDuctH = 20, smallDuctW = 12)
{
//Two mirrored version of this attach to the fan mount and duct the air to the level of the heated //block of the hotend.
fanSize = fanSizeIn-2*outerRadius;
minAngle = 30;
xTrans = cos(fanAngleFromVert)*mountToHotEndBottomZ-hingeLen-fanSize/2-smallDuctH/2;
zTrans = tan(minAngle)*xTrans+fanSize/2+smallDuctH/2; //keep the steepest angle >= minAngle deg from x y plane.
yTrans = heaterBlockW/2 + heaterBlockGap + smallDuctW/2;
width = fanSize/2;
nzSteps = zTrans/layerHeight; 
di = 1/nzSteps;
stepZ = zTrans*di;
union()
{
for(i=[0:di:1])
	{
	assign(width = fanSize/2*(1-i)+i*smallDuctW, height = fanSize*(1-i)+i*smallDuctH )
		{
	
		translate([-xTrans*i,yTrans*i,zTrans*i])
		difference()
			{
			minkowski()
				{
				cube([(1-i)*height,(1-i)*width,stepZ]);
				//cylinder(stepZ,max(outerRadius,i*height/2),max(outerRadius,i*width/2));
				oval(((1-i)*outerRadius+i*height/2),((1-i)*outerRadius+i*width/2),stepZ);
				}
			translate([(1-i)*wall,(1-i)*wall,0])
			scale([(height-2*wall)/height, (width-2*wall)/width,1])
				minkowski()
					{
					cube([(1-i)*height,(1-i)*width,stepZ]);
					//cylinder(stepZ,max(outerRadius,i*height/2),max(outerRadius,i*width/2));
					oval(((1-i)*outerRadius+i*height/2),((1-i)*outerRadius+i*width/2),stepZ);
					}
			}
		}
	}
translate([-xTrans,yTrans,zTrans])
	mirror([0,1,0])
		ventedTube(smallDuctH,smallDuctW,heaterBlockW+heaterBlockGap*2,fanAngleFromVert);
}

}

module ventedTube(height, width, len, fanAngleFromVert)
{

xTrans = len*sin(fanAngleFromVert)
	-(height-width)/2; //Compensate for blend from oval to circular below, so as to keep bottom to tube horizontal

slotAngle = fanAngleFromVert-atan(0.5*(height-width)/len);

zTrans = len*cos(fanAngleFromVert);
nzSteps = zTrans/layerHeight; 
di = 1/nzSteps;

stepZ = zTrans*di;
r1 = height/2;
r2 = width/2;

slotWidth = r2*3.1459*45/180; //Corresponds to 45 degrees

difference()
	{ 
	union()
		{
		for(i = [0:di:1-di])
			{//Blend from oval to circular to reduce volume in a linear fashion
			assign(r1 = (height/2)*(1-i)+i*width/2)
				{
				translate([xTrans*i,0,zTrans*i])
					ovalTube(stepZ,r1,r2,wall);
				}
			}
		//End cap
		translate([xTrans,0,zTrans])
			endCap(r2,wall,fanAngleFromVert/2);
		}
		rotate([0,slotAngle,0]) //Second, rotate the slot to be parallel to the ventedTube
			rotate([0,0,90])  //First, rotate the slot to point down at an angle of 60 from horizontal
				translate([0,0,height/3])
					{
					hull()
						{
						cube([slotWidth,2*r2,len-height/2-r2]);
						//Add prism at top to avoid need for support
						translate([slotWidth/2,0,len-height/2])
							cube([0.5,2*r2,0.5*slotWidth]);
						//Add prism at bottom for symmetry
						translate([slotWidth/2,0,-height/3])
							cube([0.5,2*r2,0.5*slotWidth]);
						}
					}
	}

}


module endCap(r,wall,fanAngleFromVert)
{
len = 1.4*r;
xTrans = len*sin(fanAngleFromVert);
zTrans = len*cos(fanAngleFromVert);
nzSteps = zTrans/layerHeight; 
di = 1/nzSteps;
stepZ = zTrans*di;
r1 = r-wall;
for(i = [0:di:1])
	{
	assign(r1 = (r-wall)*(1-i)+wall)
		{
		translate([xTrans*i,0,zTrans*i])
			ovalTube(stepZ,r1,r1,wall);
		}
	}
}

module coneTube(h, r1, r2, wall, center = false)
{
difference()
	{
	cylinder(h, r1, r2, center);
	cylinder(h, r1-wall, r2-wall, center);
	}
}
