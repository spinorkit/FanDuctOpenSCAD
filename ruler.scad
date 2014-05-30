module cylinder_ep(p1, p2) 
{
	vector = [p2[0] - p1[0],p2[1] - p1[1],p2[2] - p1[2]];
	distance = sqrt(pow(vector[0], 2) +	pow(vector[1], 2) +	pow(vector[2], 2));
	echo(distance);
	translate(vector/2 + p1)
	//rotation of XoY plane by the Z axis with the angle of the [p1 p2] line projection with the X axis on the XoY plane
	rotate([0, 0, atan2(vector[1], vector[0])]) //rotation
	//rotation of ZoX plane by the y axis with the angle given by the z coordinate and the sqrt(x^2 + y^2)) point in the XoY plane
	rotate([0, atan2(sqrt(pow(vector[0], 2)+pow(vector[1], 2)),vector[2]), 0])
	cylinder(h = distance, r = 0.1, center = true);
}



//module ruler(length)
//{
//        difference()
//        {
//                cube( [1, length, 8 ] );
//                for ( i = [1:length-1] )
//                {
//                        translate( [0.05, i, 0] ) 1_mm();
//                        if (i % 5 == 0)
//                        {
//                                translate( [0.05, i, 0] ) 5_mm();
//                        }
//                        if (i % 10 == 0)
//                        {
//                                translate( [0.05, i, 0] ) 10_mm();
//                        }
//                }
//        }
//}
//
//module 1_mm() { cube( [1, 0.125, 3 ] ); }
//module 5_mm() { cube( [5, 0.125, 5 ] ); }
//module 10_mm() { cube( [10, 0.125, 7 ] ); }
//
